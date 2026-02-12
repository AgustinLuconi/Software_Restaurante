import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';

import 'pantalla_inicio_estados_de_cubit.dart';

class PantallaInicioCubit extends Cubit<PantallaInicioState> {
  final NegocioRepositorio negocioRepositorio;

  PantallaInicioCubit(this.negocioRepositorio) : super(const PantallaInicioInicial()) {
    _cargarNegocios();
  }

  // Cargar negocios existentes
  Future<void> _cargarNegocios() async {
    final negocios = await negocioRepositorio.obtenerTodosLosNegocios();
    emit(PantallaInicioInicial(negocios: negocios));
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
}
