enum TipoNotificacion {
  reservaConfirmada,
  reservaCancelada,
  reservaPendiente,
  mesaDisponible,
  recordatorioReserva,
  cambioHorario,
  general,
}

class Notificacion {
  final String id;
  final String usuarioId; // Puede ser clienteId o negocioId
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final DateTime fechaCreacion;
  bool leida;
  final String? reservaId; // Referencia opcional a una reserva
  final String? negocioId; // Referencia opcional a un negocio

  Notificacion({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fechaCreacion,
    this.leida = false,
    this.reservaId,
    this.negocioId,
  });

  void marcarComoLeida() {
    leida = true;
  }

  Notificacion copyWith({
    String? id,
    String? usuarioId,
    String? titulo,
    String? mensaje,
    TipoNotificacion? tipo,
    DateTime? fechaCreacion,
    bool? leida,
    String? reservaId,
    String? negocioId,
  }) {
    return Notificacion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      leida: leida ?? this.leida,
      reservaId: reservaId ?? this.reservaId,
      negocioId: negocioId ?? this.negocioId,
    );
  }
}
