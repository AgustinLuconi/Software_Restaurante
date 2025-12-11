import '../dominio/entidades/horario_apertura.dart';
import '../dominio/repositorios/horario_apertura_repositorio.dart';

class HorarioAperturaRepositorioMemoria implements HorarioAperturaRepositorio {
  final Map<String, HorarioApertura> _horarios = {
    // Horario del restaurante Chiringuito
    'negocio_1': HorarioApertura.crearHorarioChiringuito(),
  };

  @override
  Future<HorarioApertura?> obtenerHorarioPorNegocio(String negocioId) async {
    return _horarios[negocioId];
  }

  @override
  Future<bool> estaAbiertoEn(String negocioId, DateTime fecha) async {
    final horario = _horarios[negocioId];
    if (horario == null) return false;
    
    return horario.estaAbiertoEn(fecha);
  }

  @override
  Future<String> obtenerMensajeHorarioCerrado(String negocioId, DateTime fecha) async {
    final horario = _horarios[negocioId];
    if (horario == null) {
      return 'No se encontraron horarios para este negocio.';
    }
    
    return horario.obtenerMensajeError(fecha);
  }

  @override
  Future<List<String>> obtenerIntervalosDisponibles(String negocioId, DateTime fecha) async {
    final horario = _horarios[negocioId];
    if (horario == null) return [];
    
    final diaSemana = fecha.weekday; // 1=lunes, 7=domingo
    
    // Buscar el horario del día correspondiente
    final horarioDia = horario.horariosSemanal.firstWhere(
      (h) => _obtenerNumeroDia(h.nombreDia) == diaSemana,
      orElse: () => HorarioDia(nombreDia: '', cerrado: true),
    );
    
    if (horarioDia.cerrado || horarioDia.intervalos.isEmpty) {
      return [];
    }
    
    final intervalos = <String>[];
    
    // Generar intervalos de 1 hora para cada período del día
    for (final intervalo in horarioDia.intervalos) {
      int horaInicio = intervalo.horaInicio;
      final horaFin = intervalo.horaFin;
      
      while (horaInicio < horaFin) {
        final horaInicioStr = horaInicio.toString().padLeft(2, '0');
        final horaSiguiente = horaInicio + 1;
        // Si la hora siguiente es 24, mostrarla como 00
        final horaSiguienteStr = horaSiguiente == 24 
            ? '00' 
            : horaSiguiente.toString().padLeft(2, '0');
        intervalos.add('$horaInicioStr:00 - $horaSiguienteStr:00');
        horaInicio++;
      }
    }
    
    return intervalos;
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
