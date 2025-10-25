import '../dominio/servicios/servicio_notificaciones.dart';

/// Implementación simple del servicio de notificaciones que imprime en consola
/// En producción, esto podría enviar emails, SMS, push notifications, etc.
class ServicioNotificacionesConsola implements ServicioNotificaciones {
  @override
  Future<void> notificarDisponibilidad(String usuarioId, String mensaje) async {
    print('📧 NOTIFICACIÓN para usuario $usuarioId:');
    print('   $mensaje');
    print('---');
  }
}
