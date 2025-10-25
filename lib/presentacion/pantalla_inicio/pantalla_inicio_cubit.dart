import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';

import 'pantalla_inicio_estados_de_cubit.dart';

class PantallaInicioCubit extends Cubit<PantallaInicioState> {
  final NegocioRepositorio negocioRepositorio;

  PantallaInicioCubit(this.negocioRepositorio) : super(const PantallaInicioInitial()) {
    _cargarNegocios();
  }

  // Cargar negocios existentes
  Future<void> _cargarNegocios() async {
    final negocios = await negocioRepositorio.obtenerTodosLosNegocios();
    emit(PantallaInicioInitial(negocios: negocios));
  }

  // Agregar un nuevo negocio
  Future<Negocio?> registrarNegocio({
    required String nombre,
    required String nombreResponsable,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  }) async {
    final negocio = await negocioRepositorio.registrarNegocio(
      nombre: nombre,
      nombreResponsable: nombreResponsable,
      email: email,
      telefono: telefono,
      direccion: direccion,
      password: password,
    );

    if (negocio != null) {
      await _cargarNegocios();
      return negocio;
    }

    return null;
  }

  // Obtener todos los negocios
  List<Negocio> obtenerNegocios() {
    return state.negocios;
  }

  // Ejemplo de método que cambia el estado
  Future<void> cargarDatos() async {
    try {
      emit(PantallaInicioLoading(negocios: state.negocios));
      
      // Simular carga de datos
      await Future.delayed(const Duration(seconds: 1));
      
      emit(PantallaInicioSuccess('Datos cargados correctamente', negocios: state.negocios));
    } catch (e) {
      emit(PantallaInicioError('Error al cargar los datos: $e', negocios: state.negocios));
    }
  }

  // Reiniciar al estado inicial manteniendo los negocios
  void reset() {
    emit(PantallaInicioInitial(negocios: state.negocios));
  }
}
