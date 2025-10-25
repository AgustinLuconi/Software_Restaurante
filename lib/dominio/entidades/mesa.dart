class Mesa {
	final String id;
	final String nombre;
	final int capacidad;
	final String negocioId;

	Mesa({
		required this.id,
		required this.nombre,
		required this.capacidad,
		required this.negocioId,
	});

	bool puedeAcomodar(int numeroPersonas) {
		return numeroPersonas <= capacidad;
	}

	Mesa copyWith({
		String? id,
		String? nombre,
		int? capacidad,
		String? negocioId,
	}) {
		return Mesa(
			id: id ?? this.id,
			nombre: nombre ?? this.nombre,
			capacidad: capacidad ?? this.capacidad,
			negocioId: negocioId ?? this.negocioId,
		);
	}
}
