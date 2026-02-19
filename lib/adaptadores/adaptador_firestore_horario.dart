import 'package:cloud_firestore/cloud_firestore.dart';
import '../dominio/entidades/horario_apertura.dart';
import '../dominio/repositorios/horario_apertura_repositorio.dart';

/// Adaptador de Firestore para el repositorio de horarios de apertura
/// Lee y escribe desde la colección 'horarios_apertura' en Firestore
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

    HorarioDia? horarioDia;
    for (final h in horario.horariosSemanal) {
      if (_obtenerNumeroDia(h.nombreDia) == diaSemana) {
        horarioDia = h;
        break;
      }
    }

    if (horarioDia == null || horarioDia.cerrado) return [];

    for (final intervalo in horarioDia.intervalos) {
      var horaActual = intervalo.horaInicio;
      var minutoActual = intervalo.minutoInicio;

      var horaFinCalculo = intervalo.horaFin;
      if (horaFinCalculo < intervalo.horaInicio || (horaFinCalculo == intervalo.horaInicio && intervalo.minutoFin <= intervalo.minutoInicio)) {
        horaFinCalculo += 24;
      }

      while (horaActual < horaFinCalculo ||
          (horaActual == horaFinCalculo && minutoActual < intervalo.minutoFin)) {
        
        var horaFin = horaActual;
        var minutoFin = minutoActual + intervaloMinutos;
        if (minutoFin >= 60) {
          horaFin++;
          minutoFin = minutoFin - 60;
        }

        final horaInicioMostrar = horaActual % 24;
        final horaFinMostrar = horaFin % 24;
        
        final horaInicioStr = '${horaInicioMostrar.toString().padLeft(2, '0')}:${minutoActual.toString().padLeft(2, '0')}';
        final horaFinStr = '${horaFinMostrar.toString().padLeft(2, '0')}:${minutoFin.toString().padLeft(2, '0')}';
        intervalos.add('$horaInicioStr - $horaFinStr');

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
  @override
  Future<bool> guardarHorario(HorarioApertura horario) async {
    try {
      final snapshot = await _horariosRef
          .where('negocioId', isEqualTo: horario.negocioId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        await _horariosRef.add(_horarioToMap(horario));
        print('✅ Horario creado para negocio: ${horario.negocioId}');
      } else {
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

  /// Convierte HorarioApertura a Map<String, String> para mostrar en pantalla
  /// Ejemplo: {'lunes': 'Cerrado', 'miercoles': '12:00 - 15:30 / 20:00 - 23:30'}
  @override
  Map<String, String> horarioAMapString(HorarioApertura horario) {
    final mapa = <String, String>{};
    for (final dia in horario.horariosSemanal) {
      if (dia.cerrado) {
        mapa[dia.nombreDia] = 'Cerrado';
      } else if (dia.intervalos.isEmpty) {
        mapa[dia.nombreDia] = 'Sin horario';
      } else {
        mapa[dia.nombreDia] = dia.intervalos.map((i) {
          final hi = i.horaInicio.toString().padLeft(2, '0');
          final mi = i.minutoInicio.toString().padLeft(2, '0');
          final hf = i.horaFin.toString().padLeft(2, '0');
          final mf = i.minutoFin.toString().padLeft(2, '0');
          return '$hi:$mi - $hf:$mf';
        }).join(' / ');
      }
    }
    return mapa;
  }

  /// Convierte un Map<String, String> (del editor) a HorarioApertura
  @override
  HorarioApertura mapStringAHorario(String negocioId, Map<String, String> mapa) {
    final horariosSemanal = <HorarioDia>[];

    for (final entry in mapa.entries) {
      final nombreDia = entry.key;
      final valorStr = entry.value.trim();

      if (valorStr.toLowerCase() == 'cerrado') {
        horariosSemanal.add(HorarioDia(
          nombreDia: nombreDia,
          cerrado: true,
        ));
      } else {
        final intervalos = _parsearIntervalos(valorStr);
        horariosSemanal.add(HorarioDia(
          nombreDia: nombreDia,
          cerrado: false,
          intervalos: intervalos,
        ));
      }
    }

    return HorarioApertura(
      negocioId: negocioId,
      horariosSemanal: horariosSemanal,
    );
  }

  // ============================================================
  // MÉTODOS PRIVADOS
  // ============================================================

  /// Parsea un string como "12:00 - 15:30 / 20:00 - 23:30" a lista de intervalos
  /// Acepta formatos flexibles: "9-13", "09:00 - 13:00", "9 - 13:30"
  List<IntervaloHorario> _parsearIntervalos(String texto) {
    final intervalos = <IntervaloHorario>[];
    if (texto.trim().isEmpty) return intervalos;

    // Normalizar separadores de turnos
    final turnos = texto.replaceAll(' y ', '/').split('/');
    
    for (final turno in turnos) {
      // Normalizar separadores de rango (permitir "a", "hasta", "-")
      final parteLimpia = turno.replaceAll(' a ', '-').replaceAll(' hasta ', '-');
      final partes = parteLimpia.trim().split('-');

      if (partes.length != 2) continue;

      try {
        final inicio = _parsearHoraMinuto(partes[0].trim());
        final fin = _parsearHoraMinuto(partes[1].trim());

        if (inicio != null && fin != null) {
          intervalos.add(IntervaloHorario(
            horaInicio: inicio.hora,
            minutoInicio: inicio.minuto,
            horaFin: fin.hora,
            minutoFin: fin.minuto,
          ));
        }
      } catch (e) {
        print('⚠️ Error parseando intervalo: "$turno" - $e');
      }
    }

    return intervalos;
  }

  /// Intenta parsear texto a hora y minuto
  ({int hora, int minuto})? _parsearHoraMinuto(String texto) {
    if (texto.isEmpty) return null;
    
    try {
      // Caso: "9" o "13"
      if (!texto.contains(':')) {
        final hora = int.parse(texto);
        if (hora >= 0 && hora <= 24) {
          return (hora: hora == 24 ? 0 : hora, minuto: 0);
        }
        return null;
      }

      // Caso: "9:30" o "09:30"
      final partes = texto.split(':');
      if (partes.length == 2) {
        final hora = int.parse(partes[0]);
        final minuto = int.parse(partes[1]);
        if (hora >= 0 && hora <= 24 && minuto >= 0 && minuto < 60) {
          return (hora: hora == 24 ? 0 : hora, minuto: minuto);
        }
      }
    } catch (_) {}
    
    return null;
  }

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
