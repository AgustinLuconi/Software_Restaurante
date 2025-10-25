import 'package:flutter_bloc/flutter_bloc.dart';
import '../../aplicacion/agregar_a_lista_de_espera.dart';
import 'lista_espera_estados_de_cubit.dart';

class ListaEsperaCubit extends Cubit<ListaEsperaState> {
  final AgregarAListaDeEspera agregarAListaDeEsperaUseCase;

  ListaEsperaCubit(this.agregarAListaDeEsperaUseCase)
      : super(const ListaEsperaInicial());

  Future<void> agregarALista({
    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
    required String usuarioId,
  }) async {
    try {
      // Emitir estado de carga
      emit(const ListaEsperaAgregando());

      // Llamar al caso de uso
      final entrada = await agregarAListaDeEsperaUseCase.ejecutar(
        fechaDeseada: fecha,
        horaDeseada: hora,
        numeroPersonas: numeroPersonas,
        usuarioId: usuarioId,
      );

      // Emitir estado de éxito
      emit(ListaEsperaAgregada(entrada));
    } catch (e) {
      // Emitir estado de error
      emit(ListaEsperaError(e.toString()));
    }
  }

  void reiniciar() {
    emit(const ListaEsperaInicial());
  }
}
