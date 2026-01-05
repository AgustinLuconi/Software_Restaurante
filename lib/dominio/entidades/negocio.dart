class Negocio {
  final String id;
  final String nombre;
  final String nombreResponsable;
  final String email;
  final String telefono;
  final String direccion;
  final String descripcion;
  final String especialidad;
  final int minHorasParaCancelar;
  final int maxDiasAnticipacionReserva;
  final int duracionPromedioMinutos;

  Negocio({
    required this.id,
    required this.nombre,
    required this.nombreResponsable,
    required this.email,
    required this.telefono,
    required this.direccion,
    this.descripcion = '',
    this.especialidad = '',
    this.minHorasParaCancelar = 24,
    this.maxDiasAnticipacionReserva = 14,
    this.duracionPromedioMinutos = 60,
  });

  Negocio copyWith({
    String? id,
    String? nombre,
    String? nombreResponsable,
    String? email,
    String? telefono,
    String? direccion,
    String? descripcion,
    String? especialidad,
    int? minHorasParaCancelar,
    int? maxDiasAnticipacionReserva,
    int? duracionPromedioMinutos,
  }) {
    return Negocio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nombreResponsable: nombreResponsable ?? this.nombreResponsable,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      descripcion: descripcion ?? this.descripcion,
      especialidad: especialidad ?? this.especialidad,
      minHorasParaCancelar: minHorasParaCancelar ?? this.minHorasParaCancelar,
      maxDiasAnticipacionReserva: maxDiasAnticipacionReserva ?? this.maxDiasAnticipacionReserva,
      duracionPromedioMinutos: duracionPromedioMinutos ?? this.duracionPromedioMinutos,
    );
  }
}
