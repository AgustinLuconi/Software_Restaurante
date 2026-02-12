import 'package:flutter/foundation.dart';

import '../../dominio/entidades/negocio.dart';

// Estados del Cubit
@immutable
abstract class PantallaRestauranteState {}

// Estado inicial (cargando)
class PantallaRestauranteInicial extends PantallaRestauranteState {}

// Estado cargando
class PantallaRestauranteCargando extends PantallaRestauranteState {}

// Estado exitoso con datos del negocio
class PantallaRestauranteExitoso extends PantallaRestauranteState {
  final Negocio negocio;
  final Map<String, String> horarios;

  PantallaRestauranteExitoso({
    required this.negocio,
    required this.horarios,
  });
}

// Estado de error
class PantallaRestauranteConError extends PantallaRestauranteState {
  final String mensaje;

  PantallaRestauranteConError(this.mensaje);
}
