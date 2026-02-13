import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Servicio de verificación para clientes (sin login permanente)
/// Maneja verificación por SMS y almacenamiento local de reservas
class ServicioVerificacionCliente {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Almacena el verificationId para usarlo al verificar el código
  String? _verificationId;
  int? _resendToken;
  
  // Para almacenar el ConfirmationResult en web
  ConfirmationResult? _confirmationResult;
  
  // RecaptchaVerifier para poder limpiarlo después
  RecaptchaVerifier? _recaptchaVerifier;

  // ============================================================
  // VERIFICACIÓN SMS
  // ============================================================

  /// Enviar código SMS de verificación
  Future<bool> enviarCodigoSMS({
    required String telefono,
    required Function(String) onCodigoEnviado,
    required Function(String) onError,
    required Function(String) onVerificacionAutomatica,
  }) async {
    try {
      final telefonoFormateado = normalizarTelefono(telefono);

      // En web, usar signInWithPhoneNumber con RecaptchaVerifier
      if (kIsWeb) {
        try {
          print('📱 Enviando SMS a: $telefonoFormateado');
          
          // Limpiar cualquier recaptcha anterior
          _limpiarRecaptcha();
          
          // Crear RecaptchaVerifier invisible (sin container = modal automático)
          _recaptchaVerifier = RecaptchaVerifier(
            auth: FirebaseAuthPlatform.instance,
            // Sin container = reCAPTCHA invisible
          );
          
          // signInWithPhoneNumber con el verifier
          _confirmationResult = await _auth.signInWithPhoneNumber(
            telefonoFormateado,
            _recaptchaVerifier,
          );
          
          // Guardar el verificationId para verificar después
          _verificationId = _confirmationResult!.verificationId;
          print('✅ SMS enviado, verificationId: ${_verificationId?.substring(0, 10)}...');
          onCodigoEnviado('Código enviado por SMS');
          return true;
        } catch (e) {
          print('❌ Error enviando SMS: $e');
          
          // Limpiar recaptcha en caso de error
          _limpiarRecaptcha();
          
          // Manejar errores específicos
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'invalid-phone-number':
                onError('Número de teléfono inválido. Usa formato: +54 9 2622 123456');
                break;
              case 'too-many-requests':
                onError('Demasiados intentos. Intenta más tarde');
                break;
              case 'quota-exceeded':
                onError('Límite de SMS excedido. Contacta al administrador');
                break;
              case 'captcha-check-failed':
              case 'invalid-app-credential':
                onError('Error de verificación. Recarga la página e intenta de nuevo');
                break;
              default:
                onError('Error: ${e.message}');
            }
          } else {
            onError('Error al enviar SMS: $e');
          }
          return false;
        }
      }

