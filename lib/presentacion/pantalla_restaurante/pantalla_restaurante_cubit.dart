import 'package:flutter_bloc/flutter_bloc.dart';

import 'pantalla_restaurante_estados_de_cubit.dart';

class PantallaRestauranteCubit extends Cubit<PantallaRestauranteState> {
  PantallaRestauranteCubit() : super(PantallaRestauranteInitial());

  // Ejemplo de método que cambia el estado
  Future<void> cargarDatos() async {
    try {
      emit(PantallaRestauranteLoading());
      
      // Simular carga de datos
      await Future.delayed(const Duration(seconds: 1));
      
      emit(PantallaRestauranteSuccess('Datos cargados correctamente'));
    } catch (e) {
      emit(PantallaRestauranteError('Error al cargar los datos: $e'));
    }
  }

  // Reiniciar al estado inicial
  void reset() {
    emit(PantallaRestauranteInitial());
  }
}
