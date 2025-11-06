import '../entidades/notificacion.dart';

abstract class NotificacionRepositorio {
  /// Crear una nueva notificación
  Future<Notificacion> crearNotificacion(Notificacion notificacion);
  
  /// Obtener todas las notificaciones de un usuario
  Future<List<Notificacion>> obtenerNotificacionesPorUsuario(String usuarioId);
  
  /// Obtener notificaciones no leídas de un usuario
  Future<List<Notificacion>> obtenerNotificacionesNoLeidas(String usuarioId);
  
  /// Marcar una notificación como leída
  Future<bool> marcarComoLeida(String notificacionId);
  
  /// Marcar todas las notificaciones de un usuario como leídas
  Future<bool> marcarTodasComoLeidas(String usuarioId);
  
  /// Eliminar una notificación
  Future<bool> eliminarNotificacion(String notificacionId);
  
  /// Contar notificaciones no leídas
  Future<int> contarNotificacionesNoLeidas(String usuarioId);
}
