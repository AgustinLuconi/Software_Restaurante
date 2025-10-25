import '../../dominio/entidades/entrada_lista_espera.dart';

abstract class ListaEsperaState {
  const ListaEsperaState();
}

class ListaEsperaInicial extends ListaEsperaState {
  const ListaEsperaInicial();
}

class ListaEsperaAgregando extends ListaEsperaState {
  const ListaEsperaAgregando();
}

class ListaEsperaAgregada extends ListaEsperaState {
  final EntradaListaEspera entrada;

  const ListaEsperaAgregada(this.entrada);
}

class ListaEsperaError extends ListaEsperaState {
  final String mensaje;

  const ListaEsperaError(this.mensaje);
}
