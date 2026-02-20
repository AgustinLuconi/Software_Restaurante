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

  Future<void> cancelarReserva(String reservaId, {String? negocioId}) async {
    try {
      emit(MisReservasCargando());

      // El caso de uso CancelarReserva se encarga de:
      //   1. Validar reglas de negocio (horas mínimas, estado válido, etc.)
      //   2. Cancelar en Firestore
      //   3. Enviar emails de notificación al cliente y al dueño
      final idNegocio = negocioId ?? 'default';
      await _cancelarReserva.ejecutar(reservaId, negocioId: idNegocio);

      emit(ReservaCancelada('Reserva cancelada exitosamente'));
      
      // Recargar las reservas
      await cargarReservas();
    } catch (e) {
      print('❌ Error al cancelar reserva: $e');
      emit(ReservaCancelacionError('Error al cancelar: ${e.toString().replaceAll('Exception: ', '')}'));
      // Recargar para volver al estado Exitoso y mostrar la lista
      try { await cargarReservas(); } catch (_) {}
    }
  }
}
