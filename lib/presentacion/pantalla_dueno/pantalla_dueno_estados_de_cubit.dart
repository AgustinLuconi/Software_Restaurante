import '../../dominio/entidades/negocio.dart';

abstract class PantallaDuenoState {
  const PantallaDuenoState();
}

class PantallaDuenoInicial extends PantallaDuenoState {
  const PantallaDuenoInicial();
}

class PantallaDuenoCargando extends PantallaDuenoState {
  const PantallaDuenoCargando();
}

class PantallaDuenoAutenticado extends PantallaDuenoState {
  final Negocio negocio;

  const PantallaDuenoAutenticado(this.negocio);
}

class PantallaDuenoConError extends PantallaDuenoState {
  final String mensaje;

  const PantallaDuenoConError(this.mensaje);
}
