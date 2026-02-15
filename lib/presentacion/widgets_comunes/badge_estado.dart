import 'package:flutter/material.dart';
import 'constantes_diseno.dart';

/// Badge/chip de estado con color e ícono opcional.
/// Útil para estados como: confirmada, cancelada, pendiente, verificado, etc.
///
/// Ejemplo:
/// ```dart
/// BadgeEstado(texto: 'Confirmada', color: Colors.green, icon: Icons.check_circle)
/// BadgeEstado.confirmada()
/// BadgeEstado.cancelada()
/// BadgeEstado.pendiente()
/// ```
class BadgeEstado extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icon;
  final double fontSize;

  const BadgeEstado({
    super.key,
    required this.texto,
    required this.color,
    this.icon,
    this.fontSize = 12,
  });

  /// Badges predefinidos para estados comunes
  factory BadgeEstado.confirmada() => const BadgeEstado(
        texto: 'Confirmada',
        color: AppColores.exito,
        icon: Icons.check_circle,
      );

  factory BadgeEstado.cancelada() => const BadgeEstado(
        texto: 'Cancelada',
        color: AppColores.error,
        icon: Icons.cancel,
      );

  factory BadgeEstado.pendiente() => const BadgeEstado(
        texto: 'Pendiente',
        color: AppColores.advertencia,
        icon: Icons.schedule,
      );

  factory BadgeEstado.verificado() => const BadgeEstado(
        texto: 'Verificado',
        color: AppColores.exito,
        icon: Icons.verified,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadios.mediano),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
