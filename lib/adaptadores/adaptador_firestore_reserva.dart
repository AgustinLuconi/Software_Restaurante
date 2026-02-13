import 'package:cloud_firestore/cloud_firestore.dart';
import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

/// Adaptador de Firestore para el repositorio de reservas
class ReservaRepositorioFirestore implements ReservaRepositorio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referencia a la colección de reservas
  CollectionReference<Map<String, dynamic>> get _reservasRef =>
      _firestore.collection('reservas');

  @override
  Future<Reserva> crearReserva(Reserva reserva) async {
    try {
      final docRef = await _reservasRef.add(_reservaToMap(reserva));
      print('✅ Reserva creada en Firestore: ${docRef.id}');
      return reserva.copyWith(id: docRef.id);
    } catch (e) {
      print('❌ Error creando reserva en Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<List<Reserva>> obtenerReserva() async {
    try {
      final snapshot =
          await _reservasRef.orderBy('fechaHora', descending: true).get();

      return snapshot.docs
          .map((doc) => _mapToReserva(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo reservas: $e');
      return [];
    }
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    try {
      await _reservasRef.doc(reservaId).update({
        'estado': 'cancelada',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Reserva cancelada: $reservaId');
    } catch (e) {
      print('❌ Error cancelando reserva: $e');
      rethrow;
    }
  }

  @override
  Future<void> confirmarReserva(String reservaId) async {
    try {
      await _reservasRef.doc(reservaId).update({
        'estado': 'confirmada',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Reserva confirmada: $reservaId');
    } catch (e) {
      print('❌ Error confirmando reserva: $e');
      rethrow;
    }
  }

  @override
  Future<Reserva?> obtenerReservaPorId(String reservaId) async {
    try {
      final doc = await _reservasRef.doc(reservaId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _mapToReserva(doc.id, doc.data()!);
    } catch (e) {
      print('❌ Error obteniendo reserva por ID: $e');
      return null;
    }
  }

  @override
  Future<List<Reserva>> obtenerReservasPorMesaIds(List<String> mesaIds) async {
    if (mesaIds.isEmpty) return [];
    try {
      // Firestore whereIn soporta máximo 30 elementos
      final List<Reserva> todasReservas = [];
      for (int i = 0; i < mesaIds.length; i += 30) {
        final batch = mesaIds.sublist(
          i,
          i + 30 > mesaIds.length ? mesaIds.length : i + 30,
        );
        final snapshot = await _reservasRef
            .where('mesaId', whereIn: batch)
            .orderBy('fechaHora', descending: true)
            .get();
        todasReservas.addAll(
          snapshot.docs.map((doc) => _mapToReserva(doc.id, doc.data())),
        );
      }
      return todasReservas;
    } catch (e) {
      print('❌ Error obteniendo reservas por mesa IDs: $e');
      return [];
    }
  }

  @override
  Future<List<Reserva>> obtenerReservasPorContacto(String contactoCliente) async {
    if (contactoCliente.isEmpty) return [];
    try {
      final snapshot = await _reservasRef
          .where('contactoCliente', isEqualTo: contactoCliente)
          .orderBy('fechaHora', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _mapToReserva(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo reservas por contacto: $e');
      return [];
    }
  }

  @override
  Future<List<Reserva>> obtenerReservasPorMesaYHorario({
    required String mesaId,
    required DateTime fecha,
    required DateTime hora,
  }) async {
    try {
      // Buscar reservas del mismo día para la mesa
      // Solo filtramos por mesaId para evitar requerir índice compuesto
      final snapshot =
          await _reservasRef.where('mesaId', isEqualTo: mesaId).get();

      final inicioDia = DateTime(fecha.year, fecha.month, fecha.day);
      final finDia = inicioDia.add(const Duration(days: 1));

      return snapshot.docs
          .map((doc) => _mapToReserva(doc.id, doc.data()))
          .where(
            (r) =>
                r.estado != EstadoReserva.cancelada &&
                r.fechaHora.isAfter(
                  inicioDia.subtract(const Duration(seconds: 1)),
                ) &&
                r.fechaHora.isBefore(finDia),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo reservas por mesa y horario: $e');
      return [];
    }
  }

  @override
  Future<bool> mesaDisponible({
    required String mesaId,
    required DateTime fecha,
    required DateTime hora,
    required int duracionMinutos,
  }) async {
    try {
      final reservas = await obtenerReservasPorMesaYHorario(
        mesaId: mesaId,
        fecha: fecha,
        hora: hora,
      );

      // Calcular el intervalo de la nueva reserva
      final horaInicioNueva = hora;
      final horaFinNueva = hora.add(Duration(minutes: duracionMinutos));

      // Verificar si hay colisión con alguna reserva existente
      for (final reserva in reservas) {
        final horaInicioExistente = reserva.fechaHora;
        final horaFinExistente = reserva.horaFin;

        // Hay colisión si los intervalos se superponen
        final hayColision =
            horaInicioNueva.isBefore(horaFinExistente) &&
            horaFinNueva.isAfter(horaInicioExistente);

        if (hayColision) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('❌ Error verificando disponibilidad: $e');
      return false;
    }
  }

  // ============================================================
  // MÉTODOS DE CONVERSIÓN
  // ============================================================

  Map<String, dynamic> _reservaToMap(Reserva reserva) {
    return {
      'mesaId': reserva.mesaId,
      'fechaHora': Timestamp.fromDate(reserva.fechaHora),
      'numeroPersonas': reserva.numeroPersonas,
      'duracionMinutos': reserva.duracionMinutos,
      'estado': _estadoToString(reserva.estado),
      'contactoCliente': reserva.contactoCliente,
      'nombreCliente': reserva.nombreCliente,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Reserva _mapToReserva(String id, Map<String, dynamic> data) {
    return Reserva(
      id: id,
      mesaId: data['mesaId'] ?? '',
      fechaHora: (data['fechaHora'] as Timestamp).toDate(),
      numeroPersonas: data['numeroPersonas'] ?? 1,
      duracionMinutos: data['duracionMinutos'] ?? 60,
      estado: _stringToEstado(data['estado']),
      contactoCliente: data['contactoCliente'],
      nombreCliente: data['nombreCliente'],
    );
  }

  String _estadoToString(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.pendiente:
        return 'pendiente';
      case EstadoReserva.confirmada:
        return 'confirmada';
      case EstadoReserva.cancelada:
        return 'cancelada';
    }
  }

  EstadoReserva _stringToEstado(String? estado) {
    switch (estado) {
      case 'confirmada':
        return EstadoReserva.confirmada;
      case 'cancelada':
        return EstadoReserva.cancelada;
      default:
        return EstadoReserva.pendiente;
    }
  }
}
