import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../dominio/entidades/historia_restaurante.dart';
import '../dominio/repositorios/historia_repositorio.dart';

class HistoriaRepositorioFirestore implements HistoriaRepositorio {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _historiasRef =>
      _firestore.collection('historias');

  @override
  Future<HistoriaRestaurante?> obtenerHistoria(String negocioId) async {
    try {
      final doc = await _historiasRef.doc(negocioId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _mapToHistoria(doc.data()!);
    } catch (e) {
      print('❌ Error obteniendo historia: $e');
      return null;
    }
  }

  @override
  Future<bool> guardarHistoria(
    String negocioId,
    HistoriaRestaurante historia,
  ) async {
    try {
      await _historiasRef.doc(negocioId).set(_historiaToMap(historia));
      print('✅ Historia guardada para: $negocioId');
      return true;
    } catch (e) {
      print('❌ Error guardando historia: $e');
      return false;
    }
  }

  // Mappers

  Map<String, dynamic> _historiaToMap(HistoriaRestaurante historia) {
    return {
      'titulo': historia.titulo,
      'subtitulo': historia.subtitulo,
      'parrafosHistoria': historia.parrafosHistoria,
      'especialidades':
          historia.especialidades.map((e) => _especialidadToMap(e)).toList(),
    };
  }

  Map<String, dynamic> _especialidadToMap(EspecialidadItem item) {
    return {
      'nombre': item.nombre,
      'descripcion': item.descripcion,
      'iconoCode': item.icono.codePoint,
      'iconoFontFamily': item.icono.fontFamily,
      'iconoFontPackage': item.icono.fontPackage,
    };
  }

  HistoriaRestaurante _mapToHistoria(Map<String, dynamic> data) {
    return HistoriaRestaurante(
      titulo: data['titulo'] ?? '',
      subtitulo: data['subtitulo'] ?? '',
      parrafosHistoria: List<String>.from(data['parrafosHistoria'] ?? []),
      especialidades:
          (data['especialidades'] as List<dynamic>? ?? [])
              .map((e) => _mapToEspecialidad(e))
              .toList(),
    );
  }

  EspecialidadItem _mapToEspecialidad(Map<String, dynamic> data) {
    final code = data['iconoCode'] as int? ?? 0xe532; // Default restaurant
    
    return EspecialidadItem(
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      icono: _getIconFromCode(code),
    );
  }

  IconData _getIconFromCode(int code) {
    // Lista blanca de iconos permitidos para evitar problemas de tree-shaking
    // y "non-constant invocations of IconData" en Flutter Web Release.
    const allowedIcons = [
      Icons.restaurant,
      Icons.restaurant_menu,
      Icons.rice_bowl,
      Icons.set_meal,
      Icons.dining,
      Icons.local_cafe,
      Icons.local_pizza,
      Icons.local_bar,
      Icons.fastfood,
      Icons.cake,
      Icons.icecream,
      Icons.local_dining,
      Icons.lunch_dining,
      Icons.brunch_dining,
      Icons.breakfast_dining,
      Icons.dinner_dining,
      Icons.bakery_dining,
      Icons.ramen_dining,
      Icons.kebab_dining,
      Icons.tapas,
      Icons.soup_kitchen,
    ];

    try {
      return allowedIcons.firstWhere((icon) => icon.codePoint == code);
    } catch (_) {
      return Icons.restaurant; // Fallback seguro
    }
  }
}
