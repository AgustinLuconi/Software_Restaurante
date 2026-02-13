import 'package:cloud_firestore/cloud_firestore.dart';
import '../dominio/entidades/zona.dart';
import '../dominio/repositorios/zona_repositorio.dart';

class AdaptadorFirestoreZona implements ZonaRepositorio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _coleccionZonas = 'zonas';
  final String _coleccionMesas = 'mesas';

  @override
  Future<List<Zona>> obtenerZonasPorNegocio(String negocioId) async {
    try {
      print('🔍 Buscando zonas para negocio: $negocioId');

      final querySnapshot =
          await _firestore
              .collection(_coleccionZonas)
              .where('negocioId', isEqualTo: negocioId)
              .get();

      final zonas =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Zona(
              id: doc.id,
              nombre: data['nombre'] ?? '',
              descripcion: data['descripcion'] ?? '',
              negocioId: data['negocioId'] ?? '',
              colorHex: data['colorHex'],
            );
          }).toList();

      // Ordenar alfabéticamente
      zonas.sort((a, b) => a.nombre.compareTo(b.nombre));

      print('📊 Zonas encontradas: ${zonas.length}');
      return zonas;
    } catch (e) {
      print('❌ Error obteniendo zonas: $e');
      return [];
    }
  }

  @override
  Future<Zona?> crearZona(Zona zona) async {
    try {
      print('➕ Creando zona: ${zona.nombre}');

      final docRef = await _firestore.collection(_coleccionZonas).add({
        'nombre': zona.nombre,
        'descripcion': zona.descripcion,
        'negocioId': zona.negocioId,
        'colorHex': zona.colorHex,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      print('✅ Zona creada con ID: ${docRef.id}');

      return zona.copyWith(id: docRef.id);
    } catch (e) {
      print('❌ Error creando zona: $e');
      return null;
    }
  }

  @override
  Future<bool> actualizarZona(Zona zona) async {
    try {
      print('🔄 Actualizando zona: ${zona.id}');

      await _firestore.collection(_coleccionZonas).doc(zona.id).update({
        'nombre': zona.nombre,
        'descripcion': zona.descripcion,
        'colorHex': zona.colorHex,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });

      print('✅ Zona actualizada correctamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando zona: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarZona(String zonaId) async {
    try {
      print('🗑️ Eliminando zona: $zonaId');

      // Primero verificar si tiene mesas asignadas
      final tieneMesas = await tieneMesasAsignadas(zonaId);
      if (tieneMesas) {
        print('⚠️ No se puede eliminar: hay mesas asignadas a esta zona');
        return false;
      }

      await _firestore.collection(_coleccionZonas).doc(zonaId).delete();

      print('✅ Zona eliminada correctamente');
      return true;
    } catch (e) {
      print('❌ Error eliminando zona: $e');
      return false;
    }
  }

  @override
  Future<bool> tieneMesasAsignadas(String zonaId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_coleccionMesas)
              .where('zonaId', isEqualTo: zonaId)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando mesas asignadas: $e');
      return true; // En caso de error, asumir que sí tiene para evitar eliminación accidental
    }
  }

  /// Crea las zonas iniciales para un nuevo negocio
  Future<void> crearZonasIniciales(String negocioId) async {
    try {
      print('🏗️ Creando zonas iniciales para negocio: $negocioId');

      final zonasIniciales = Zona.zonasIniciales(negocioId);

      for (final zona in zonasIniciales) {
        await crearZona(zona);
      }

      print('✅ Zonas iniciales creadas correctamente');
    } catch (e) {
      print('❌ Error creando zonas iniciales: $e');
    }
  }
}
