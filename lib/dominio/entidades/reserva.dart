enum EstadoReserva {
	pendiente,
	confirmada,
	cancelada,
}

class Reserva {
	final String id;
	final String clienteId;
	final String mesaId;
	final DateTime fechaHora;
	final int numeroPersonas;
	EstadoReserva estado;
	final String? contactoCliente; // Email o teléfono del cliente
	final String? nombreCliente; // Nombre opcional del cliente

	Reserva({
		required this.id,
		required this.clienteId,
		required this.mesaId,
		required this.fechaHora,
		required this.numeroPersonas,
		this.estado = EstadoReserva.pendiente,
		this.contactoCliente,
		this.nombreCliente,
	});

	void confirmar() {
		if (estado == EstadoReserva.cancelada) {
			throw Exception('No se puede confirmar una reserva cancelada.');
		}
		if (estado == EstadoReserva.confirmada) {
			throw Exception('La reserva ya está confirmada.');
		}
		estado = EstadoReserva.confirmada;
	}

	void cancelar() {
		if (estado == EstadoReserva.cancelada) {
			throw Exception('La reserva ya está cancelada.');
		}
		estado = EstadoReserva.cancelada;
	}
}
