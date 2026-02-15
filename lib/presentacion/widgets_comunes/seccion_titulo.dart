import 'package:flutter/material.dart';
import 'constantes_diseno.dart';

/// Encabezado de sección con ícono y título.
/// Patrón repetido para separar secciones dentro de pantallas.
///
/// Ejemplo:
/// ```dart
/// SeccionTitulo(
///   icon: Icons.security,
///   titulo: 'Seguridad',
///   color: Colors.blue,
/// )
/// ```
class SeccionTitulo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final Color color;
  final Widget? trailing;
  final double fontSize;

  const SeccionTitulo({
    super.key,
    required this.icon,
    required this.titulo,
    this.color = AppColores.primario,
    this.trailing,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: fontSize + 4),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColores.textoOscuro,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
