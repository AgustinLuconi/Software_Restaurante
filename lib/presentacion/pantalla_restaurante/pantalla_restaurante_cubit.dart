import 'package:flutter_bloc/flutter_bloc.dart';

import 'pantalla_restaurante_estados_de_cubit.dart';

class PantallaRestauranteCubit extends Cubit<PantallaRestauranteState> {
  PantallaRestauranteCubit() : super(PantallaRestauranteInicial());

  // Ejemplo de método que cambia el estado
  Future<void> cargarDatos() async {
    try {
      emit(PantallaRestauranteCargando());
      
      // Simular carga de datos
      await Future.delayed(const Duration(seconds: 1));
      
      emit(PantallaRestauranteExitoso('Datos cargados correctamente'));
    } catch (e) {
      emit(PantallaRestauranteConError('Error al cargar los datos: $e'));
    }
  }

  // Reiniciar al estado inicial
  void reiniciar() {
    emit(PantallaRestauranteInicial());
  }
}
