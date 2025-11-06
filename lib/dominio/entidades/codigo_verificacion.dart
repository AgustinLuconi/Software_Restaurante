class CodigoVerificacion {
  final String id;
  final String contacto; // email o teléfono
  final String codigo;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;
  bool utilizado;
  final String? reservaId; // Reserva asociada

  CodigoVerificacion({
    required this.id,
    required this.contacto,
    required this.codigo,
    required this.fechaCreacion,
    required this.fechaExpiracion,
    this.utilizado = false,
    this.reservaId,
  });

  bool estaVigente() {
    return !utilizado && DateTime.now().isBefore(fechaExpiracion);
  }

  void marcarComoUtilizado() {
    utilizado = true;
  }

  CodigoVerificacion copyWith({
    String? id,
    String? contacto,
    String? codigo,
    DateTime? fechaCreacion,
    DateTime? fechaExpiracion,
    bool? utilizado,
    String? reservaId,
  }) {
    return CodigoVerificacion(
      id: id ?? this.id,
      contacto: contacto ?? this.contacto,
      codigo: codigo ?? this.codigo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      utilizado: utilizado ?? this.utilizado,
      reservaId: reservaId ?? this.reservaId,
    );
  }
}
