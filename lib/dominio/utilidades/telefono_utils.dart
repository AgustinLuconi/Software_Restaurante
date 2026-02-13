/// Utilidades compartidas para normalización y validación de teléfonos argentinos.
/// Usado por ServicioVerificacionCliente y ServicioAutenticacion.
class TelefonoUtils {
  TelefonoUtils._();

  /// Normalizar teléfono a formato E.164.
  /// Ejemplo: "11 1234-5678" → "+5491112345678"
  static String normalizar(String telefono) {
    String normalizado = telefono.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!normalizado.startsWith('+')) {
      // Remover 0 inicial si existe
      if (normalizado.startsWith('0')) {
        normalizado = normalizado.substring(1);
      }
      // Si empieza con 15 (formato local), removerlo y agregar 9
      if (normalizado.startsWith('15')) {
        normalizado = '9${normalizado.substring(2)}';
      }
      // Si no tiene el 9 después del código de área
      if (!normalizado.startsWith('9') && normalizado.length == 10) {
        normalizado = '9$normalizado';
      }
      // Agregar código de Argentina
      normalizado = '+54$normalizado';
    }

    return normalizado;
  }

  /// Validar formato de teléfono argentino.
  /// Retorna un mapa con 'valido', 'formateado' y opcionalmente 'error'.
  static Map<String, dynamic> validar(String telefono) {
    try {
      final formateado = normalizar(telefono);

      // Validar longitud (Argentina: +54 + 9 + 10 dígitos = 13-14 caracteres)
      if (formateado.length < 13 || formateado.length > 14) {
        return {
          'valido': false,
          'error': 'Número de teléfono inválido para Argentina',
        };
      }

      // Validar que empiece con +54
      if (!formateado.startsWith('+54')) {
        return {'valido': false, 'error': 'Debe ser un número argentino (+54)'};
      }

      return {
        'valido': true,
        'formateado': formateado,
        'nacional': formatoNacional(formateado),
      };
    } catch (e) {
      return {'valido': false, 'error': 'Formato de teléfono inválido'};
    }
  }

  /// Convierte E.164 a formato nacional legible.
  /// Ejemplo: "+5491112345678" → "011 15-1234-5678"
  static String formatoNacional(String e164) {
    if (e164.length < 13) return e164;
    final sinCodigo = e164.substring(3); // Quitar +54
    final tiene9 = sinCodigo.startsWith('9');
    final numero = tiene9 ? sinCodigo.substring(1) : sinCodigo;

    if (numero.length == 10) {
      final area = numero.substring(0, 2);
      final resto = numero.substring(2);
      return '0$area 15-${resto.substring(0, 4)}-${resto.substring(4)}';
    }
    return e164;
  }
}
