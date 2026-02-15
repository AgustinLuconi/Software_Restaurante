import 'package:flutter/material.dart';
import 'constantes_diseno.dart';

/// Botón primario estandarizado con ícono opcional y estado de carga.
///
/// Ejemplo:
/// ```dart
/// BotonPrimario(
///   texto: 'Guardar',
///   icon: Icons.save,
///   onPressed: () {},
///   color: AppColores.exito,
/// )
/// ```
class BotonPrimario extends StatelessWidget {
  final String texto;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final bool expandido;

  const BotonPrimario({
    super.key,
    required this.texto,
    this.icon,
    this.onPressed,
    this.color = AppColores.acento,
    this.isLoading = false,
    this.expandido = true,
  });

  @override
  Widget build(BuildContext context) {
    final boton = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadios.mediano),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );

    if (expandido) {
      return SizedBox(width: double.infinity, child: boton);
    }
    return boton;
  }
}

/// Botón secundario (outlined) estandarizado
class BotonSecundario extends StatelessWidget {
  final String texto;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;

  const BotonSecundario({
    super.key,
    required this.texto,
    this.icon,
    this.onPressed,
    this.color = AppColores.primario,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadios.mediano),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            texto,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Botón de peligro/destructivo (rojo)
class BotonPeligro extends StatelessWidget {
  final String texto;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const BotonPeligro({
    super.key,
    required this.texto,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return BotonPrimario(
      texto: texto,
      icon: icon,
      onPressed: onPressed,
      color: AppColores.error,
      isLoading: isLoading,
    );
  }
}
