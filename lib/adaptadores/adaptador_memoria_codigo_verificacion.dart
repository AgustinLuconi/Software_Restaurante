import 'dart:math';
import '../dominio/entidades/codigo_verificacion.dart';
import '../dominio/repositorios/codigo_verificacion_repositorio.dart';

class CodigoVerificacionRepositorioMemoria implements CodigoVerificacionRepositorio {
  final List<CodigoVerificacion> _codigos = [];
  int _contadorId = 1;
  final Random _random = Random();

  @override
  Future<CodigoVerificacion> generarCodigo({
    required String contacto,
    String? reservaId,
  }) async {
    // Limpiar códigos anteriores del mismo contacto
    _codigos.removeWhere((c) => c.contacto == contacto);
    
    // Generar código de 6 dígitos
    final codigo = _generarCodigoNumerico(6);
    
    final ahora = DateTime.now();
    final expiracion = ahora.add(const Duration(minutes: 10)); // Expira en 10 minutos
    
    final nuevoCodigo = CodigoVerificacion(
      id: 'codigo_${_contadorId++}',
      contacto: contacto,
      codigo: codigo,
      fechaCreacion: ahora,
      fechaExpiracion: expiracion,
      utilizado: false,
      reservaId: reservaId,
    );
    
    _codigos.add(nuevoCodigo);
    
    // Simular envío de código (en producción sería SMS/Email real)
    print('📧 Código de verificación enviado a $contacto');
    print('🔑 Código: $codigo');
    print('⏰ Válido hasta: ${expiracion.hour}:${expiracion.minute}');
    print('---');
    
    return nuevoCodigo;
  }

  @override
  Future<bool> verificarCodigo({
    required String contacto,
    required String codigo,
  }) async {
    try {
      final codigoObj = _codigos.firstWhere(
        (c) => c.contacto == contacto && c.codigo == codigo,
      );
      
      if (codigoObj.estaVigente()) {
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CodigoVerificacion?> obtenerCodigoPorContacto(String contacto) async {
    try {
      return _codigos.firstWhere((c) => c.contacto == contacto && c.estaVigente());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> marcarComoUtilizado(String codigoId) async {
    try {
      final codigo = _codigos.firstWhere((c) => c.id == codigoId);
      codigo.marcarComoUtilizado();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> limpiarCodigosExpirados() async {
    final ahora = DateTime.now();
    _codigos.removeWhere((c) => ahora.isAfter(c.fechaExpiracion));
  }

  String _generarCodigoNumerico(int longitud) {
    String codigo = '';
    for (int i = 0; i < longitud; i++) {
      codigo += _random.nextInt(10).toString();
    }
    return codigo;
  }
}
