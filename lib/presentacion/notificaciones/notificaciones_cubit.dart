import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/repositorios/notificacion_repositorio.dart';
import 'notificaciones_estados_de_cubit.dart';

class NotificacionesCubit extends Cubit<NotificacionesState> {
  final NotificacionRepositorio notificacionRepositorio;

  NotificacionesCubit(this.notificacionRepositorio) : super(const NotificacionesInicial());

  Future<void> cargarNotificaciones(String usuarioId) async {
    try {
      emit(const NotificacionesCargando());
      
      final notificaciones = await notificacionRepositorio.obtenerNotificacionesPorUsuario(usuarioId);
      final noLeidas = await notificacionRepositorio.contarNotificacionesNoLeidas(usuarioId);
      
      emit(NotificacionesCargadas(
        notificaciones: notificaciones,
        noLeidas: noLeidas,
      ));
    } catch (e) {
      emit(NotificacionesConError('Error al cargar notificaciones: $e'));
    }
  }

  Future<void> marcarComoLeida(String notificacionId, String usuarioId) async {
    try {
      await notificacionRepositorio.marcarComoLeida(notificacionId);
      // Recargar notificaciones
      await cargarNotificaciones(usuarioId);
    } catch (e) {
      emit(NotificacionesConError('Error al marcar notificación: $e'));
    }
  }

  Future<void> marcarTodasComoLeidas(String usuarioId) async {
    try {
      await notificacionRepositorio.marcarTodasComoLeidas(usuarioId);
      // Recargar notificaciones
      await cargarNotificaciones(usuarioId);
    } catch (e) {
      emit(NotificacionesConError('Error al marcar notificaciones: $e'));
    }
  }

  Future<void> eliminarNotificacion(String notificacionId, String usuarioId) async {
    try {
      await notificacionRepositorio.eliminarNotificacion(notificacionId);
      // Recargar notificaciones
      await cargarNotificaciones(usuarioId);
    } catch (e) {
      emit(NotificacionesConError('Error al eliminar notificación: $e'));
    }
  }
}
