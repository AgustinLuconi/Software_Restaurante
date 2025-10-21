class Mesa {
	final String id;
	final String nombre;
	final int capacidad;

	Mesa({
		required this.id,
		required this.nombre,
		required this.capacidad,
	});

	bool puedeAcomodar(int numeroPersonas) {
		return numeroPersonas <= capacidad;
	}
}
