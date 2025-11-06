import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/crear_reserva.dart';
import '../../aplicacion/obtener_mesas_disponibles.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/codigo_verificacion_repositorio.dart';
import '../../dominio/repositorios/horario_apertura_repositorio.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/servicios/servicio_notificaciones.dart';
import '../../service_locator.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadCubit extends Cubit<DisponibilidadState> {
  final ObtenerMesasDisponibles _obtenerMesasDisponibles;
  final MesaRepositorio _mesaRepositorio;
  final CrearReserva _crearReserva;
  final ServicioNotificaciones _servicioNotificaciones;
  final CodigoVerificacionRepositorio _codigoVerificacionRepo;
  final HorarioAperturaRepositorio _horarioAperturaRepo;

  DisponibilidadCubit()
      : _obtenerMesasDisponibles = getIt<ObtenerMesasDisponibles>(),
        _mesaRepositorio = getIt<MesaRepositorio>(),
        _crearReserva = getIt<CrearReserva>(),
        _servicioNotificaciones = getIt<ServicioNotificaciones>(),
        _codigoVerificacionRepo = getIt<CodigoVerificacionRepositorio>(),
        _horarioAperturaRepo = getIt<HorarioAperturaRepositorio>(),
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

  /// Valida si el horario seleccionado está dentro del horario de apertura
  /// Retorna null si es válido, o un mensaje de error si no lo es
  Future<String?> validarHorarioApertura(DateTime fecha, DateTime hora) async {
    try {
      final fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );

      final estaAbierto = await _horarioAperturaRepo.estaAbiertoEn(
        'negocio_1', // ID del negocio
        fechaHora,
      );

      if (!estaAbierto) {
        final mensajeError = await _horarioAperturaRepo.obtenerMensajeHorarioCerrado(
          'negocio_1',
          fechaHora,
        );
        return mensajeError;
      }

      return null; // Horario válido
    } catch (e) {
      return 'Error al validar horario: ${e.toString()}';
    }
  }

  // Paso 1: Enviar código de verificación
  Future<void> enviarCodigoVerificacion(String contacto) async {
    try {
      await _codigoVerificacionRepo.generarCodigo(contacto: contacto);
      // El estado se mantiene para que el usuario pueda ingresar el código
    } catch (e) {
      emit(DisponibilidadError('Error al enviar código: ${e.toString()}'));
    }
  }

  // Paso 2: Crear reserva con verificación
  Future<void> crearReservaConVerificacion({
    required String contacto,
    required String codigo,
    required String? nombreCliente,
    required String mesaId,
    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
  }) async {
    try {
      emit(DisponibilidadLoading());

      // Verificar el código
      final esValido = await _codigoVerificacionRepo.verificarCodigo(
        contacto: contacto,
        codigo: codigo,
      );

      if (!esValido) {
        emit(DisponibilidadError(
          'Código de verificación inválido o expirado. Por favor, solicita uno nuevo.',
        ));
        return;
      }

      // Marcar código como utilizado
      final codigoObj = await _codigoVerificacionRepo.obtenerCodigoPorContacto(contacto);
      if (codigoObj != null) {
        await _codigoVerificacionRepo.marcarComoUtilizado(codigoObj.id);
      }

      // Crear reserva directamente CONFIRMADA (sin necesidad de aprobación del dueño)
      final reserva = await _crearReserva.execute(
        contacto, // Usar el contacto como clienteId
        mesaId,
        fecha,
        hora,
        numeroPersonas,
        contactoCliente: contacto,
        nombreCliente: nombreCliente,
        estadoInicial: EstadoReserva.confirmada, // CONFIRMADA automáticamente
      );

      // Notificar al dueño sobre la nueva reserva confirmada
      await _servicioNotificaciones.notificarNuevaReservaDueno('negocio_1', reserva);

      // Notificar al cliente que su reserva está confirmada
      await _servicioNotificaciones.notificarReservaConfirmada(contacto, reserva);

      emit(ReservaCreada('✅ Reserva confirmada exitosamente. Recibirás un recordatorio en tu ${contacto.contains('@') ? 'email' : 'teléfono'}.'));
    } catch (e) {
      emit(DisponibilidadError('Error al crear la reserva: ${e.toString()}'));
    }
  }

  void reset() {
    emit(DisponibilidadInitial());
  }
}

