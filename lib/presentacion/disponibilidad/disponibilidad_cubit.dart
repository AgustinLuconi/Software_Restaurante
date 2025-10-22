import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/crear_reserva.dart';
import '../../aplicacion/obtener_mesas_disponibles.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../service_locator.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadCubit extends Cubit<DisponibilidadState> {
  final ObtenerMesasDisponibles _obtenerMesasDisponibles;
  final MesaRepositorio _mesaRepositorio;
  final CrearReserva _crearReserva;

  DisponibilidadCubit()
      : _obtenerMesasDisponibles = getIt<ObtenerMesasDisponibles>(),
        _mesaRepositorio = getIt<MesaRepositorio>(),
        _crearReserva = getIt<CrearReserva>(),
        super(DisponibilidadInitial());

  Future<void> cargarTodasLasMesas() async {
    try {
      emit(DisponibilidadLoading());
      final mesas = await _mesaRepositorio.obtenerMesas();
      emit(DisponibilidadSuccess(mesas));
    } catch (e) {
      emit(DisponibilidadError('Error al cargar las mesas: ${e.toString()}'));
    }
  }

  Future<void> buscarMesasDisponibles(
    DateTime fecha,
    DateTime hora,
    int numeroPersonas,
  ) async {
    try {
      emit(DisponibilidadLoading());

      final mesas = await _obtenerMesasDisponibles.execute(
        fecha,
        hora,
        numeroPersonas,
      );

      if (mesas.isEmpty) {
        emit(DisponibilidadError(
          'No hay mesas disponibles para la fecha y hora seleccionadas.',
        ));
      } else {
        emit(DisponibilidadSuccess(mesas));
      }
    } catch (e) {
      emit(DisponibilidadError('Error al buscar mesas: ${e.toString()}'));
    }
  }

  Future<void> crearReserva(
    String clienteId,
    String mesaId,
    DateTime fecha,
    DateTime hora,
    int numeroPersonas,
  ) async {
    try {
      await _crearReserva.execute(clienteId, mesaId, fecha, hora, numeroPersonas);
      emit(ReservaCreada('Reserva creada exitosamente'));
    } catch (e) {
      emit(DisponibilidadError('Error al crear la reserva: ${e.toString()}'));
    }
  }

  void reset() {
    emit(DisponibilidadInitial());
  }
}
