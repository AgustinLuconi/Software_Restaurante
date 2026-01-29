import 'package:cloud_firestore/cloud_firestore.dart';
import '../dominio/entidades/horario_apertura.dart';
import '../dominio/repositorios/horario_apertura_repositorio.dart';

/// Adaptador de Firestore para el repositorio de horarios de apertura
class HorarioAperturaRepositorioFirestore implements HorarioAperturaRepositorio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referencia a la colección de horarios
  CollectionReference<Map<String, dynamic>> get _horariosRef =>
      _firestore.collection('horarios_apertura');

  @override
  Future<HorarioApertura?> obtenerHorarioPorNegocio(String negocioId) async {
    try {
      final snapshot = await _horariosRef
          .where('negocioId', isEqualTo: negocioId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No hay horario para negocio: $negocioId');
        return null;
      }

      final doc = snapshot.docs.first;
      return _mapToHorario(doc.data());
    } catch (e) {
      print('❌ Error obteniendo horario: $e');
      return null;
    }
  }

  @override
  Future<bool> estaAbiertoEn(String negocioId, DateTime fechaHora) async {
    final horario = await obtenerHorarioPorNegocio(negocioId);
    if (horario == null) {
      // Si no hay horario definido, asumir que está abierto
      return true;
    }
    return horario.estaAbiertoEn(fechaHora);
  }

  @override
  Future<String> obtenerMensajeHorarioCerrado(
    String negocioId,
    DateTime fechaHora,
  ) async {
    final horario = await obtenerHorarioPorNegocio(negocioId);
    if (horario == null) {
      return 'No hay información de horarios disponible.';
    }

    if (!horario.estaAbiertoEn(fechaHora)) {
      return horario.obtenerMensajeError(fechaHora);
    }
    return '';
  }

  @override
  Future<List<String>> obtenerIntervalosDisponibles(
    String negocioId,
    DateTime fecha, {
    int intervaloMinutos = 60,
  }) async {
    final horario = await obtenerHorarioPorNegocio(negocioId);
    if (horario == null) return [];

    final intervalos = <String>[];
    final diaSemana = fecha.weekday;

    // Buscar el horario del día correspondiente
    HorarioDia? horarioDia;
    for (final h in horario.horariosSemanal) {
      if (_obtenerNumeroDia(h.nombreDia) == diaSemana) {
        horarioDia = h;
        break;
      }
    }

    if (horarioDia == null || horarioDia.cerrado) return [];

    // Generar intervalos de tiempo para cada período abierto
    for (final intervalo in horarioDia.intervalos) {
      var horaActual = intervalo.horaInicio;
      var minutoActual = intervalo.minutoInicio;

      while (horaActual < intervalo.horaFin ||
          (horaActual == intervalo.horaFin && minutoActual < intervalo.minutoFin)) {
        
        // Calcular hora de fin del intervalo
        var horaFin = horaActual;
        var minutoFin = minutoActual + intervaloMinutos;
        if (minutoFin >= 60) {
          horaFin++;
          minutoFin = minutoFin - 60;
        }

        final horaInicioStr = '${horaActual.toString().padLeft(2, '0')}:${minutoActual.toString().padLeft(2, '0')}';
        final horaFinStr = '${horaFin.toString().padLeft(2, '0')}:${minutoFin.toString().padLeft(2, '0')}';
        intervalos.add('$horaInicioStr - $horaFinStr');

        // Avanzar según el intervalo
        minutoActual += intervaloMinutos;
        if (minutoActual >= 60) {
          horaActual++;
          minutoActual = minutoActual - 60;
        }
      }
    }

    return intervalos;
  }

  /// Guarda o actualiza el horario de un negocio
  Future<bool> guardarHorario(HorarioApertura horario) async {
    try {
      // Buscar si ya existe un documento para este negocio
      final snapshot = await _horariosRef
          .where('negocioId', isEqualTo: horario.negocioId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // Crear nuevo documento
        await _horariosRef.add(_horarioToMap(horario));
        print('✅ Horario creado para negocio: ${horario.negocioId}');
      } else {
        // Actualizar documento existente
        await _horariosRef
            .doc(snapshot.docs.first.id)
            .update(_horarioToMap(horario));
        print('✅ Horario actualizado para negocio: ${horario.negocioId}');
      }
      return true;
    } catch (e) {
      print('❌ Error guardando horario: $e');
      return false;
    }
  }

  // ============================================================
  // MÉTODOS DE CONVERSIÓN
  // ============================================================

  Map<String, dynamic> _horarioToMap(HorarioApertura horario) {
    return {
      'negocioId': horario.negocioId,
      'horariosSemanal': horario.horariosSemanal
          .map((dia) => _horarioDiaToMap(dia))
          .toList(),
    };
  }

  Map<String, dynamic> _horarioDiaToMap(HorarioDia dia) {
    return {
      'nombreDia': dia.nombreDia,
      'cerrado': dia.cerrado,
      'intervalos': dia.intervalos
          .map((i) => {
                'horaInicio': i.horaInicio,
                'minutoInicio': i.minutoInicio,
                'horaFin': i.horaFin,
                'minutoFin': i.minutoFin,
              })
          .toList(),
    };
  }

  HorarioApertura _mapToHorario(Map<String, dynamic> data) {
    final horariosList = data['horariosSemanal'] as List<dynamic>? ?? [];
    
    return HorarioApertura(
      negocioId: data['negocioId'] ?? '',
      horariosSemanal: horariosList
          .map((h) => _mapToHorarioDia(h as Map<String, dynamic>))
          .toList(),
    );
  }

  HorarioDia _mapToHorarioDia(Map<String, dynamic> data) {
    final intervalosList = data['intervalos'] as List<dynamic>? ?? [];
    
    return HorarioDia(
      nombreDia: data['nombreDia'] ?? '',
      cerrado: data['cerrado'] ?? false,
      intervalos: intervalosList
          .map((i) => _mapToIntervalo(i as Map<String, dynamic>))
          .toList(),
    );
  }

  IntervaloHorario _mapToIntervalo(Map<String, dynamic> data) {
    return IntervaloHorario(
      horaInicio: data['horaInicio'] ?? 0,
      minutoInicio: data['minutoInicio'] ?? 0,
      horaFin: data['horaFin'] ?? 0,
      minutoFin: data['minutoFin'] ?? 0,
    );
  }

  int _obtenerNumeroDia(String nombreDia) {
    switch (nombreDia.toLowerCase()) {
      case 'lunes':
        return 1;
      case 'martes':
        return 2;
      case 'miércoles':
      case 'miercoles':
        return 3;
      case 'jueves':
        return 4;
      case 'viernes':
        return 5;
      case 'sábado':
      case 'sabado':
        return 6;
      case 'domingo':
        return 7;
      default:
        return 0;
    }
  }
}
