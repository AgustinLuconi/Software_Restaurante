import 'package:flutter/foundation.dart';
import '../../dominio/entidades/negocio.dart';

// Estados del Cubit
@immutable
abstract class PantallaInicioState {
  final List<Negocio> negocios;
  
  const PantallaInicioState({this.negocios = const []});
}

// Estado inicial
class PantallaInicioInicial extends PantallaInicioState {
  const PantallaInicioInicial({super.negocios});
}

// Estado de carga
class PantallaInicioCargando extends PantallaInicioState {
  const PantallaInicioCargando({super.negocios});
}

// Estado de error
class PantallaInicioConError extends PantallaInicioState {
  final String mensaje;

  const PantallaInicioConError(this.mensaje, {super.negocios});
}
