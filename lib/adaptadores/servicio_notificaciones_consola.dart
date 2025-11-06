import '../dominio/entidades/notificacion.dart';
import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/notificacion_repositorio.dart';
import '../dominio/servicios/servicio_notificaciones.dart';

/// Implementación del servicio de notificaciones que crea notificaciones in-app
/// y opcionalmente imprime en consola para debugging
class ServicioNotificacionesConsola implements ServicioNotificaciones {
  final NotificacionRepositorio notificacionRepositorio;

  ServicioNotificacionesConsola(this.notificacionRepositorio);

  @override
  Future<void> notificarDisponibilidad(String usuarioId, String mensaje) async {
    await crearNotificacion(
      usuarioId: usuarioId,
      titulo: '✅ Mesa Disponible',
      mensaje: mensaje,
      tipo: TipoNotificacion.mesaDisponible,
    );
    
    print('📧 NOTIFICACIÓN para usuario $usuarioId:');
    print('   $mensaje');
    print('---');
  }

  @override
  Future<Notificacion> crearNotificacion({
    required String usuarioId,
    required String titulo,
    required String mensaje,
    required TipoNotificacion tipo,
    String? reservaId,
    String? negocioId,
  }) async {
    final notificacion = Notificacion(
      id: '', // Se generará en el repositorio
      usuarioId: usuarioId,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      fechaCreacion: DateTime.now(),
      reservaId: reservaId,
      negocioId: negocioId,
    );

    return await notificacionRepositorio.crearNotificacion(notificacion);
  }

  @override
  Future<void> notificarReservaConfirmada(String clienteId, Reserva reserva) async {
    await crearNotificacion(
      usuarioId: clienteId,
      titulo: '✅ Reserva Confirmada',
      mensaje: 'Tu reserva para el ${_formatearFecha(reserva.fechaHora)} a las ${_formatearHora(reserva.fechaHora)} ha sido confirmada.',
      tipo: TipoNotificacion.reservaConfirmada,
      reservaId: reserva.id,
    );
    
    print('✅ Reserva confirmada para cliente $clienteId');
  }

  @override
  Future<void> notificarReservaCancelada(String clienteId, Reserva reserva, {bool porNegocio = false}) async {
    final mensaje = porNegocio
        ? 'Lo sentimos, tu reserva para el ${_formatearFecha(reserva.fechaHora)} ha sido cancelada por el restaurante.'
        : 'Tu reserva para el ${_formatearFecha(reserva.fechaHora)} ha sido cancelada exitosamente.';
    
    await crearNotificacion(
      usuarioId: clienteId,
      titulo: '❌ Reserva Cancelada',
      mensaje: mensaje,
      tipo: TipoNotificacion.reservaCancelada,
      reservaId: reserva.id,
    );
    
    print('❌ Reserva cancelada para cliente $clienteId');
  }

  @override
  Future<void> notificarNuevaReservaDueno(String negocioId, Reserva reserva) async {
    await crearNotificacion(
      usuarioId: negocioId,
      titulo: '🔔 Nueva Reserva',
      mensaje: 'Nueva reserva para el ${_formatearFecha(reserva.fechaHora)} a las ${_formatearHora(reserva.fechaHora)} - ${reserva.numeroPersonas} personas',
      tipo: TipoNotificacion.reservaPendiente,
      reservaId: reserva.id,
      negocioId: negocioId,
    );
    
    print('🔔 Nueva reserva para negocio $negocioId');
  }

  @override
  Future<void> notificarRecordatorioReserva(String clienteId, Reserva reserva) async {
    await crearNotificacion(
      usuarioId: clienteId,
      titulo: '⏰ Recordatorio de Reserva',
      mensaje: 'Recordatorio: Tienes una reserva hoy a las ${_formatearHora(reserva.fechaHora)} para ${reserva.numeroPersonas} personas.',
      tipo: TipoNotificacion.recordatorioReserva,
      reservaId: reserva.id,
    );
    
    print('⏰ Recordatorio enviado a cliente $clienteId');
  }

  @override
  Future<void> notificarCambioHorarios(String negocioId, String mensaje) async {
    await crearNotificacion(
      usuarioId: negocioId,
      titulo: '📅 Cambio de Horarios',
      mensaje: mensaje,
      tipo: TipoNotificacion.cambioHorario,
      negocioId: negocioId,
    );
    
    print('📅 Cambio de horarios para negocio $negocioId');
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
