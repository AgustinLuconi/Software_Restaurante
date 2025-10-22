import 'package:flutter/foundation.dart';

// Estados del Cubit
@immutable
abstract class PantallaInicioState {}

// Estado inicial
class PantallaInicioInitial extends PantallaInicioState {}

// Estado de carga
class PantallaInicioLoading extends PantallaInicioState {}

// Estado de éxito
class PantallaInicioSuccess extends PantallaInicioState {
  final String message;

  PantallaInicioSuccess(this.message);
}

// Estado de error
class PantallaInicioError extends PantallaInicioState {
  final String message;

  PantallaInicioError(this.message);
}
