abstract class ServicioNotificaciones {
  /// Notifica a un usuario que hay una mesa disponible
  /// [usuarioId] - ID del usuario a notificar
  /// [mensaje] - Mensaje de la notificación
  Future<void> notificarDisponibilidad(String usuarioId, String mensaje);
}
