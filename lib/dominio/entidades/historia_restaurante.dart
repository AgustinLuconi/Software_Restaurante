import 'package:flutter/material.dart';

/// Representa un ítem de especialidad del restaurante
class EspecialidadItem {
  final String nombre;
  final String descripcion;
  final IconData icono;

  const EspecialidadItem({
    required this.nombre,
    required this.descripcion,
    required this.icono,
  });
}

/// Estructura de datos para la información histórica del restaurante
class HistoriaRestaurante {
  final String titulo;
  final String subtitulo;
  final List<String> parrafosHistoria;
  final List<EspecialidadItem> especialidades;

  HistoriaRestaurante({
    required this.titulo,
    required this.subtitulo,
    required this.parrafosHistoria,
    required this.especialidades,
  });

  HistoriaRestaurante copyWith({
    String? titulo,
    String? subtitulo,
    List<String>? parrafosHistoria,
    List<EspecialidadItem>? especialidades,
  }) {
    return HistoriaRestaurante(
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      parrafosHistoria: parrafosHistoria ?? this.parrafosHistoria,
      especialidades: especialidades ?? this.especialidades,
    );
  }
}

/// Datos modificables de la historia del restaurante
class HistoriaData {
  static HistoriaRestaurante actual = HistoriaRestaurante(
    titulo: 'Nuestra Historia',
    subtitulo: 'Tradición y pasión desde 1998',
    parrafosHistoria: [
      'Fundado en 1998 por la familia Martínez, nuestro restaurante nació de un sueño compartido: '
      'llevar los sabores auténticos del Mediterráneo a cada mesa.',
      'La inspiración de nuestra cocina proviene de las recetas tradicionales transmitidas de '
      'generación en generación. Nuestra abuela Carmen nos enseñó que cocinar es un acto de amor.',
      'A lo largo de más de 25 años, hemos mantenido nuestro compromiso con la excelencia '
      'y los ingredientes frescos.',
    ],
    especialidades: [
      const EspecialidadItem(
        nombre: 'Paella Valenciana',
        descripcion: 'Nuestra receta estrella con arroz bomba.',
        icono: Icons.rice_bowl,
      ),
      const EspecialidadItem(
        nombre: 'Pulpo a la Gallega',
        descripcion: 'Pulpo cocido al punto perfecto.',
        icono: Icons.set_meal,
      ),
      const EspecialidadItem(
        nombre: 'Cochinillo Asado',
        descripcion: 'Asado lentamente en horno de leña.',
        icono: Icons.dining,
      ),
    ],
  );
}
