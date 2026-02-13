import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cancelar_reserva.dart';
import '../../aplicacion/obtener_reserva.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import '../../service_locator.dart';
import 'mis_reservas_estados_de_cubit.dart';

class MisReservasCubit extends Cubit<MisReservasState> {
  final ObtenerReserva _obtenerReserva;
  final CancelarReserva _cancelarReserva;
  final ReservaRepositorio _reservaRepositorio;

  MisReservasCubit()
      : _obtenerReserva = getIt<ObtenerReserva>(),
        _cancelarReserva = getIt<CancelarReserva>(),
        _reservaRepositorio = getIt<ReservaRepositorio>(),
        super(MisReservasInicial());

  Future<void> cargarReservas({String? contactoCliente}) async {
    try {
      emit(MisReservasCargando());
      final reservas = await _obtenerReserva.ejecutar(contactoCliente: contactoCliente);
      emit(MisReservasExitoso(reservas));
    } catch (e) {
      emit(MisReservasConError('Error al cargar las reservas: ${e.toString()}'));
    }
  }

  Future<void> cancelarReserva(String reservaId, {String? negocioId}) async {
    try {
      // Si no se proporciona negocioId, obtener de la reserva
      String idNegocio = negocioId ?? '';
      if (idNegocio.isEmpty) {
        final reserva = await _reservaRepositorio.obtenerReservaPorId(reservaId);
        if (reserva != null) {
          // El negocioId se obtiene de la mesa asociada
          idNegocio = 'default'; // Fallback si no está disponible
        }
      }
      
      await _cancelarReserva.ejecutar(reservaId, negocioId: idNegocio);
      emit(ReservaCancelada('Reserva cancelada exitosamente'));
      // Recargar las reservas
      await cargarReservas();
    } catch (e) {
      emit(MisReservasConError('Error al cancelar la reserva: ${e.toString()}'));
    }
  }
}
