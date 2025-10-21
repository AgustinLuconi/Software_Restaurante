import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class CancelarReserva {
  final ReservaRepositorio reservaRepositorio;

  CancelarReserva(this.reservaRepositorio);

  Future<void> execute(String reservaId) async {
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);
    if (reserva == null) {
      throw Exception('Reserva no encontrada');
    }
    final ahora = DateTime.now();
    final diferencia = reserva.fechaHora.difference(ahora);
    if (reserva.estado != EstadoReserva.confirmada && reserva.estado != EstadoReserva.pendiente) {
      throw Exception('Solo se pueden cancelar reservas confirmadas o pendientes.');
    }
    if (reserva.fechaHora.isBefore(ahora)) {
      throw Exception('No se puede cancelar una reserva cuya hora ya pasó.');
    }
    if (diferencia.inHours < 24) {
      throw Exception('Solo se puede cancelar la reserva con al menos 24 horas de anticipación.');
    }
    await reservaRepositorio.cancelarReserva(reservaId);
  }
}
