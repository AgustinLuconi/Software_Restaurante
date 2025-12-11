import '../../dominio/entidades/notificacion.dart';

abstract class NotificacionesState {
  const NotificacionesState();
}

class NotificacionesInicial extends NotificacionesState {
  const NotificacionesInicial();
}

class NotificacionesCargando extends NotificacionesState {
  const NotificacionesCargando();
}

class NotificacionesCargadas extends NotificacionesState {
  final List<Notificacion> notificaciones;
  final int noLeidas;

  const NotificacionesCargadas({
    required this.notificaciones,
    required this.noLeidas,
  });
}

class NotificacionesConError extends NotificacionesState {
  final String mensaje;

  const NotificacionesConError(this.mensaje);
}
