import 'package:flutter/foundation.dart';

import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';

@immutable
abstract class DisponibilidadState {}

class DisponibilidadInicial extends DisponibilidadState {}

class DisponibilidadCargando extends DisponibilidadState {}

class DisponibilidadExitosa extends DisponibilidadState {
  final List<Mesa> mesasDisponibles;
  final Negocio? negocio;
  final Map<String, String>? horariosServicio;

  DisponibilidadExitosa(this.mesasDisponibles, {this.negocio, this.horariosServicio});

  /// Duración promedio de reserva en minutos (default: 60)
  int get duracionPromedioMinutos => negocio?.duracionPromedioMinutos ?? 60;

  /// Máximos días de anticipación para reservar (default: 14)
  int get maxDiasAnticipacionReserva => negocio?.maxDiasAnticipacionReserva ?? 14;

  /// Mínimas horas para cancelar (default: 24)
  int get minHorasParaCancelar => negocio?.minHorasParaCancelar ?? 24;
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
  final String zona;
  final int duracionPromedioMinutos;

  MesaEncontrada(this.mesa, this.zona, this.duracionPromedioMinutos);
}

/// Estado mientras se procesa la creación de la reserva (post-verificación SMS)
class ProcesandoReserva extends DisponibilidadState {}

