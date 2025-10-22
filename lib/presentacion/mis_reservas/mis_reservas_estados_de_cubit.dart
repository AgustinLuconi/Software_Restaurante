import 'package:flutter/foundation.dart';

import '../../dominio/entidades/reserva.dart';

@immutable
abstract class MisReservasState {}

class MisReservasInitial extends MisReservasState {}

class MisReservasLoading extends MisReservasState {}

class MisReservasSuccess extends MisReservasState {
  final List<Reserva> reservas;

  MisReservasSuccess(this.reservas);
}

class MisReservasError extends MisReservasState {
  final String message;

  MisReservasError(this.message);
}

class ReservaCancelada extends MisReservasState {
  final String message;

  ReservaCancelada(this.message);
}
