class Negocio {
  final String id;
  final String nombre;
  final String nombreResponsable;
  final String email;
  final String telefono;
  final String direccion;
  final String descripcion;
  final String especialidad;
  final String icono; // sailing, restaurant, local_fire_department, etc.
  
  // Configuración de Tiempos
  final int minHorasParaCancelar;
  final int maxDiasAnticipacionReserva;
  final int duracionPromedioMinutos;
  // Estado
  final bool telefonoVerificado;

  Negocio({
    required this.id,
    required this.nombre,
    required this.nombreResponsable,
    required this.email,
    required this.telefono,
    required this.direccion,
    this.descripcion = '',
    this.especialidad = '',
    this.icono = 'restaurant',
    this.minHorasParaCancelar = 24,
    this.maxDiasAnticipacionReserva = 14,
    this.duracionPromedioMinutos = 60,
    this.telefonoVerificado = false,
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
    String? icono,
    int? minHorasParaCancelar,
    int? maxDiasAnticipacionReserva,
    int? duracionPromedioMinutos,
    bool? telefonoVerificado,
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
      icono: icono ?? this.icono,
      minHorasParaCancelar: minHorasParaCancelar ?? this.minHorasParaCancelar,
      maxDiasAnticipacionReserva: maxDiasAnticipacionReserva ?? this.maxDiasAnticipacionReserva,
      duracionPromedioMinutos: duracionPromedioMinutos ?? this.duracionPromedioMinutos,
      telefonoVerificado: telefonoVerificado ?? this.telefonoVerificado,
    );
  }
}
