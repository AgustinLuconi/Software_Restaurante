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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantallaInicioInicial &&
          listEquals(negocios, other.negocios);

  @override
  int get hashCode => Object.hashAll(negocios);
}
