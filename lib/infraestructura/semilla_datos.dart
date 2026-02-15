import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Para IconObjects si se usa
import '../dominio/entidades/historia_restaurante.dart';

class SemillaDatos {
  static Future<void> inicializarDatosChiringuito() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // 1. Buscar el negocio "El Chiringuito" (o "Chiringuito")
      print('🚀 SemillaDatos: Buscando "El Chiringuito"...');
      final querySnapshot = await firestore
          .collection('negocios')
          .get();

      String? chiringuitoId;
      
      for (var doc in querySnapshot.docs) {
        final nombre = (doc.data()['nombre'] as String? ?? '').toLowerCase();
        if (nombre.contains('chiringuito')) {
          chiringuitoId = doc.id;
          print('✅ SemillaDatos: Encontrado ID: $chiringuitoId para "$nombre"');
          break;
        }
      }

      if (chiringuitoId == null) {
        print('⚠️ SemillaDatos: No se encontró el restaurante "Chiringuito". Saltando migración.');
        return;
      }

      // 2. Verificar si ya tiene historia
      final historiaRef = firestore.collection('historias').doc(chiringuitoId);
      final historiaSnapshot = await historiaRef.get();

      if (historiaSnapshot.exists) {
        print('✅ SemillaDatos: "El Chiringuito" ($chiringuitoId) ya tiene historia. No se requiere acción.');
        return;
      }

      // 3. Inyectar datos por defecto
      print('🚀 SemillaDatos: Inyectando historia por defecto para "El Chiringuito" ($chiringuitoId)...');
      
      final historiaData = HistoriaData.actual; // Datos hardcodeados legacy
      
      final mapaHistoria = {
        'titulo': historiaData.titulo,
        'subtitulo': historiaData.subtitulo,
        'parrafosHistoria': historiaData.parrafosHistoria,
        'especialidades': historiaData.especialidades.map((e) => {
          'nombre': e.nombre,
          'descripcion': e.descripcion,
          'iconoCodePoint': e.icono.codePoint,
          'iconoFontFamily': e.icono.fontFamily,
          'iconoFontPackage': e.icono.fontPackage,
        }).toList(),
      };

      await historiaRef.set(mapaHistoria);
      print('🎉 SemillaDatos: Historia inyectada correctamente para "El Chiringuito".');

    } catch (e) {
      print('❌ Error en SemillaDatos: $e');
    }
  }
}
