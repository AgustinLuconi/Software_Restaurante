import '../entidades/reserva.dart';

abstract class ReservaRepositorio {
	Future<void> crearReserva(Reserva reserva);
	Future<List<Reserva>> obtenerReserva();
	Future<void> cancelarReserva(String reservaId);
	Future<Reserva?> obtenerReservaPorId(String reservaId);
	
	/// Obtiene las reservas activas (confirmadas o pendientes) para una mesa específica en una fecha y hora
	Future<List<Reserva>> obtenerReservasPorMesaYHorario({
		required String mesaId,
		required DateTime fecha,
		required DateTime hora,
	});
	
	/// Verifica si una mesa está disponible en un horario específico
	/// Considera intervalos de 1 hora para las reservas
	Future<bool> mesaDisponible({
		required String mesaId,
		required DateTime fecha,
		required DateTime hora,
	});
}
