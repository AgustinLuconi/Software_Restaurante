class Restaurante {
	final String nombre;
	final String direccion;
	final String telefono;
	final int aforoMaximo;
	final DateTime horarioDeApertura;
	final DateTime horarioDeCierre;

	Restaurante({
		required this.nombre,
		required this.direccion,
		required this.telefono,
		required this.aforoMaximo,
		required this.horarioDeApertura,
		required this.horarioDeCierre,
	});
}
