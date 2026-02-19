/// Representa un intervalo de horario de apertura
class IntervaloHorario {
  final int horaInicio; // 0-23
  final int minutoInicio; // 0-59
  final int horaFin; // 0-23
  final int minutoFin; // 0-59

  IntervaloHorario({
    required this.horaInicio,
    required this.minutoInicio,
    required this.horaFin,
    required this.minutoFin,
  });

  /// Verifica si una hora específica está dentro de este intervalo
  bool contieneHora(int hora, int minuto) {
    final minutosTotales = hora * 60 + minuto;
    final minutosInicio = horaInicio * 60 + minutoInicio;
    int minutosFin = horaFin * 60 + minutoFin;
    
    // Si el horario cruza la medianoche
    if (minutosFin < minutosInicio || (minutosFin == minutosInicio && minutosFin == 0)) {
       minutosFin += 24 * 60;
       
       // Si la hora a consultar también está pasada la medianoche pero es menor al inicio
       if (minutosTotales < minutosInicio) {
          final adjustedMinutosTotales = minutosTotales + 24 * 60;
          return adjustedMinutosTotales >= minutosInicio && adjustedMinutosTotales < minutosFin;
       }
    }
    
    return minutosTotales >= minutosInicio && minutosTotales < minutosFin;
  }

  @override
  String toString() {
    return '${horaInicio.toString().padLeft(2, '0')}:${minutoInicio.toString().padLeft(2, '0')} - ${horaFin.toString().padLeft(2, '0')}:${minutoFin.toString().padLeft(2, '0')}';
  }
}

/// Representa los horarios de apertura de un día específico
class HorarioDia {
  final String nombreDia; // Lunes, Martes, etc.
  final bool cerrado;
  final List<IntervaloHorario> intervalos; // Puede tener múltiples intervalos (ej: almuerzo y cena)

  HorarioDia({
    required this.nombreDia,
    this.cerrado = false,
    this.intervalos = const [],
  });

  /// Verifica si el negocio está abierto a una hora específica
  bool estaAbierto(int hora, int minuto) {
    if (cerrado || intervalos.isEmpty) return false;
    
    return intervalos.any((intervalo) => intervalo.contieneHora(hora, minuto));
  }

  @override
  String toString() {
    if (cerrado) return '$nombreDia: Cerrado';
    if (intervalos.isEmpty) return '$nombreDia: Sin horarios definidos';
    return '$nombreDia: ${intervalos.map((i) => i.toString()).join(' / ')}';
  }
}

/// Representa el horario completo del negocio
class HorarioApertura {
  final String negocioId;
  final List<HorarioDia> horariosSemanal;

  HorarioApertura({
    required this.negocioId,
    required this.horariosSemanal,
  });

  /// Verifica si el negocio está abierto en una fecha y hora específica
  bool estaAbiertoEn(DateTime fecha) {
    // 1 = Lunes, 7 = Domingo
    final diaSemana = fecha.weekday;
    
    if (diaSemana < 1 || diaSemana > 7) return false;
    
    // Buscar el horario del día correspondiente
    final horarioDia = horariosSemanal.firstWhere(
      (h) => _obtenerNumeroDia(h.nombreDia) == diaSemana,
      orElse: () => HorarioDia(nombreDia: '', cerrado: true),
    );
    
    return horarioDia.estaAbierto(fecha.hour, fecha.minute);
  }

  /// Obtiene el mensaje de error cuando el negocio está cerrado
  String obtenerMensajeError(DateTime fecha) {
    final diaSemana = fecha.weekday;
    final horarioDia = horariosSemanal.firstWhere(
      (h) => _obtenerNumeroDia(h.nombreDia) == diaSemana,
      orElse: () => HorarioDia(nombreDia: '', cerrado: true),
    );
    
    if (horarioDia.cerrado) {
      return 'El restaurante está cerrado los ${horarioDia.nombreDia}s.';
    }
    
    if (horarioDia.intervalos.isEmpty) {
      return 'No hay horarios disponibles para ${horarioDia.nombreDia}.';
    }
    
    final horariosStr = horarioDia.intervalos.map((i) => i.toString()).join(' y ');
    return 'El horario seleccionado (${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}) está fuera del horario de atención.\n\n${horarioDia.nombreDia}: $horariosStr';
  }

  /// Convierte el nombre del día a número (1-7)
  int _obtenerNumeroDia(String nombreDia) {
    switch (nombreDia.toLowerCase()) {
      case 'lunes':
        return 1;
      case 'martes':
        return 2;
      case 'miércoles':
      case 'miercoles':
        return 3;
      case 'jueves':
        return 4;
      case 'viernes':
        return 5;
      case 'sábado':
      case 'sabado':
        return 6;
      case 'domingo':
        return 7;
      default:
        return 0;
    }
  }
}
