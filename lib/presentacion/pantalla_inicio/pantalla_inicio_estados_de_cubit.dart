import 'package:flutter/foundation.dart';
import '../../dominio/entidades/negocio.dart';

// Estados del Cubit
@immutable
abstract class PantallaInicioState {
  final List<Negocio> negocios;
  
  const PantallaInicioState({this.negocios = const []});
}

// Estado inicial
class PantallaInicioInitial extends PantallaInicioState {
  const PantallaInicioInitial({super.negocios});
}

// Estado de carga
class PantallaInicioLoading extends PantallaInicioState {
  const PantallaInicioLoading({super.negocios});
}

// Estado de éxito
class PantallaInicioSuccess extends PantallaInicioState {
  final String message;

  const PantallaInicioSuccess(this.message, {super.negocios});
}

// Estado de error
class PantallaInicioError extends PantallaInicioState {
  final String message;

  const PantallaInicioError(this.message, {super.negocios});
}

// Estado con negocio agregado
class NegocioAgregado extends PantallaInicioState {
  final Negocio negocioNuevo;
  
  const NegocioAgregado(this.negocioNuevo, {super.negocios});
}
