import '../entidades/horario_apertura.dart';

abstract class HorarioAperturaRepositorio {
  /// Obtiene el horario de apertura de un negocio
  Future<HorarioApertura?> obtenerHorarioPorNegocio(String negocioId);
  
  /// Verifica si un negocio está abierto en una fecha y hora específica
  Future<bool> estaAbiertoEn(String negocioId, DateTime fecha);
  
  /// Obtiene el mensaje de error cuando el negocio está cerrado
  Future<String> obtenerMensajeHorarioCerrado(String negocioId, DateTime fecha);
}
