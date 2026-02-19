class Mesa {
	final String id;
	final String nombre;
	final int capacidad;
	final String negocioId;
	final String zona;

	Mesa({
		required this.id,
		required this.nombre,
		required this.capacidad,
		required this.negocioId,
		this.zona = 'Salón',
	});

	bool puedeAcomodar(int numeroPersonas) {
		// La mesa DEBE tener capacidad mayor o igual al número de personas
		if (capacidad < numeroPersonas) {
			return false; // Mesa muy chica, no alcanza
		}
		
		// La mesa NO puede tener más de 3 lugares extra
		// (evita desperdiciar mesas grandes para grupos pequeños)
		if (capacidad > numeroPersonas + 3) {
			return false; // Mesa muy grande, diferencia mayor a 3
		}
		
		// La mesa es adecuada: capacidad >= numeroPersonas Y capacidad <= numeroPersonas + 3
		return true;
	}

	Mesa copyWith({
		String? id,
		String? nombre,
		int? capacidad,
		String? negocioId,
		String? zona,
	}) {
		return Mesa(
			id: id ?? this.id,
			nombre: nombre ?? this.nombre,
			capacidad: capacidad ?? this.capacidad,
			negocioId: negocioId ?? this.negocioId,
			zona: zona ?? this.zona,
		);
	}
}
