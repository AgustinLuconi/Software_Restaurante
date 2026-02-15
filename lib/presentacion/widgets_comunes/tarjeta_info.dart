import 'package:flutter/material.dart';
import 'constantes_diseno.dart';
import 'icono_circular.dart';

/// Tarjeta informativa con ícono, título, subtítulo y acción opcional.
/// Unifica los patrones _buildInfoCard, _buildSecurityCard, _buildSecurityCardConEstado.
///
/// Ejemplo:
/// ```dart
/// TarjetaInfo(
///   icon: Icons.email,
///   titulo: 'Email',
///   subtitulo: 'correo@test.com',
///   color: Colors.blue,
///   onTap: () {},
/// )
/// ```
class TarjetaInfo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double elevation;
  final bool mostrarChevron;

  const TarjetaInfo({
    super.key,
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    this.onTap,
    this.trailing,
    this.elevation = 2,
    this.mostrarChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadios.mediano),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadios.mediano),
        child: Padding(
          padding: AppPaddings.mediano,
          child: Row(
            children: [
              IconoCircular(icon: icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColores.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null && mostrarChevron && onTap != null)
                Icon(Icons.chevron_right, color: AppColores.textoClaro),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante de TarjetaInfo con badge de estado (verificado/no verificado)
class TarjetaInfoConEstado extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color color;
  final bool estaVerificado;
  final VoidCallback? onTap;

  const TarjetaInfoConEstado({
    super.key,
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.estaVerificado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaInfo(
      icon: icon,
      titulo: titulo,
      subtitulo: subtitulo,
      color: color,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (estaVerificado)
            BadgeVerificado()
          else
            Icon(Icons.chevron_right, color: AppColores.textoClaro),
        ],
      ),
    );
  }
}

/// Badge pequeño de "Verificado"
class BadgeVerificado extends StatelessWidget {
  const BadgeVerificado({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColores.exito.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadios.mediano),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColores.exito),
          SizedBox(width: 4),
          Text(
            'Verificado',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColores.exito,
            ),
          ),
        ],
      ),
    );
  }
}
