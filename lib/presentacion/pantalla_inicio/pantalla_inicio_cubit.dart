import 'package:flutter_bloc/flutter_bloc.dart';

import 'pantalla_inicio_estados_de_cubit.dart';

class PantallaInicioCubit extends Cubit<PantallaInicioState> {
  PantallaInicioCubit() : super(PantallaInicioInitial());

  // Ejemplo de método que cambia el estado
  Future<void> cargarDatos() async {
    try {
      emit(PantallaInicioLoading());
      
      // Simular carga de datos
      await Future.delayed(const Duration(seconds: 1));
      
      emit(PantallaInicioSuccess('Datos cargados correctamente'));
    } catch (e) {
      emit(PantallaInicioError('Error al cargar los datos: $e'));
    }
  }

  // Reiniciar al estado inicial
  void reset() {
    emit(PantallaInicioInitial());
  }
}
