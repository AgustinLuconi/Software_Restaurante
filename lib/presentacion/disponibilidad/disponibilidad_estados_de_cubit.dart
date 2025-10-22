import 'package:flutter/foundation.dart';

import '../../dominio/entidades/mesa.dart';

@immutable
abstract class DisponibilidadState {}

class DisponibilidadInitial extends DisponibilidadState {}

class DisponibilidadLoading extends DisponibilidadState {}

class DisponibilidadSuccess extends DisponibilidadState {
  final List<Mesa> mesasDisponibles;

  DisponibilidadSuccess(this.mesasDisponibles);
}

class DisponibilidadError extends DisponibilidadState {
  final String message;

  DisponibilidadError(this.message);
}

class ReservaCreada extends DisponibilidadState {
  final String message;

  ReservaCreada(this.message);
}
