import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/crear_reserva.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/codigo_verificacion_repositorio.dart';
import '../../dominio/repositorios/horario_apertura_repositorio.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../dominio/servicios/servicio_notificaciones.dart';
import '../../service_locator.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadCubit extends Cubit<DisponibilidadState> {
  final MesaRepositorio _mesaRepositorio;
  final NegocioRepositorio _negocioRepositorio;
  final CrearReserva _crearReserva;
  final ServicioNotificaciones _servicioNotificaciones;
  final CodigoVerificacionRepositorio _codigoVerificacionRepo;
  final HorarioAperturaRepositorio _horarioAperturaRepo;

  /// Negocio cacheado para acceso rápido
  Negocio? _negocioActual;
  Negocio? get negocioActual => _negocioActual;

  DisponibilidadCubit()
      : _mesaRepositorio = getIt<MesaRepositorio>(),
        _negocioRepositorio = getIt<NegocioRepositorio>(),
        _crearReserva = getIt<CrearReserva>(),
        _servicioNotificaciones = getIt<ServicioNotificaciones>(),
        _codigoVerificacionRepo = getIt<CodigoVerificacionRepositorio>(),
        _horarioAperturaRepo = getIt<HorarioAperturaRepositorio>(),
        super(DisponibilidadInicial());

  Future<void> cargarTodasLasMesas() async {
    try {
      emit(DisponibilidadCargando());
      
      // Cargar mesas, negocio y horarios en paralelo
      final resultados = await Future.wait([
        _mesaRepositorio.obtenerMesas(),
        _negocioRepositorio.obtenerNegocioPorId('negocio_1'),
        _negocioRepositorio.obtenerHorariosServicio('negocio_1'),
      ]);
      
      final mesas = resultados[0] as List<Mesa>;
      _negocioActual = resultados[1] as Negocio?;
      final horarios = resultados[2] as Map<String, String>;
      
      emit(DisponibilidadExitosa(mesas, negocio: _negocioActual, horariosServicio: horarios));
    } catch (e) {
      emit(DisponibilidadConError('Error al cargar los datos: ${e.toString()}'));
    }
  }

  /// Carga inicial de datos (mesas + configuración del negocio + horarios)
  Future<void> cargarDatosIniciales({String negocioId = 'negocio_1'}) async {
    try {
      emit(DisponibilidadCargando());
      
      final resultados = await Future.wait([
        _mesaRepositorio.obtenerMesas(),
        _negocioRepositorio.obtenerNegocioPorId(negocioId),
        _negocioRepositorio.obtenerHorariosServicio(negocioId),
      ]);
      
      final mesas = resultados[0] as List<Mesa>;
      _negocioActual = resultados[1] as Negocio?;
      final horarios = resultados[2] as Map<String, String>;
      
      emit(DisponibilidadExitosa(mesas, negocio: _negocioActual, horariosServicio: horarios));
    } catch (e) {
      emit(DisponibilidadConError('Error al cargar los datos: ${e.toString()}'));
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

  /// Obtiene los intervalos horarios del negocio para una fecha
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
}

