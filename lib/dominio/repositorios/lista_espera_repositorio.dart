import '../entidades/entrada_lista_espera.dart';

abstract class ListaEsperaRepositorio {
  Future<EntradaListaEspera> agregarALista(
    DateTime fechaDeseada,
    DateTime horaDeseada,
    int numeroPersonas,
    String usuarioId,
  );

  Future<List<EntradaListaEspera>> obtenerEntradasParaSlot(
    DateTime fecha,
    DateTime hora,
  );

  Future<void> eliminarEntrada(String entradaId);

  Future<List<EntradaListaEspera>> obtenerListaDeUsuario(String usuarioId);
}
