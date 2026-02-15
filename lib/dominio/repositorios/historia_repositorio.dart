import '../entidades/historia_restaurante.dart';

abstract class HistoriaRepositorio {
  /// Obtiene la historia de un negocio por su ID
  Future<HistoriaRestaurante?> obtenerHistoria(String negocioId);

  /// Guarda o actualiza la historia de un negocio
  Future<bool> guardarHistoria(String negocioId, HistoriaRestaurante historia);
}
