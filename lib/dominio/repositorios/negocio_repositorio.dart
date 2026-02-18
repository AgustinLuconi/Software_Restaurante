import '../entidades/negocio.dart';

abstract class NegocioRepositorio {
  Future<Negocio?> registrarNegocio({
    required String nombre,
    required String nombreResponsable,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  });

  Future<Negocio?> autenticarNegocio({
    required String email,
    required String password,
  });

  Future<List<Negocio>> obtenerTodosLosNegocios();

  Future<Negocio?> obtenerNegocioPorId(String id);

  Future<Negocio?> obtenerNegocioPorEmail(String email);

  Future<bool> actualizarNegocio(Negocio negocio);

  /// Actualizar email del negocio
  Future<bool> actualizarEmail(String negocioId, String nuevoEmail);

  /// Actualizar el password del negocio (Backup o Legacy)
  Future<bool> actualizarPassword(String negocioId, String nuevaPassword);

  /// Actualizar el teléfono y su estado de verificación
  Future<bool> actualizarTelefono(String negocioId, String nuevoTelefono, {bool verificado = false});
}
