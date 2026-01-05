import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../service_locator.dart';
import 'pantalla_restaurante_estados_de_cubit.dart';

class PantallaRestauranteCubit extends Cubit<PantallaRestauranteState> {
  final NegocioRepositorio _negocioRepositorio;

  PantallaRestauranteCubit()
      : _negocioRepositorio = getIt<NegocioRepositorio>(),
        super(PantallaRestauranteInicial());

  /// Carga los datos del negocio (info + horarios)
  Future<void> cargarDatosNegocio({String negocioId = 'negocio_1'}) async {
    try {
      emit(PantallaRestauranteCargando());

      final resultados = await Future.wait([
        _negocioRepositorio.obtenerNegocioPorId(negocioId),
        _negocioRepositorio.obtenerHorariosServicio(negocioId),
      ]);

      final negocio = resultados[0] as dynamic;
      final horarios = resultados[1] as Map<String, String>;

      if (negocio == null) {
        emit(PantallaRestauranteConError('No se encontró el negocio'));
        return;
      }

      emit(PantallaRestauranteExitoso(
        negocio: negocio,
        horariosAtencion: horarios,
      ));
    } catch (e) {
      emit(PantallaRestauranteConError('Error al cargar datos: ${e.toString()}'));
    }
  }

  // Reiniciar al estado inicial
  void reiniciar() {
    emit(PantallaRestauranteInicial());
  }
}
