import '../dominio/repositorios/lista_espera_repositorio.dart';
import '../dominio/entidades/entrada_lista_espera.dart';

class AgregarAListaDeEspera {
  final ListaEsperaRepositorio listaEsperaRepositorio;

  AgregarAListaDeEspera(this.listaEsperaRepositorio);

  Future<EntradaListaEspera> ejecutar({
    required DateTime fechaDeseada,
    required DateTime horaDeseada,
    required int numeroPersonas,
    required String usuarioId,
  }) async {
    // Validar que la fecha no sea en el pasado
    final ahora = DateTime.now();
    final fechaHoraDeseada = DateTime(
      fechaDeseada.year,
      fechaDeseada.month,
      fechaDeseada.day,
      horaDeseada.hour,
      horaDeseada.minute,
    );

    if (fechaHoraDeseada.isBefore(ahora)) {
      throw Exception('No puedes agregar una entrada a la lista de espera para una fecha/hora pasada');
    }

    // Validar número de personas
    if (numeroPersonas <= 0) {
      throw Exception('El número de personas debe ser mayor a 0');
    }

    if (numeroPersonas > 20) {
      throw Exception('El número máximo de personas por reserva es 20');
    }

    // Verificar si el usuario ya está en la lista para ese horario
    final entradasExistentes = await listaEsperaRepositorio.obtenerEntradasParaSlot(
      fechaDeseada,
      horaDeseada,
    );

    final yaRegistrado = entradasExistentes.any((entrada) => entrada.usuarioId == usuarioId);

    if (yaRegistrado) {
      throw Exception('Ya estás registrado en la lista de espera para este horario');
    }

    // Agregar a la lista de espera
    return await listaEsperaRepositorio.agregarALista(
      fechaDeseada,
      horaDeseada,
      numeroPersonas,
      usuarioId,
    );
  }
}