      // En móvil, usar verifyPhoneNumber tradicional
      await _auth.verifyPhoneNumber(
        phoneNumber: telefonoFormateado,
        timeout: const Duration(seconds: 60),

        // Verificación automática (Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final result = await _auth.signInWithCredential(credential);
            if (result.user != null) {
              onVerificacionAutomatica(
                result.user!.phoneNumber ?? telefonoFormateado,
              );
            }
          } catch (e) {
            onError('Error en verificación automática: $e');
          }
        },

        // Error en verificación
        verificationFailed: (FirebaseAuthException e) {
          String mensaje;
          switch (e.code) {
            case 'invalid-phone-number':
              mensaje =
                  'Número de teléfono inválido. Usa formato: +54 9 11 1234-5678';
              break;
            case 'too-many-requests':
              mensaje = 'Demasiados intentos. Intenta más tarde';
              break;
            case 'quota-exceeded':
              mensaje = 'Límite de SMS excedido. Contacta al administrador';
              break;
            default:
              mensaje = 'Error: ${e.message}';
          }
          onError(mensaje);
        },

        // Código enviado exitosamente
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodigoEnviado('Código enviado por SMS');
        },

        // Tiempo de espera agotado
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },

        // Token para reenvío
        forceResendingToken: _resendToken,
      );

      return true;
    } catch (e) {
      onError('Error al enviar SMS: $e');
      return false;
    }
  }

  /// Verificar código SMS ingresado por el usuario
  /// Retorna el teléfono verificado si es correcto
  Future<String> verificarCodigoSMS({required String codigo}) async {
    if (_verificationId == null && _confirmationResult == null) {
      throw Exception('Primero debes solicitar el código SMS');
    }

    try {
      UserCredential result;
      
      // En web, usar confirmationResult si está disponible
      if (kIsWeb && _confirmationResult != null) {
        result = await _confirmationResult!.confirm(codigo);
      } else {
        // En móvil o fallback, usar credential tradicional
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: codigo,
        );
        result = await _auth.signInWithCredential(credential);
      }

      if (result.user == null) {
        throw Exception('Error al verificar código');
      }

      final telefonoVerificado = result.user!.phoneNumber ?? '';

      // Cerrar sesión temporal (el cliente no necesita estar logueado)
      await _auth.signOut();

      // Limpiar estado y recaptcha
      _limpiarEstado();

      return telefonoVerificado;
    } on FirebaseAuthException catch (e) {
      // Limpiar en caso de error también
      _limpiarEstado();
      
      switch (e.code) {
        case 'invalid-verification-code':
          throw Exception('Código incorrecto. Verifica e intenta nuevamente');
        case 'session-expired':
          throw Exception('El código ha expirado. Solicita uno nuevo');
        default:
          throw Exception('Error: ${e.message}');
      }
    }
  }

  /// Limpiar el widget de reCAPTCHA
  void _limpiarRecaptcha() {
    if (_recaptchaVerifier != null) {
      try {
        _recaptchaVerifier!.clear();
        print('🧹 reCAPTCHA limpiado');
      } catch (e) {
        print('⚠️ Error limpiando reCAPTCHA: $e');
      }
      _recaptchaVerifier = null;
    }
    
    // Limpiar también el contenedor HTML si existe
    if (kIsWeb) {
      try {
        final container = html.document.getElementById('recaptcha-container');
        if (container != null) {
          container.children.clear();
        }
      } catch (e) {
        print('⚠️ Error limpiando contenedor reCAPTCHA: $e');
      }
    }
  }
  
  /// Limpiar todo el estado de verificación
  void _limpiarEstado() {
    _verificationId = null;
    _resendToken = null;
    _confirmationResult = null;
    _limpiarRecaptcha();
  }
  
  /// Método público para limpiar el reCAPTCHA desde afuera si es necesario
  void limpiarRecaptcha() {
    _limpiarRecaptcha();
  }

  // ============================================================
  // NORMALIZACIÓN DE TELÉFONO
  // ============================================================

  /// Normalizar teléfono a formato E.164
  String normalizarTelefono(String telefono) {
    String normalizado = telefono.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!normalizado.startsWith('+')) {
      // Remover 0 inicial si existe
      if (normalizado.startsWith('0')) {
        normalizado = normalizado.substring(1);
      }
      // Si empieza con 15 (formato local), removerlo
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

  /// Validar formato de teléfono
  Map<String, dynamic> validarTelefono(String telefono) {
    try {
      final formateado = normalizarTelefono(telefono);

      if (formateado.length < 13 || formateado.length > 14) {
        return {'valido': false, 'error': 'Número de teléfono inválido'};
      }

      if (!formateado.startsWith('+54')) {
        return {'valido': false, 'error': 'Debe ser un número argentino (+54)'};
      }

      return {'valido': true, 'formateado': formateado};
    } catch (e) {
      return {'valido': false, 'error': 'Formato de teléfono inválido'};
    }
  }

  // ============================================================
  // ALMACENAMIENTO LOCAL DE RESERVAS
  // ============================================================

  static const String _keyReservas = 'reservas_cliente';

  /// Guardar reserva en localStorage
  void guardarReserva(Map<String, dynamic> reserva) {
    final reservas = obtenerTodasReservas();
    reservas.add(reserva);
    html.window.localStorage[_keyReservas] = jsonEncode(reservas);
  }

  /// Obtener todas las reservas del localStorage
  List<Map<String, dynamic>> obtenerTodasReservas() {
    final data = html.window.localStorage[_keyReservas];
    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> lista = jsonDecode(data);
      return lista.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener reservas por teléfono
  List<Map<String, dynamic>> obtenerReservasPorTelefono(String telefono) {
    final telefonoNormalizado = normalizarTelefono(telefono);
    final reservas = obtenerTodasReservas();

    return reservas
        .where((r) => r['clienteTelefono'] == telefonoNormalizado)
        .toList();
  }

  // ============================================================
  // SESIÓN TEMPORAL DEL CLIENTE
  // ============================================================

  static const String _keyClienteActual = 'cliente_actual';

  /// Guardar sesión temporal del cliente (30 días)
  void guardarSesionCliente(String telefono, String email) {
    final expiracion = DateTime.now().add(const Duration(days: 30));

    final sesion = {
      'telefono': normalizarTelefono(telefono),
      'email': email,
      'expiracion': expiracion.toIso8601String(),
    };

    html.window.localStorage[_keyClienteActual] = jsonEncode(sesion);
  }

  /// Obtener sesión del cliente si existe y no ha expirado
  Map<String, dynamic>? obtenerSesionCliente() {
    final data = html.window.localStorage[_keyClienteActual];
    if (data == null || data.isEmpty) {
      return null;
    }

    try {
      final sesion = Map<String, dynamic>.from(jsonDecode(data));
      final expiracion = DateTime.parse(sesion['expiracion']);

      if (DateTime.now().isAfter(expiracion)) {
        // Sesión expirada
        limpiarSesionCliente();
        return null;
      }

      return sesion;
    } catch (e) {
      return null;
    }
  }

  /// Limpiar sesión del cliente
  void limpiarSesionCliente() {
    html.window.localStorage.remove(_keyClienteActual);
  }
}
