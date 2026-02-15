import 'package:flutter/material.dart';
import 'constantes_diseno.dart';

/// Widget reutilizable para mostrar un ícono dentro de un círculo coloreado.
/// Es el patrón más repetido en toda la app (~20+ veces).
///
/// Ejemplo:
/// ```dart
/// IconoCircular(icon: Icons.phone, color: Colors.blue)
/// IconoCircular(icon: Icons.email, color: Colors.green, size: 32, padding: 14)
/// IconoCircular.circulo(icon: Icons.check, color: Colors.white, bgColor: Colors.green)
/// ```
class IconoCircular extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double padding;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxShape shape;

  const IconoCircular({
    super.key,
    required this.icon,
    required this.color,
    this.size = 28,
    this.padding = 12,
    this.borderRadius = AppRadios.normal,
    this.backgroundColor,
    this.shape = BoxShape.rectangle,
  });

  /// Constructor para forma circular (en vez de rectángulo redondeado)
  const IconoCircular.circulo({
    super.key,
    required this.icon,
    required this.color,
    this.size = 28,
    this.padding = 12,
    this.backgroundColor,
  })  : borderRadius = 0,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
        shape: shape,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
