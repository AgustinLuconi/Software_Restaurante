import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/negocio_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class CancelarReserva {
  final ReservaRepositorio reservaRepositorio;
  final NegocioRepositorio negocioRepositorio;

  CancelarReserva(
    this.reservaRepositorio, {
    required this.negocioRepositorio,
  });

  Future<void> ejecutar(String reservaId, {required String negocioId}) async {
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);
    if (reserva == null) {
      throw Exception('Reserva no encontrada');
    }
    
    if (reserva.estado != EstadoReserva.confirmada && reserva.estado != EstadoReserva.pendiente) {
      throw Exception('Solo se pueden cancelar reservas confirmadas o pendientes.');
    }
    
    final ahora = DateTime.now();
    if (reserva.fechaHora.isBefore(ahora)) {
      throw Exception('No se puede cancelar una reserva cuya hora ya pasó.');
    }
    
    // Obtener configuración del negocio
    final negocio = await negocioRepositorio.obtenerNegocioPorId(negocioId);
    final minHorasParaCancelar = negocio?.minHorasParaCancelar ?? 24;
    
    final diferencia = reserva.fechaHora.difference(ahora);
    if (diferencia.inHours < minHorasParaCancelar) {
      throw Exception('Solo se puede cancelar con $minHorasParaCancelar horas de anticipación.');
    }
    
    // Cancelar la reserva
    await reservaRepositorio.cancelarReserva(reservaId);
  }
}
