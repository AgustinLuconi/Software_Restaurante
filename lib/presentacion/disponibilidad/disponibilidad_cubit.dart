import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/crear_reserva.dart';
import '../../aplicacion/obtener_mesas_disponibles.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/codigo_verificacion_repositorio.dart';
import '../../dominio/repositorios/horario_apertura_repositorio.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import '../../dominio/servicios/servicio_notificaciones.dart';
import '../../service_locator.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadCubit extends Cubit<DisponibilidadState> {
  final ObtenerMesasDisponibles _obtenerMesasDisponibles;
  final MesaRepositorio _mesaRepositorio;
  final ReservaRepositorio _reservaRepositorio;
  final CrearReserva _crearReserva;
  final ServicioNotificaciones _servicioNotificaciones;
  final CodigoVerificacionRepositorio _codigoVerificacionRepo;
  final HorarioAperturaRepositorio _horarioAperturaRepo;

  DisponibilidadCubit()
      : _obtenerMesasDisponibles = getIt<ObtenerMesasDisponibles>(),
        _mesaRepositorio = getIt<MesaRepositorio>(),
        _reservaRepositorio = getIt<ReservaRepositorio>(),
        _crearReserva = getIt<CrearReserva>(),
        _servicioNotificaciones = getIt<ServicioNotificaciones>(),
        _codigoVerificacionRepo = getIt<CodigoVerificacionRepositorio>(),
        _horarioAperturaRepo = getIt<HorarioAperturaRepositorio>(),
        super(DisponibilidadInicial());

  Future<void> cargarTodasLasMesas() async {
    try {
      emit(DisponibilidadCargando());
      final mesas = await _mesaRepositorio.obtenerMesas();
      emit(DisponibilidadExitosa(mesas));
    } catch (e) {
      emit(DisponibilidadConError('Error al cargar las mesas: ${e.toString()}'));
    }
  }

  Future<void> buscarMesasDisponibles(
    DateTime fecha,
    DateTime hora,
    int numeroPersonas,
  ) async {
    try {
      emit(DisponibilidadCargando());

      final mesas = await _obtenerMesasDisponibles.ejecutar(
        fecha,
        hora,
        numeroPersonas,
      );

      if (mesas.isEmpty) {
        emit(DisponibilidadConError(
          'No hay mesas disponibles para la fecha y hora seleccionadas.',
        ));
      } else {
        emit(DisponibilidadExitosa(mesas));
      }
    } catch (e) {
      emit(DisponibilidadConError('Error al buscar mesas: ${e.toString()}'));
    }
  }

  /// Obtiene las zonas disponibles del restaurante
  Future<List<ZonaMesa>> obtenerZonasDisponibles() async {
    try {
      return await _mesaRepositorio.obtenerZonasDisponibles('negocio_1');
    } catch (e) {
      return [];
    }
  }

  /// Busca automáticamente una mesa disponible en la zona especificada
  Future<void> buscarMesaEnZona({
    required ZonaMesa zona,
    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
  }) async {
    try {
      emit(DisponibilidadCargando());

      final mesa = await _mesaRepositorio.buscarMesaDisponibleEnZona(
        zona: zona,
        fecha: fecha,
        hora: hora,
        numeroPersonas: numeroPersonas,
        negocioId: 'negocio_1',
      );

      if (mesa == null) {
        emit(DisponibilidadConError(
          'No hay mesas disponibles en ${zona.nombre} para $numeroPersonas personas en ese horario.\n\n'
          'Intenta con otra zona o un horario diferente.',
        ));
      } else {
        // Emitir estado con la mesa encontrada
        emit(MesaEncontrada(mesa, zona));
      }
    } catch (e) {
      emit(DisponibilidadConError('Error al buscar mesa: ${e.toString()}'));
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

  /// Obtiene los intervalos de horarios disponibles para una fecha y mesa específica
  /// Retorna un Map donde la clave es el intervalo (ej: "08:00 - 09:00")
  /// y el valor es un booleano indicando si está disponible (true) o no (false)
  Future<Map<String, bool>> obtenerIntervalosDisponibles({
    required DateTime fecha,
    required String mesaId,
  }) async {
    try {
      // Obtener los intervalos del horario del negocio
      final intervalos = await _horarioAperturaRepo.obtenerIntervalosDisponibles(
        'negocio_1',
        fecha,
      );

      // Obtener todas las reservas para esa mesa en esa fecha
      final todasReservas = await _reservaRepositorio.obtenerReserva();
      final reservasMesa = todasReservas.where((r) {
        return r.mesaId == mesaId &&
            r.fechaHora.year == fecha.year &&
            r.fechaHora.month == fecha.month &&
            r.fechaHora.day == fecha.day &&
            (r.estado == EstadoReserva.confirmada || 
             r.estado == EstadoReserva.pendiente);
      }).toList();

      // Crear el mapa de disponibilidad
      final disponibilidad = <String, bool>{};
      
      for (final intervalo in intervalos) {
        // Extraer la hora de inicio del intervalo (ej: "08:00 - 09:00" -> 8)
        final partes = intervalo.split(' - ');
        final horaInicio = int.parse(partes[0].split(':')[0]);
        
        // Verificar si hay alguna reserva en ese horario
        final ocupado = reservasMesa.any((reserva) {
          return reserva.fechaHora.hour == horaInicio;
        });
        
        disponibilidad[intervalo] = !ocupado;
      }
      
      return disponibilidad;
    } catch (e) {
      return {};
    }
  }

  /// Obtiene solo los intervalos horarios del negocio (sin verificar disponibilidad de mesas)
  Future<List<String>> obtenerIntervalosHorarioNegocio(DateTime fecha) async {
    try {
      return await _horarioAperturaRepo.obtenerIntervalosDisponibles(
        'negocio_1',
        fecha,
      );
    } catch (e) {
      return [];
    }
  }

  // Paso 1: Enviar código de verificación
  Future<void> enviarCodigoVerificacion(String contacto) async {
    try {
      await _codigoVerificacionRepo.generarCodigo(contacto: contacto);
      // El estado se mantiene para que el usuario pueda ingresar el código
    } catch (e) {
      emit(DisponibilidadConError('Error al enviar código: ${e.toString()}'));
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
      emit(DisponibilidadCargando());

      // Verificar el código
      final esValido = await _codigoVerificacionRepo.verificarCodigo(
        contacto: contacto,
        codigo: codigo,
      );

      if (!esValido) {
        emit(DisponibilidadConError(
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
      final reserva = await _crearReserva.ejecutar(
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
      // También enviar a cliente_123 para que aparezca en el panel general
      await _servicioNotificaciones.notificarReservaConfirmada('cliente_123', reserva);

      emit(ReservaCreada('✅ Reserva confirmada exitosamente. Recibirás un recordatorio en tu ${contacto.contains('@') ? 'email' : 'teléfono'}.'));
    } catch (e) {
      emit(DisponibilidadConError('Error al crear la reserva: ${e.toString()}'));
    }
  }

  void reiniciar() {
    emit(DisponibilidadInicial());
  }
}

