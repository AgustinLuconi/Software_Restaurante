import '../entidades/reserva.dart';

abstract class ReservaRepositorio {
	Future<Reserva> crearReserva(Reserva reserva);
	Future<List<Reserva>> obtenerReserva();
	Future<void> cancelarReserva(String reservaId);
	Future<void> confirmarReserva(String reservaId);
	Future<Reserva?> obtenerReservaPorId(String reservaId);
	
	/// Obtiene reservas asociadas a un conjunto de mesas (para filtrar por negocio)
	Future<List<Reserva>> obtenerReservasPorMesaIds(List<String> mesaIds);

	/// Obtiene reservas de un cliente por su contacto (email o teléfono)
	Future<List<Reserva>> obtenerReservasPorContacto(String contactoCliente);

	/// Obtiene las reservas activas (confirmadas o pendientes) para una mesa específica en una fecha y hora
	Future<List<Reserva>> obtenerReservasPorMesaYHorario({
		required String mesaId,
		required DateTime fecha,
		required DateTime hora,
	});
	
	/// Verifica si una mesa está disponible en un horario específico
	/// Considera la duración de la reserva para detectar colisiones
	Future<bool> mesaDisponible({
		required String mesaId,
		required DateTime fecha,
		required DateTime hora,
		required int duracionMinutos,
	});
}
