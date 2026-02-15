import 'package:flutter/material.dart';

/// Constantes de diseño compartidas para toda la aplicación
class AppColores {
  // Colores primarios del tema
  static const Color primario = Color(0xFF2C3E50);
  static const Color acento = Color(0xFF27AE60);
  static const Color info = Color(0xFF3498DB);
  static const Color advertencia = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color exito = Color(0xFF27AE60);
  static const Color morado = Color(0xFF9B59B6);

  // Colores de texto
  static const Color textoOscuro = Color(0xFF2C3E50);
  static Color textoSecundario = Colors.grey[600]!;
  static Color textoClaro = Colors.grey[400]!;
}

class AppRadios {
  static const double pequeno = 8.0;
  static const double normal = 10.0;
  static const double mediano = 12.0;
  static const double grande = 16.0;
  static const double extraGrande = 20.0;
}

class AppPaddings {
  static const EdgeInsets pequeno = EdgeInsets.all(8);
  static const EdgeInsets normal = EdgeInsets.all(12);
  static const EdgeInsets mediano = EdgeInsets.all(16);
  static const EdgeInsets grande = EdgeInsets.all(20);
}
