enum EstadoReserva {
	pendiente,
	confirmada,
	cancelada,
}

class Reserva {
	final String id;
	final String mesaId;
	final DateTime fechaHora;
	final int numeroPersonas;
	final int duracionMinutos;
	EstadoReserva estado;
	final String? contactoCliente; // Email del cliente para notificaciones
	final String? nombreCliente; // Nombre opcional del cliente
	final String? telefonoCliente; // Teléfono verificado del cliente
	final String? negocioId; // ID del restaurante donde se hizo la reserva

	Reserva({
		required this.id,
		required this.mesaId,
		required this.fechaHora,
		required this.numeroPersonas,
		this.duracionMinutos = 60,
		this.estado = EstadoReserva.pendiente,
		this.contactoCliente,
		this.nombreCliente,
		this.telefonoCliente,
		this.negocioId,
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

	Reserva copyWith({
		String? id,
		String? mesaId,
		DateTime? fechaHora,
		int? numeroPersonas,
		int? duracionMinutos,
		EstadoReserva? estado,
		String? contactoCliente,
		String? nombreCliente,
		String? telefonoCliente,
		String? negocioId,
	}) {
		return Reserva(
			id: id ?? this.id,
			mesaId: mesaId ?? this.mesaId,
			fechaHora: fechaHora ?? this.fechaHora,
			numeroPersonas: numeroPersonas ?? this.numeroPersonas,
			duracionMinutos: duracionMinutos ?? this.duracionMinutos,
			estado: estado ?? this.estado,
			contactoCliente: contactoCliente ?? this.contactoCliente,
			nombreCliente: nombreCliente ?? this.nombreCliente,
			telefonoCliente: telefonoCliente ?? this.telefonoCliente,
			negocioId: negocioId ?? this.negocioId,
		);
	}
}
