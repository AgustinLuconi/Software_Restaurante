import '../entidades/codigo_verificacion.dart';

abstract class CodigoVerificacionRepositorio {
  /// Generar y guardar un nuevo código de verificación
  Future<CodigoVerificacion> generarCodigo({
    required String contacto,
    String? reservaId,
  });
  
  /// Verificar si un código es válido
  Future<bool> verificarCodigo({
    required String contacto,
    required String codigo,
  });
  
  /// Obtener código por contacto
  Future<CodigoVerificacion?> obtenerCodigoPorContacto(String contacto);
  
  /// Marcar código como utilizado
  Future<bool> marcarComoUtilizado(String codigoId);
  
  /// Limpiar códigos expirados
  Future<void> limpiarCodigosExpirados();
}
