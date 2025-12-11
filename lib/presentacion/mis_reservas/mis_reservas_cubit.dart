import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cancelar_reserva.dart';
import '../../aplicacion/obtener_reserva.dart';
import '../../service_locator.dart';
import 'mis_reservas_estados_de_cubit.dart';

class MisReservasCubit extends Cubit<MisReservasState> {
  final ObtenerReserva _obtenerReserva;
  final CancelarReserva _cancelarReserva;

  MisReservasCubit()
      : _obtenerReserva = getIt<ObtenerReserva>(),
        _cancelarReserva = getIt<CancelarReserva>(),
        super(MisReservasInicial());

  Future<void> cargarReservas() async {
    try {
      emit(MisReservasCargando());
      final reservas = await _obtenerReserva.ejecutar();
      emit(MisReservasExitoso(reservas));
    } catch (e) {
      emit(MisReservasConError('Error al cargar las reservas: ${e.toString()}'));
    }
  }

  Future<void> cancelarReserva(String reservaId) async {
    try {
      await _cancelarReserva.ejecutar(reservaId);
      emit(ReservaCancelada('Reserva cancelada exitosamente'));
      // Recargar las reservas
      await cargarReservas();
    } catch (e) {
      emit(MisReservasConError('Error al cancelar la reserva: ${e.toString()}'));
    }
  }
}
