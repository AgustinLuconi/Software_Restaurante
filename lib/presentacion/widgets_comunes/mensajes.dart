import 'package:flutter/material.dart';
import 'constantes_diseno.dart';

/// Contenedor de mensaje de error con ícono.
///
/// Ejemplo:
/// ```dart
/// MensajeError(texto: 'Código incorrecto')
/// ```
class MensajeError extends StatelessWidget {
  final String texto;

  const MensajeError({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return _MensajeBase(
      texto: texto,
      color: AppColores.error,
      icon: Icons.error_outline,
    );
  }
}

/// Contenedor de mensaje informativo con ícono.
///
/// Ejemplo:
/// ```dart
/// MensajeInfo(texto: 'SMS enviado correctamente')
/// ```
class MensajeInfo extends StatelessWidget {
  final String texto;
  final IconData icon;

  const MensajeInfo({
    super.key,
    required this.texto,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return _MensajeBase(
      texto: texto,
      color: AppColores.info,
      icon: icon,
    );
  }
}

/// Contenedor de mensaje de éxito.
class MensajeExito extends StatelessWidget {
  final String texto;

  const MensajeExito({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return _MensajeBase(
      texto: texto,
      color: AppColores.exito,
      icon: Icons.check_circle_outline,
    );
  }
}

/// Contenedor de mensaje de advertencia.
class MensajeAdvertencia extends StatelessWidget {
  final String texto;

  const MensajeAdvertencia({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return _MensajeBase(
      texto: texto,
      color: AppColores.advertencia,
      icon: Icons.warning_amber_rounded,
    );
  }
}

/// Widget base para todos los mensajes
class _MensajeBase extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData icon;

  const _MensajeBase({
    required this.texto,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.normal,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadios.pequeno),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
