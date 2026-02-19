import 'package:cloud_firestore/cloud_firestore.dart';
import '../dominio/entidades/negocio.dart';
import '../dominio/repositorios/negocio_repositorio.dart';

/// Adaptador de Firestore para el repositorio de negocios
class NegocioRepositorioFirestore implements NegocioRepositorio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referencia a la colección de negocios
  CollectionReference<Map<String, dynamic>> get _negociosRef =>
      _firestore.collection('negocios');

  @override
  Future<Negocio?> registrarNegocio({
    required String nombre,
    required String nombreResponsable,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  }) async {
    try {
      // Verificar si ya existe un negocio con ese email
      final existente = await obtenerNegocioPorEmail(email);
      if (existente != null) {
        print('⚠️ Ya existe un negocio con el email: $email');
        return null;
      }

      final data = {
        'nombre': nombre,
        'nombreResponsable': nombreResponsable,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'password': password, // En producción, hashear la contraseña
        'descripcion': '',
        'especialidad': '',
        'minHorasParaCancelar': 24,
        'maxDiasAnticipacionReserva': 14,
        'duracionPromedioMinutos': 60,
      };

      final docRef = await _negociosRef.add(data);
      print('✅ Negocio registrado: ${docRef.id}');
      
      return Negocio(
        id: docRef.id,
        nombre: nombre,
        nombreResponsable: nombreResponsable,
        email: email,
        telefono: telefono,
        direccion: direccion,
      );
    } catch (e) {
      print('❌ Error registrando negocio: $e');
      return null;
    }
  }

  @override
  Future<Negocio?> autenticarNegocio({
    required String email,
    required String password,
  }) async {
    try {
      final snapshot = await _negociosRef
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No existe negocio con email: $email');
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      // Verificar contraseña
      // NOTA: En producción, usar Firebase Auth o hash de contraseña
      if (data['password'] != password) {
        print('⚠️ Contraseña incorrecta para: $email');
        return null;
      }

      print('✅ Negocio autenticado: ${doc.id}');
      return _mapToNegocio(doc.id, data);
    } catch (e) {
      print('❌ Error autenticando negocio: $e');
      return null;
    }
  }

  @override
  Future<List<Negocio>> obtenerTodosLosNegocios() async {
    try {
      final snapshot = await _negociosRef.orderBy('nombre').get();
      return snapshot.docs
          .map((doc) => _mapToNegocio(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo negocios: $e');
      return [];
    }
  }

  @override
  Future<Negocio?> obtenerNegocioPorId(String negocioId) async {
    try {
      final doc = await _negociosRef.doc(negocioId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _mapToNegocio(doc.id, doc.data()!);
    } catch (e) {
      print('❌ Error obteniendo negocio por ID: $e');
      return null;
    }
  }

  @override
  Future<Negocio?> obtenerNegocioPorEmail(String email) async {
    try {
      final snapshot = await _negociosRef
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return _mapToNegocio(doc.id, doc.data());
    } catch (e) {
      print('❌ Error obteniendo negocio por email: $e');
      return null;
    }
  }

  @override
  Future<bool> actualizarNegocio(Negocio negocio) async {
    try {
      await _negociosRef.doc(negocio.id).update(_negocioToMap(negocio));
      print('✅ Negocio actualizado: ${negocio.id}');
      return true;
    } catch (e) {
      print('❌ Error actualizando negocio: $e');
      return false;
    }
  }

  @override
  Future<bool> actualizarEmail(String negocioId, String nuevoEmail) async {
    try {
      // Verificar que el nuevo email no esté en uso
      final existente = await obtenerNegocioPorEmail(nuevoEmail);
      if (existente != null && existente.id != negocioId) {
        print('⚠️ El email ya está en uso: $nuevoEmail');
        return false;
      }

      await _negociosRef.doc(negocioId).update({'email': nuevoEmail});
      print('✅ Email actualizado para negocio: $negocioId');
      return true;
    } catch (e) {
      print('❌ Error actualizando email: $e');
      return false;
    }
  }

  // ============================================================
  // MÉTODOS DE CONVERSIÓN
  // ============================================================

  @override
  Future<bool> actualizarPassword(String negocioId, String nuevaPassword) async {
    try {
      if (negocioId.isEmpty) {
        print('❌ Error: ID de negocio vacío para actualizar password');
        return false;
      }

      await _negociosRef.doc(negocioId).update({
        'password': nuevaPassword,
      });

      print('✅ Password actualizada en Firestore para: $negocioId');
      return true;
    } catch (e) {
      print('❌ Error actualizando password en Firestore: $e');
      return false;
    }
  }

  @override
  Future<bool> actualizarTelefono(String negocioId, String nuevoTelefono, {bool verificado = false}) async {
    try {
      if (negocioId.isEmpty) return false;

      await _negociosRef.doc(negocioId).update({
        'telefono': nuevoTelefono,
        'telefonoVerificado': verificado,
      });

      print('✅ Teléfono actualizado en Firestore: $nuevoTelefono (Verificado: $verificado)');
      return true;
    } catch (e) {
      print('❌ Error actualizando teléfono en Firestore: $e');
      return false;
    }
  }

  @override
  Future<bool> actualizarZonas(String negocioId, List<String> zonas) async {
    try {
      await _negociosRef.doc(negocioId).update({
        'zonas': zonas,
      });
      return true;
    } catch (e) {
      print('❌ Error actualizando zonas: $e');
      return false;
    }
  }

  Map<String, dynamic> _negocioToMap(Negocio negocio) {
    return {
      'nombre': negocio.nombre,
      'nombreResponsable': negocio.nombreResponsable,
      'email': negocio.email,
      'telefono': negocio.telefono,
      'direccion': negocio.direccion,
      'descripcion': negocio.descripcion,
      'especialidad': negocio.especialidad,
      'icono': negocio.icono,
      'minHorasParaCancelar': negocio.minHorasParaCancelar,
      'maxDiasAnticipacionReserva': negocio.maxDiasAnticipacionReserva,
      'duracionPromedioMinutos': negocio.duracionPromedioMinutos,
      'telefonoVerificado': negocio.telefonoVerificado,
      'zonas': negocio.zonas,
    };
  }

  Negocio _mapToNegocio(String id, Map<String, dynamic> data) {
    int safeInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    bool safeBool(dynamic value, bool defaultValue) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return defaultValue;
    }

    List<String> safeList(dynamic value, List<String> defaultValue) {
      if (value == null) return defaultValue;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return defaultValue;
    }

    return Negocio(
      id: id,
      nombre: data['nombre']?.toString() ?? '',
      nombreResponsable: data['nombreResponsable']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      telefono: data['telefono']?.toString() ?? '',
      direccion: data['direccion']?.toString() ?? '',
      descripcion: data['descripcion']?.toString() ?? '',
      especialidad: data['especialidad']?.toString() ?? '',
      icono: data['icono']?.toString() ?? 'restaurant',
      minHorasParaCancelar: safeInt(data['minHorasParaCancelar'], 24),
      maxDiasAnticipacionReserva: safeInt(data['maxDiasAnticipacionReserva'], 14),
      duracionPromedioMinutos: safeInt(data['duracionPromedioMinutos'], 60),
      telefonoVerificado: safeBool(data['telefonoVerificado'], false),
      zonas: safeList(data['zonas'], ['Salón', 'Terraza']),
    );
  }
}
