import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/negocio_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';
import 'procesar_lista_de_espera.dart';

class CancelarReserva {
  final ReservaRepositorio reservaRepositorio;
  final ProcesarListaDeEspera? procesarListaDeEspera;
  final NegocioRepositorio? negocioRepositorio;

  CancelarReserva(
    this.reservaRepositorio, {
    this.procesarListaDeEspera,
    this.negocioRepositorio,
  });

  Future<void> ejecutar(String reservaId, {String negocioId = 'negocio_1'}) async {
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);
    if (reserva == null) {
      throw Exception('Reserva no encontrada');
    }
    
    // Obtener configuración del negocio
    int minHorasParaCancelar = 24; // Valor por defecto
    
    if (negocioRepositorio != null) {
      final negocio = await negocioRepositorio!.obtenerNegocioPorId(negocioId);
      if (negocio != null) {
        minHorasParaCancelar = negocio.minHorasParaCancelar;
      }
    }
    
    final ahora = DateTime.now();
    final diferencia = reserva.fechaHora.difference(ahora);
    if (reserva.estado != EstadoReserva.confirmada && reserva.estado != EstadoReserva.pendiente) {
      throw Exception('Solo se pueden cancelar reservas confirmadas o pendientes.');
    }
    if (reserva.fechaHora.isBefore(ahora)) {
      throw Exception('No se puede cancelar una reserva cuya hora ya pasó.');
    }
    if (diferencia.inHours < minHorasParaCancelar) {
      throw Exception('Solo se puede cancelar con $minHorasParaCancelar horas de anticipación.');
    }
    
    // Cancelar la reserva
    await reservaRepositorio.cancelarReserva(reservaId);
    
    // Procesar lista de espera si está disponible
    if (procesarListaDeEspera != null) {
      try {
        await procesarListaDeEspera!.ejecutar(reservaId);
      } catch (e) {
        print('⚠️  Error al procesar lista de espera: $e');
        // No lanzamos el error para que la cancelación no falle si hay problemas con la lista de espera
      }
    }
  }
}
