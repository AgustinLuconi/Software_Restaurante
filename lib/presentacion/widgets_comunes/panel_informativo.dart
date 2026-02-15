import 'package:flutter/material.dart';
import 'constantes_diseno.dart';
import 'icono_circular.dart';

/// Panel informativo con ícono, título y descripción.
/// Útil para mostrar información contextual en secciones.
///
/// Ejemplo:
/// ```dart
/// PanelInformativo(
///   icon: Icons.schedule,
///   titulo: 'Horarios de reserva',
///   descripcion: 'Cada mesa se reserva por 60 minutos',
///   color: AppColores.info,
/// )
/// ```
class PanelInformativo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;
  final double borderRadius;

  const PanelInformativo({
    super.key,
    required this.icon,
    required this.titulo,
    required this.descripcion,
    this.color = AppColores.info,
    this.borderRadius = AppRadios.mediano,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.mediano,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconoCircular.circulo(
            icon: icon,
            color: color,
            size: 24,
            padding: 10,
            backgroundColor: color.withOpacity(0.2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColores.textoOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
