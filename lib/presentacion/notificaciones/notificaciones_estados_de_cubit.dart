import '../../dominio/entidades/notificacion.dart';

abstract class NotificacionesState {
  const NotificacionesState();
}

class NotificacionesInitial extends NotificacionesState {
  const NotificacionesInitial();
}

class NotificacionesLoading extends NotificacionesState {
  const NotificacionesLoading();
}

class NotificacionesLoaded extends NotificacionesState {
  final List<Notificacion> notificaciones;
  final int noLeidas;

  const NotificacionesLoaded({
    required this.notificaciones,
    required this.noLeidas,
  });
}

class NotificacionesError extends NotificacionesState {
  final String mensaje;

  const NotificacionesError(this.mensaje);
}
