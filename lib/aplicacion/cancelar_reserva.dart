import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/mesa_repositorio.dart';
import '../dominio/repositorios/negocio_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';
import '../adaptadores/servicio_email.dart';

class CancelarReserva {
  final ReservaRepositorio reservaRepositorio;
  final NegocioRepositorio? negocioRepositorio;
  final MesaRepositorio? mesaRepositorio;
  final ServicioEmail? servicioEmail;

  CancelarReserva(
    this.reservaRepositorio, {
    this.negocioRepositorio,
    this.mesaRepositorio,
    this.servicioEmail,
  });

  /// Cancelar reserva por el cliente
  Future<void> ejecutar(String reservaId, {required String negocioId}) async {
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);
    if (reserva == null) {
      throw Exception('Reserva no encontrada');
    }
    
    // Obtener configuración del negocio
    int minHorasParaCancelar = 24; // Valor por defecto
    String nombreNegocio = 'Restaurante';
    String? emailDueno;
    
    if (negocioRepositorio != null) {
      final negocio = await negocioRepositorio!.obtenerNegocioPorId(negocioId);
      if (negocio != null) {
        minHorasParaCancelar = negocio.minHorasParaCancelar;
        nombreNegocio = negocio.nombre;
        emailDueno = negocio.email;
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

    // Enviar email de cancelación por cliente
    if (servicioEmail != null) {
      try {
        String nombreMesa = 'Mesa';
        if (mesaRepositorio != null) {
          final mesa = await mesaRepositorio!.obtenerMesaPorId(reserva.mesaId);
          if (mesa != null) nombreMesa = mesa.nombre;
        }
        
        await servicioEmail!.notificarReservaCanceladaPorCliente(
          reserva,
          nombreNegocio: nombreNegocio,
          nombreMesa: nombreMesa,
          emailDueno: emailDueno,
        );
        print('📧 Emails de cancelación enviados desde caso de uso CancelarReserva');
      } catch (e) {
        print('⚠️ Error enviando email de cancelación: $e');
      }
    }
  }

  /// Cancelar reserva por el administrador/dueño del restaurante
  Future<void> ejecutarComoAdmin(String reservaId, {required String negocioId, String? motivo}) async {
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);
    if (reserva == null) {
      throw Exception('Reserva no encontrada');
    }
    
    // El admin puede cancelar sin restricciones de tiempo
    await reservaRepositorio.cancelarReserva(reservaId);

    // Enviar email informando al cliente que el restaurante canceló
    if (servicioEmail != null) {
      try {
        String nombreNegocio = 'Restaurante';
        String nombreMesa = 'Mesa';
        
        if (negocioRepositorio != null) {
          final negocio = await negocioRepositorio!.obtenerNegocioPorId(negocioId);
          if (negocio != null) nombreNegocio = negocio.nombre;
        }
        if (mesaRepositorio != null) {
          final mesa = await mesaRepositorio!.obtenerMesaPorId(reserva.mesaId);
          if (mesa != null) nombreMesa = mesa.nombre;
        }

        await servicioEmail!.notificarReservaCanceladaPorRestaurante(
          reserva,
          nombreNegocio: nombreNegocio,
          nombreMesa: nombreMesa,
          motivo: motivo,
        );
        print('📧 Email de cancelación por admin enviado desde caso de uso CancelarReserva');
      } catch (e) {
        print('⚠️ Error enviando email de cancelación por admin: $e');
      }
    }
  }
}
