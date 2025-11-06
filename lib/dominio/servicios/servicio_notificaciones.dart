import '../entidades/notificacion.dart';
import '../entidades/reserva.dart';

abstract class ServicioNotificaciones {
  /// Notifica a un usuario que hay una mesa disponible
  Future<void> notificarDisponibilidad(String usuarioId, String mensaje);
  
  /// Crear una notificación en el sistema
  Future<Notificacion> crearNotificacion({
    required String usuarioId,
    required String titulo,
    required String mensaje,
    required TipoNotificacion tipo,
    String? reservaId,
    String? negocioId,
  });
  
  /// Notificar al cliente cuando su reserva es confirmada
  Future<void> notificarReservaConfirmada(String clienteId, Reserva reserva);
  
  /// Notificar al cliente cuando su reserva es cancelada
  Future<void> notificarReservaCancelada(String clienteId, Reserva reserva, {bool porNegocio = false});
  
  /// Notificar al dueño del negocio sobre una nueva reserva
  Future<void> notificarNuevaReservaDueno(String negocioId, Reserva reserva);
  
  /// Notificar recordatorio de reserva (X horas antes)
  Future<void> notificarRecordatorioReserva(String clienteId, Reserva reserva);
  
  /// Notificar cambios en horarios del negocio
  Future<void> notificarCambioHorarios(String negocioId, String mensaje);
}
