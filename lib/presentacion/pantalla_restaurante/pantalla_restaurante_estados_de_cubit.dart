import 'package:flutter/foundation.dart';

// Estados del Cubit
@immutable
abstract class PantallaRestauranteState {}

// Estado inicial
class PantallaRestauranteInitial extends PantallaRestauranteState {}

// Estado de carga
class PantallaRestauranteLoading extends PantallaRestauranteState {}

// Estado de éxito
class PantallaRestauranteSuccess extends PantallaRestauranteState {
  final String message;

  PantallaRestauranteSuccess(this.message);
}

// Estado de error
class PantallaRestauranteError extends PantallaRestauranteState {
  final String message;

  PantallaRestauranteError(this.message);
}
