import '../entidades/horario_apertura.dart';

abstract class HorarioAperturaRepositorio {
  /// Obtiene el horario de apertura de un negocio
  Future<HorarioApertura?> obtenerHorarioPorNegocio(String negocioId);
  
  /// Verifica si un negocio está abierto en una fecha y hora específica
  Future<bool> estaAbiertoEn(String negocioId, DateTime fecha);
  
  /// Obtiene el mensaje de error cuando el negocio está cerrado
  Future<String> obtenerMensajeHorarioCerrado(String negocioId, DateTime fecha);
  
  /// Obtiene los intervalos de horarios disponibles para una fecha específica
  Future<List<String>> obtenerIntervalosDisponibles(String negocioId, DateTime fecha, {int intervaloMinutos = 60});

  /// Guarda o actualiza el horario de un negocio
  Future<bool> guardarHorario(HorarioApertura horario);

  /// Convierte HorarioApertura a Map<String, String> para mostrar en UI
  /// Ejemplo: {'lunes': 'Cerrado', 'miercoles': '12:00 - 15:30 / 20:00 - 23:30'}
  Map<String, String> horarioAMapString(HorarioApertura horario);

  /// Convierte un Map<String, String> del editor a HorarioApertura
  HorarioApertura mapStringAHorario(String negocioId, Map<String, String> mapa);
}
