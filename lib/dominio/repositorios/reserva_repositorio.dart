import '../entidades/reserva.dart';

abstract class ReservaRepositorio {
	Future<void> crearReserva(Reserva reserva);
	Future<List<Reserva>> obtenerReserva();
	Future<void> cancelarReserva(String reservaId);
	Future<Reserva?> obtenerReservaPorId(String reservaId);
}
