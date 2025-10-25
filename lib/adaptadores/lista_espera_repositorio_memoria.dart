import '../dominio/entidades/entrada_lista_espera.dart';
import '../dominio/repositorios/lista_espera_repositorio.dart';

class ListaEsperaRepositorioMemoria implements ListaEsperaRepositorio {
  final List<EntradaListaEspera> _entradas = [];
  int _contadorId = 1;

  @override
  Future<EntradaListaEspera> agregarALista(
    DateTime fechaDeseada,
    DateTime horaDeseada,
    int numeroPersonas,
    String usuarioId,
  ) async {
    final nuevaEntrada = EntradaListaEspera(
      id: 'entrada_${_contadorId++}',
      usuarioId: usuarioId,
      fechaDeseada: fechaDeseada,
      horaDeseada: horaDeseada,
      numeroPersonas: numeroPersonas,
    );

    _entradas.add(nuevaEntrada);
    return nuevaEntrada;
  }

  @override
  Future<List<EntradaListaEspera>> obtenerEntradasParaSlot(
    DateTime fecha,
    DateTime hora,
  ) async {
    return _entradas.where((entrada) {
      // Comparar solo fecha (año, mes, día)
      final mismaFecha = entrada.fechaDeseada.year == fecha.year &&
          entrada.fechaDeseada.month == fecha.month &&
          entrada.fechaDeseada.day == fecha.day;

      // Comparar solo hora y minutos
      final mismaHora = entrada.horaDeseada.hour == hora.hour &&
          entrada.horaDeseada.minute == hora.minute;

      return mismaFecha && mismaHora;
    }).toList();
  }

  @override
  Future<void> eliminarEntrada(String entradaId) async {
    _entradas.removeWhere((entrada) => entrada.id == entradaId);
  }

  @override
  Future<List<EntradaListaEspera>> obtenerListaDeUsuario(String usuarioId) async {
    return _entradas.where((entrada) => entrada.usuarioId == usuarioId).toList();
  }
}
