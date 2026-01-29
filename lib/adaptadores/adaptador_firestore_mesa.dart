import 'package:cloud_firestore/cloud_firestore.dart';
import '../dominio/entidades/mesa.dart';
import '../dominio/repositorios/mesa_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

/// Adaptador de Firestore para el repositorio de mesas
class MesaRepositorioFirestore implements MesaRepositorio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReservaRepositorio _reservaRepositorio;
  
  MesaRepositorioFirestore({required ReservaRepositorio reservaRepositorio})
      : _reservaRepositorio = reservaRepositorio;

  /// Referencia a la colección de mesas
  CollectionReference<Map<String, dynamic>> get _mesasRef =>
      _firestore.collection('mesas');

  @override
  Future<List<Mesa>> obtenerMesas() async {
    try {
      final snapshot = await _mesasRef.orderBy('nombre').get();
      return snapshot.docs
          .map((doc) => _mapToMesa(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo mesas: $e');
      return [];
    }
  }

  @override
  Future<Mesa?> obtenerMesaPorId(String mesaId) async {
    try {
      final doc = await _mesasRef.doc(mesaId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _mapToMesa(doc.id, doc.data()!);
    } catch (e) {
      print('❌ Error obteniendo mesa por ID: $e');
      return null;
    }
  }

  @override
  Future<List<Mesa>> obtenerMesasDisponibles(
    DateTime fecha,
    DateTime hora,
    int numeroPersonas,
  ) async {
    try {
      final todasLasMesas = await obtenerMesas();
      final mesasDisponibles = <Mesa>[];

      for (final mesa in todasLasMesas) {
        if (!mesa.puedeAcomodar(numeroPersonas)) continue;

        final disponible = await _reservaRepositorio.mesaDisponible(
          mesaId: mesa.id,
          fecha: fecha,
          hora: hora,
          duracionMinutos: 60,
        );

        if (disponible) {
          mesasDisponibles.add(mesa);
        }
      }

      // Ordenar por capacidad (menor desperdicio primero)
      mesasDisponibles.sort((a, b) => a.capacidad.compareTo(b.capacidad));
      
      return mesasDisponibles;
    } catch (e) {
      print('❌ Error obteniendo mesas disponibles: $e');
      return [];
    }
  }

  @override
  Future<List<Mesa>> obtenerMesasPorNegocio(String negocioId) async {
    try {
      final snapshot = await _mesasRef
          .where('negocioId', isEqualTo: negocioId)
          .orderBy('nombre')
          .get();
      
      return snapshot.docs
          .map((doc) => _mapToMesa(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo mesas por negocio: $e');
      return [];
    }
  }

  @override
  Future<Mesa?> agregarMesa(Mesa mesa) async {
    try {
      final docRef = await _mesasRef.add(_mesaToMap(mesa));
      print('✅ Mesa agregada: ${docRef.id}');
      return mesa.copyWith(id: docRef.id);
    } catch (e) {
      print('❌ Error agregando mesa: $e');
      return null;
    }
  }

  @override
  Future<bool> actualizarMesa(Mesa mesa) async {
    try {
      await _mesasRef.doc(mesa.id).update(_mesaToMap(mesa));
      print('✅ Mesa actualizada: ${mesa.id}');
      return true;
    } catch (e) {
      print('❌ Error actualizando mesa: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminarMesa(String mesaId) async {
    try {
      await _mesasRef.doc(mesaId).delete();
      print('✅ Mesa eliminada: $mesaId');
      return true;
    } catch (e) {
      print('❌ Error eliminando mesa: $e');
      return false;
    }
  }

  @override
  Future<List<ZonaMesa>> obtenerZonasDisponibles(String negocioId) async {
    try {
      final mesas = await obtenerMesasPorNegocio(negocioId);
      final zonas = mesas.map((m) => m.zona).toSet().toList();
      return zonas;
    } catch (e) {
      print('❌ Error obteniendo zonas: $e');
      return [];
    }
  }

  @override
  Future<Mesa?> buscarMesaDisponibleEnZona({
    required ZonaMesa zona,
    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
    required String negocioId,
  }) async {
    try {
      final mesas = await obtenerMesasPorNegocio(negocioId);
      
      // Filtrar mesas de la zona que puedan acomodar al grupo
      final mesasZona = mesas
          .where((m) => m.zona == zona && m.puedeAcomodar(numeroPersonas))
          .toList();

      // Ordenar por capacidad (priorizar las que mejor se ajustan)
      mesasZona.sort((a, b) => a.capacidad.compareTo(b.capacidad));

      // Buscar la primera mesa disponible
      for (final mesa in mesasZona) {
        final disponible = await _reservaRepositorio.mesaDisponible(
          mesaId: mesa.id,
          fecha: fecha,
          hora: hora,
          duracionMinutos: 60,
        );

        if (disponible) {
          return mesa;
        }
      }

      return null;
    } catch (e) {
      print('❌ Error buscando mesa en zona: $e');
      return null;
    }
  }

  // ============================================================
  // MÉTODOS DE CONVERSIÓN
  // ============================================================

  Map<String, dynamic> _mesaToMap(Mesa mesa) {
    return {
      'nombre': mesa.nombre,
      'capacidad': mesa.capacidad,
      'negocioId': mesa.negocioId,
      'zona': mesa.zona.name,
    };
  }

  Mesa _mapToMesa(String id, Map<String, dynamic> data) {
    return Mesa(
      id: id,
      nombre: data['nombre'] ?? '',
      capacidad: data['capacidad'] ?? 2,
      negocioId: data['negocioId'] ?? '',
      zona: _stringToZona(data['zona']),
    );
  }

  ZonaMesa _stringToZona(String? zona) {
    switch (zona) {
      case 'terraza':
        return ZonaMesa.terraza;
      case 'salon':
        return ZonaMesa.salon;
      case 'jardin':
        return ZonaMesa.jardin;
      case 'barraBar':
        return ZonaMesa.barraBar;
      case 'vip':
        return ZonaMesa.vip;
      default:
        return ZonaMesa.salon;
    }
  }
}
