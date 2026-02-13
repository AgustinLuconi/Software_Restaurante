import '../entidades/zona.dart';

/// Repositorio para gestionar las zonas de un restaurante
abstract class ZonaRepositorio {
  /// Obtiene todas las zonas de un negocio específico
  Future<List<Zona>> obtenerZonasPorNegocio(String negocioId);

  /// Crea una nueva zona para un negocio
  Future<Zona?> crearZona(Zona zona);

  /// Actualiza una zona existente
  Future<bool> actualizarZona(Zona zona);

  /// Elimina una zona
  /// Debe validar que no haya mesas asignadas a esta zona antes de eliminar
  Future<bool> eliminarZona(String zonaId);

  /// Verifica si una zona tiene mesas asignadas
  Future<bool> tieneMesasAsignadas(String zonaId);
}
