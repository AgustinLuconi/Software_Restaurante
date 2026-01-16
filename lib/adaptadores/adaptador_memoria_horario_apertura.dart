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
  Future<List<String>> obtenerIntervalosDisponibles(String negocioId, DateTime fecha, {int intervaloMinutos = 60}) async {
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
    
    // Generar intervalos según la duración configurada
    for (final intervalo in horarioDia.intervalos) {
      int minutoActual = intervalo.horaInicio * 60; // Convertir a minutos
      final minutoFin = intervalo.horaFin * 60;
      
      while (minutoActual < minutoFin) {
        final horaInicio = minutoActual ~/ 60;
        final minInicio = minutoActual % 60;
        
        final minutoSiguiente = minutoActual + intervaloMinutos;
        final horaSiguiente = minutoSiguiente ~/ 60;
        final minSiguiente = minutoSiguiente % 60;
        
        // Formatear horas y minutos
        final horaInicioStr = horaInicio.toString().padLeft(2, '0');
        final minInicioStr = minInicio.toString().padLeft(2, '0');
        final horaSiguienteStr = (horaSiguiente >= 24 ? horaSiguiente - 24 : horaSiguiente).toString().padLeft(2, '0');
        final minSiguienteStr = minSiguiente.toString().padLeft(2, '0');
        
        intervalos.add('$horaInicioStr:$minInicioStr - $horaSiguienteStr:$minSiguienteStr');
        minutoActual += intervaloMinutos;
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
