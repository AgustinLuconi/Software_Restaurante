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
