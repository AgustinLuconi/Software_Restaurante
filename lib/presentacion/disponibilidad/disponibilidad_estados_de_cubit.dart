import 'package:flutter/foundation.dart';

import '../../dominio/entidades/mesa.dart';

@immutable
abstract class DisponibilidadState {}

class DisponibilidadInicial extends DisponibilidadState {}

class DisponibilidadCargando extends DisponibilidadState {}

class DisponibilidadExitosa extends DisponibilidadState {
  final List<Mesa> mesasDisponibles;

  DisponibilidadExitosa(this.mesasDisponibles);
}

class DisponibilidadConError extends DisponibilidadState {
  final String mensaje;

  DisponibilidadConError(this.mensaje);
}

class ReservaCreada extends DisponibilidadState {
  final String mensaje;

  ReservaCreada(this.mensaje);
}

/// Estado cuando se encuentra una mesa disponible en la zona seleccionada
class MesaEncontrada extends DisponibilidadState {
  final Mesa mesa;
  final ZonaMesa zona;

  MesaEncontrada(this.mesa, this.zona);
}
