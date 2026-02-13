import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../dominio/utilidades/telefono_utils.dart';

/// Servicio de autenticación con Firebase
class ServicioAutenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Solo inicializar GoogleSignIn en plataformas móviles/desktop
  GoogleSignIn? _googleSignIn;
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  /// Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual
  User? get usuarioActual => _auth.currentUser;

  /// Verificar si hay un usuario autenticado
  bool get estaAutenticado => _auth.currentUser != null;

  /// Verificar si el email está verificado
  bool get emailVerificado => _auth.currentUser?.emailVerified ?? false;

  // ============================================================
  // REGISTRO Y LOGIN
  // ============================================================

  /// Registrar usuario con email y contraseña
  /// Envía automáticamente email de verificación
  Future<UserCredential?> registrarConEmail({
    required String email,
    required String password,
    String? urlRedireccion,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enviar email de verificación automáticamente
      if (userCredential.user != null) {
        await enviarEmailVerificacion(urlRedireccion: urlRedireccion);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<UserCredential?> iniciarSesionConEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  /// Iniciar sesión con Google
  Future<UserCredential?> iniciarSesionConGoogle() async {
    if (kIsWeb) {
      // En WEB: Usar signInWithPopup directamente con Firebase
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // IMPORTANTE: Forzar selector de cuentas
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      return await _auth.signInWithPopup(googleProvider);
    } else {
      // En móvil/desktop: Usar google_sign_in package
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    }
  }

  /// Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
  }

  // ============================================================
  // VERIFICACIÓN DE EMAIL
  // ============================================================

  /// Enviar email de verificación al usuario actual
  Future<void> enviarEmailVerificacion({String? urlRedireccion}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: urlRedireccion ?? 'https://software-restaurante-59030.web.app',
          handleCodeInApp: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  /// Recargar usuario para verificar si ya verificó su email
  Future<bool> recargarUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ============================================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ============================================================

  /// Enviar email para restablecer contraseña
  Future<void> enviarEmailRecuperacion({
    required String email,
    String? urlRedireccion,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: urlRedireccion ?? 'https://software-restaurante-59030.web.app',
          handleCodeInApp: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  // ============================================================
  // CAMBIO DE EMAIL
  // ============================================================

  /// Cambiar email del usuario (requiere reautenticación)
  Future<void> cambiarEmail({
    required String nuevoEmail,
    required String passwordActual,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      // Reautenticar primero
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordActual,
      );
      await user.reauthenticateWithCredential(credential);

      // Enviar email de verificación al nuevo correo (Firebase 4.x+)
      await user.verifyBeforeUpdateEmail(nuevoEmail);
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  // ============================================================
  // CAMBIO DE CONTRASEÑA
  // ============================================================

  /// Cambiar contraseña del usuario (requiere reautenticación)
  Future<void> cambiarPassword({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      // Reautenticar primero
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordActual,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(passwordNueva);
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  // ============================================================
  // INFORMACIÓN DEL USUARIO
  // ============================================================

  /// Obtener información del usuario
  Map<String, dynamic>? obtenerInfoUsuario() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'nombre': user.displayName,
      'foto': user.photoURL,
      'emailVerificado': user.emailVerified,
      'esGoogle': user.providerData.any((p) => p.providerId == 'google.com'),
    };
  }

  /// Verificar si el usuario inició con Google
  bool get esLoginGoogle {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  /// Verificar si el teléfono está verificado
  bool get telefonoVerificado {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.phoneNumber != null && user.phoneNumber!.isNotEmpty;
  }

  /// Obtener teléfono verificado
  String? get telefonoVerificadoNumero => _auth.currentUser?.phoneNumber;

  // ============================================================
  // VERIFICACIÓN DE TELÉFONO
  // ============================================================

  // Almacena el verificationId para usarlo al verificar el código
  String? _verificationId;
  int? _resendToken;

  /// Enviar código SMS de verificación
  /// Retorna true si se envió correctamente
  Future<bool> enviarCodigoSMS({
    required String numeroTelefono,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onAutoVerified,
  }) async {
    try {
      // Formatear número (asegurar formato E.164)
      final phoneNumber = _formatearNumeroTelefono(numeroTelefono);

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Verificación automática (Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          // En Android, puede verificar automáticamente
          try {
            final user = _auth.currentUser;
            if (user != null) {
              await user.linkWithCredential(credential);
              onAutoVerified();
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
              mensaje = 'Límite de SMS excedido. Intenta más tarde';
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
          onCodeSent('Código enviado por SMS');
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
  Future<void> verificarCodigoSMS({required String codigo}) async {
    if (_verificationId == null) {
      throw Exception('Primero debes solicitar el código SMS');
    }

    try {
      // Crear credencial con el código
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: codigo,
      );

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Vincular teléfono a la cuenta existente
      await user.linkWithCredential(credential);

      // Limpiar verificationId
      _verificationId = null;
      _resendToken = null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          throw Exception('Código incorrecto. Verifica e intenta nuevamente');
        case 'credential-already-in-use':
          throw Exception('Este número ya está vinculado a otra cuenta');
        case 'invalid-verification-id':
          throw Exception('La verificación expiró. Solicita un nuevo código');
        case 'session-expired':
          throw Exception('La sesión expiró. Solicita un nuevo código');
        default:
          throw Exception('Error: ${e.message}');
      }
    }
  }

  /// Desvincular teléfono de la cuenta
  Future<void> desvincularTelefono() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      await user.unlink('phone');
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  /// Formatear número de teléfono a formato E.164
  /// Ejemplo: "11 1234-5678" → "+5491112345678"
  String _formatearNumeroTelefono(String numero) => TelefonoUtils.normalizar(numero);

  /// Validar formato de teléfono argentino
  Map<String, dynamic> validarTelefonoArgentino(String telefono) => TelefonoUtils.validar(telefono);

  // ============================================================
  // MANEJO DE ERRORES
  // ============================================================

  /// Convierte errores de Firebase a mensajes amigables
  Exception _manejarError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('Este correo ya está registrado');
      case 'weak-password':
        return Exception('La contraseña debe tener al menos 6 caracteres');
      case 'invalid-email':
        return Exception('El correo electrónico no es válido');
      case 'user-not-found':
        return Exception('No existe una cuenta con este correo');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'requires-recent-login':
        return Exception('Por seguridad, inicia sesión nuevamente');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intenta más tarde');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada');
      case 'operation-not-allowed':
        return Exception('Operación no permitida');
      default:
        return Exception('Error: ${e.message}');
    }
  }
}
