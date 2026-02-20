import '../entidades/reserva.dart';

abstract class ReservaRepositorio {
	Future<Reserva> crearReserva(Reserva reserva);
	Future<List<Reserva>> obtenerReserva();
	Future<void> cancelarReserva(String reservaId);
	Future<void> actualizarReserva(Reserva reserva);
	Future<Reserva?> obtenerReservaPorId(String reservaId);
	
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

	/// Obtiene las reservas de un cliente (por teléfono) en un restaurante específico
	Future<List<Reserva>> obtenerReservasPorTelefonoYNegocio({
		required String telefonoCliente,
		required String negocioId,
	});
}
