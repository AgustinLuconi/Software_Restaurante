import '../dominio/entidades/notificacion.dart';
import '../dominio/repositorios/notificacion_repositorio.dart';

class NotificacionRepositorioMemoria implements NotificacionRepositorio {
  final List<Notificacion> _notificaciones = [];
  int _contadorId = 1;

  @override
  Future<Notificacion> crearNotificacion(Notificacion notificacion) async {
    final nuevaNotificacion = Notificacion(
      id: 'notif_${_contadorId++}',
      usuarioId: notificacion.usuarioId,
      titulo: notificacion.titulo,
      mensaje: notificacion.mensaje,
      tipo: notificacion.tipo,
      fechaCreacion: notificacion.fechaCreacion,
      leida: false,
      reservaId: notificacion.reservaId,
      negocioId: notificacion.negocioId,
    );
    
    _notificaciones.add(nuevaNotificacion);
    return nuevaNotificacion;
  }

  @override
  Future<List<Notificacion>> obtenerNotificacionesPorUsuario(String usuarioId) async {
    final notificaciones = _notificaciones
        .where((n) => n.usuarioId == usuarioId)
        .toList();
    
    // Ordenar por fecha más reciente primero
    notificaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return notificaciones;
  }

  @override
  Future<List<Notificacion>> obtenerNotificacionesNoLeidas(String usuarioId) async {
    final notificaciones = _notificaciones
        .where((n) => n.usuarioId == usuarioId && !n.leida)
        .toList();
    
    notificaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return notificaciones;
  }

  @override
  Future<bool> marcarComoLeida(String notificacionId) async {
    try {
      final notificacion = _notificaciones.firstWhere((n) => n.id == notificacionId);
      notificacion.marcarComoLeida();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> marcarTodasComoLeidas(String usuarioId) async {
    try {
      final notificacionesUsuario = _notificaciones
          .where((n) => n.usuarioId == usuarioId && !n.leida);
      
      for (var notificacion in notificacionesUsuario) {
        notificacion.marcarComoLeida();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> eliminarNotificacion(String notificacionId) async {
    try {
      _notificaciones.removeWhere((n) => n.id == notificacionId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> contarNotificacionesNoLeidas(String usuarioId) async {
    return _notificaciones
        .where((n) => n.usuarioId == usuarioId && !n.leida)
        .length;
  }
}
