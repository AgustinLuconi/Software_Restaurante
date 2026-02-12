import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dominio/repositorios/horario_apertura_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../service_locator.dart';
import 'pantalla_restaurante_estados_de_cubit.dart';

class PantallaRestauranteCubit extends Cubit<PantallaRestauranteState> {
  final NegocioRepositorio _negocioRepositorio;
  final HorarioAperturaRepositorio _horarioAperturaRepo;
  
  /// ID del negocio actual (se carga dinámicamente)
  String? _negocioId;

  PantallaRestauranteCubit()
      : _negocioRepositorio = getIt<NegocioRepositorio>(),
        _horarioAperturaRepo = getIt<HorarioAperturaRepositorio>(),
        super(PantallaRestauranteInicial());

  /// Carga los datos del negocio (info + horarios)
  Future<void> cargarDatosNegocio({String? negocioId}) async {
    try {
      emit(PantallaRestauranteCargando());
      
      // Si no tenemos negocioId, cargar el primer negocio disponible
      if (negocioId == null && _negocioId == null) {
        final negocios = await _negocioRepositorio.obtenerTodosLosNegocios();
        if (negocios.isNotEmpty) {
          negocioId = negocios.first.id;
        }
      }

      // Usar el negocioId proporcionado o el actual
      final id = negocioId ?? _negocioId;
      if (id == null) {
        emit(PantallaRestauranteConError('No hay negocios registrados'));
        return;
      }
      _negocioId = id;

      // Cargar negocio y horarios en paralelo
      final negocioFuture = _negocioRepositorio.obtenerNegocioPorId(id);
      final horarioFuture = _horarioAperturaRepo.obtenerHorarioPorNegocio(id);

      final negocio = await negocioFuture;
      final horario = await horarioFuture;

      if (negocio == null) {
        emit(PantallaRestauranteConError('No se encontró el negocio'));
        return;
      }

      // Convertir horario a Map<String, String> para la UI
      final horariosMap = horario != null
          ? _horarioAperturaRepo.horarioAMapString(horario)
          : <String, String>{};

      emit(PantallaRestauranteExitoso(
        negocio: negocio,
        horarios: horariosMap,
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
