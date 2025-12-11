import 'package:flutter/foundation.dart';

// Estados del Cubit
@immutable
abstract class PantallaRestauranteState {}

// Estado inicial
class PantallaRestauranteInicial extends PantallaRestauranteState {}

// Estado de carga
class PantallaRestauranteCargando extends PantallaRestauranteState {}

// Estado de éxito
class PantallaRestauranteExitoso extends PantallaRestauranteState {
  final String mensaje;

  PantallaRestauranteExitoso(this.mensaje);
}

// Estado de error
class PantallaRestauranteConError extends PantallaRestauranteState {
  final String mensaje;

  PantallaRestauranteConError(this.mensaje);
}
