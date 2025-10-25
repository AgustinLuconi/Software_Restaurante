import '../../dominio/entidades/negocio.dart';

abstract class PantallaDuenoState {
  const PantallaDuenoState();
}

class PantallaDuenoInitial extends PantallaDuenoState {
  const PantallaDuenoInitial();
}

class PantallaDuenoLoading extends PantallaDuenoState {
  const PantallaDuenoLoading();
}

class PantallaDuenoAutenticado extends PantallaDuenoState {
  final Negocio negocio;

  const PantallaDuenoAutenticado(this.negocio);
}

class PantallaDuenoError extends PantallaDuenoState {
  final String mensaje;

  const PantallaDuenoError(this.mensaje);
}
