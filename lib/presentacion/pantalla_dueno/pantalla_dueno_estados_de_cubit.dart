import '../../dominio/entidades/negocio.dart';

abstract class PantallaDuenoState {
  const PantallaDuenoState();
}

class PantallaDuenoInicial extends PantallaDuenoState {
  const PantallaDuenoInicial();

  @override
  bool operator ==(Object other) => other is PantallaDuenoInicial;

  @override
  int get hashCode => runtimeType.hashCode;
}

class PantallaDuenoCargando extends PantallaDuenoState {
  const PantallaDuenoCargando();

  @override
  bool operator ==(Object other) => other is PantallaDuenoCargando;

  @override
  int get hashCode => runtimeType.hashCode;
}

class PantallaDuenoAutenticado extends PantallaDuenoState {
  final Negocio negocio;

  const PantallaDuenoAutenticado(this.negocio);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantallaDuenoAutenticado && negocio.id == other.negocio.id;

  @override
  int get hashCode => negocio.id.hashCode;
}

class PantallaDuenoConError extends PantallaDuenoState {
  final String mensaje;

  const PantallaDuenoConError(this.mensaje);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantallaDuenoConError && mensaje == other.mensaje;

  @override
  int get hashCode => mensaje.hashCode;
}
