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
	final int duracionMinutos;
	EstadoReserva estado;
	final String? contactoCliente; // Email o teléfono del cliente
	final String? nombreCliente; // Nombre opcional del cliente

	Reserva({
		required this.id,
		required this.clienteId,
		required this.mesaId,
		required this.fechaHora,
		required this.numeroPersonas,
		this.duracionMinutos = 60,
		this.estado = EstadoReserva.pendiente,
		this.contactoCliente,
		this.nombreCliente,
	});

	/// Hora de finalización calculada de la reserva
	DateTime get horaFin => fechaHora.add(Duration(minutes: duracionMinutos));

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

	Reserva copyWith({
		String? id,
		String? clienteId,
		String? mesaId,
		DateTime? fechaHora,
		int? numeroPersonas,
		int? duracionMinutos,
		EstadoReserva? estado,
		String? contactoCliente,
		String? nombreCliente,
	}) {
		return Reserva(
			id: id ?? this.id,
			clienteId: clienteId ?? this.clienteId,
			mesaId: mesaId ?? this.mesaId,
			fechaHora: fechaHora ?? this.fechaHora,
			numeroPersonas: numeroPersonas ?? this.numeroPersonas,
			duracionMinutos: duracionMinutos ?? this.duracionMinutos,
			estado: estado ?? this.estado,
			contactoCliente: contactoCliente ?? this.contactoCliente,
			nombreCliente: nombreCliente ?? this.nombreCliente,
		);
	}
}
