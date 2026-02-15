import 'package:flutter/material.dart';
import 'constantes_diseno.dart';
import 'icono_circular.dart';

/// Tarjeta con gradiente para acciones del dashboard.
/// Reemplaza el patrón _buildMenuCard del panel del dueño.
///
/// Ejemplo:
/// ```dart
/// TarjetaAccionGradiente(
///   icon: Icons.table_bar,
///   title: 'Mesas',
///   subtitle: 'Configurar',
///   gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
///   onTap: () {},
/// )
/// ```
class TarjetaAccionGradiente extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final double iconSize;
  final double borderRadius;

  const TarjetaAccionGradiente({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
    this.iconSize = 32,
    this.borderRadius = AppRadios.extraGrande,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: gradient.colors.first.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: AppPaddings.mediano,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconoCircular.circulo(
                  icon: icon,
                  color: Colors.white,
                  size: iconSize,
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
