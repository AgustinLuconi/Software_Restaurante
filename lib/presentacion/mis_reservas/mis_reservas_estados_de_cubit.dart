import 'package:flutter/foundation.dart';

import '../../dominio/entidades/reserva.dart';

@immutable
abstract class MisReservasState {}

class MisReservasInicial extends MisReservasState {}

class MisReservasCargando extends MisReservasState {}

class MisReservasExitoso extends MisReservasState {
  final List<Reserva> reservas;

  MisReservasExitoso(this.reservas);
}

class MisReservasConError extends MisReservasState {
  final String mensaje;

  MisReservasConError(this.mensaje);
}

class ReservaCancelada extends MisReservasState {
  final String mensaje;

  ReservaCancelada(this.mensaje);
}
