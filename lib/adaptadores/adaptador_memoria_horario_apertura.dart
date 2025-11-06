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
}
