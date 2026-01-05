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

  const HistoriaRestaurante({
    required this.titulo,
    required this.subtitulo,
    required this.parrafosHistoria,
    required this.especialidades,
  });
}

/// Datos de ejemplo (mock) para la historia del restaurante
const historiaMock = HistoriaRestaurante(
  titulo: 'Nuestra Historia',
  subtitulo: 'Tradición y pasión desde 1998',
  parrafosHistoria: [
    'Fundado en 1998 por la familia Martínez, nuestro restaurante nació de un sueño compartido: '
    'llevar los sabores auténticos del Mediterráneo a cada mesa. Lo que comenzó como un pequeño '
    'local familiar en el corazón de la ciudad, se ha convertido en un referente gastronómico '
    'reconocido por su calidad y calidez.',
    
    'La inspiración de nuestra cocina proviene de las recetas tradicionales transmitidas de '
    'generación en generación. Nuestra abuela Carmen, con sus manos sabias, nos enseñó que '
    'cocinar es un acto de amor. Cada plato que servimos lleva consigo esa herencia, ese '
    'cariño por los ingredientes frescos y las técnicas artesanales.',
    
    'A lo largo de más de 25 años, hemos mantenido nuestro compromiso con la excelencia. '
    'Trabajamos con productores locales, seleccionamos los mejores ingredientes de temporada '
    'y preparamos cada receta con la dedicación que nuestros clientes merecen. Porque para '
    'nosotros, cada comensal es parte de nuestra familia.',
    
    'Hoy, la tercera generación de la familia Martínez continúa el legado, fusionando la '
    'tradición con toques contemporáneos, pero sin perder nunca la esencia que nos define: '
    'autenticidad, calidad y hospitalidad.',
  ],
  especialidades: [
    EspecialidadItem(
      nombre: 'Paella Valenciana',
      descripcion: 'Nuestra receta estrella, preparada con arroz bomba, mariscos frescos del día, '
          'azafrán de La Mancha y el sofrito secreto de la abuela Carmen. Cocinada a fuego lento '
          'en paellera tradicional de hierro.',
      icono: Icons.rice_bowl,
    ),
    EspecialidadItem(
      nombre: 'Pulpo a la Gallega',
      descripcion: 'Pulpo de las rías gallegas, cocido al punto perfecto y servido sobre cama de '
          'patatas cachelas. Aliñado con pimentón de la Vera, aceite de oliva virgen extra y '
          'sal gruesa marina.',
      icono: Icons.set_meal,
    ),
    EspecialidadItem(
      nombre: 'Cochinillo Asado',
      descripcion: 'Cochinillo de Segovia asado en horno de leña durante 3 horas. Piel crujiente '
          'y carne tierna que se deshace en el paladar. Servido con patatas asadas y ensalada '
          'de la huerta.',
      icono: Icons.dining,
    ),
    EspecialidadItem(
      nombre: 'Gazpacho Andaluz',
      descripcion: 'Sopa fría tradicional elaborada con tomates maduros de temporada, pepino, '
          'pimiento, ajo, aceite de oliva y vinagre de Jerez. Refrescante y nutritivo, perfecto '
          'para los días de calor.',
      icono: Icons.soup_kitchen,
    ),
    EspecialidadItem(
      nombre: 'Tarta de Santiago',
      descripcion: 'Postre tradicional gallego elaborado con almendra molida, huevos frescos, '
          'azúcar y un toque de limón. Decorada con la cruz de Santiago y espolvoreada con '
          'azúcar glas.',
      icono: Icons.cake,
    ),
    EspecialidadItem(
      nombre: 'Jamón Ibérico de Bellota',
      descripcion: 'Jamón de cerdo ibérico 100% criado en dehesa, alimentado con bellotas durante '
          'la montanera. Curación mínima de 36 meses. Cortado a mano por nuestro maestro jamonero.',
      icono: Icons.restaurant,
    ),
  ],
);
