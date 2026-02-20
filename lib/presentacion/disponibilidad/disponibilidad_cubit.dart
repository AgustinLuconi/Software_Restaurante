import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/crear_reserva.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/horario_apertura_repositorio.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../service_locator.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadCubit extends Cubit<DisponibilidadState> {
  final MesaRepositorio _mesaRepositorio;
  final NegocioRepositorio _negocioRepositorio;
  final CrearReserva _crearReserva;
  final HorarioAperturaRepositorio _horarioAperturaRepo;

  /// Negocio cacheado para acceso rápido
  Negocio? _negocioActual;
  Negocio? get negocioActual => _negocioActual;

  DisponibilidadCubit()
    : _mesaRepositorio = getIt<MesaRepositorio>(),
      _negocioRepositorio = getIt<NegocioRepositorio>(),
      _crearReserva = getIt<CrearReserva>(),
      _horarioAperturaRepo = getIt<HorarioAperturaRepositorio>(),
      super(DisponibilidadInicial());

  /// ID del negocio actual (se carga dinámicamente)
  String? _negocioId;

  Future<void> cargarTodasLasMesas([String? negocioId]) async {
    try {
      emit(DisponibilidadCargando());
      
      // Si nos pasan un ID explícito, usarlo
      if (negocioId != null) {
        _negocioId = negocioId;
      }

      // Si no tenemos negocioId, cargar el primer negocio disponible
      if (_negocioId == null) {
        final negocios = await _negocioRepositorio.obtenerTodosLosNegocios();
        if (negocios.isNotEmpty) {
          _negocioId = negocios.first.id;
          _negocioActual = negocios.first;
        }
      }

      if (_negocioId == null) {
        emit(DisponibilidadConError('No hay negocios registrados'));
        return;
      }

      // Cargar mesas, negocio y horarios en paralelo
      final resultados = await Future.wait([
        _mesaRepositorio.obtenerMesasPorNegocio(_negocioId!),
        _negocioRepositorio.obtenerNegocioPorId(_negocioId!),
        _horarioAperturaRepo.obtenerHorarioPorNegocio(_negocioId!),
      ]);

      final mesas = resultados[0] as List<Mesa>;
      _negocioActual = resultados[1] as Negocio?;
      final horario = resultados[2] as dynamic;
      final horarios = horario != null
          ? _horarioAperturaRepo.horarioAMapString(horario)
          : <String, String>{};

      emit(
        DisponibilidadExitosa(
          mesas,
          negocio: _negocioActual,
          horariosServicio: horarios,
        ),
      );
    } catch (e) {
      emit(
        DisponibilidadConError('Error al cargar los datos: ${e.toString()}'),
      );
    }
  }

  /// Obtiene las zonas disponibles del restaurante
  Future<List<String>> obtenerZonasDisponibles() async {
    try {
      final nid = _negocioActual?.id ?? _negocioId;
      if (nid == null) return [];
      return await _mesaRepositorio.obtenerZonasDisponibles(nid);
    } catch (e) {
      return [];
    }
  }

  /// Busca automáticamente una mesa disponible en la zona especificada
  Future<void> buscarMesaEnZona({
    required String zona,

    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
  }) async {
    try {
      emit(DisponibilidadCargando());

      final negocioId = _negocioActual?.id ?? _negocioId ?? 'default';
      final mesa = await _mesaRepositorio.buscarMesaDisponibleEnZona(
        zona: zona,
        fecha: fecha,
        hora: hora,
        numeroPersonas: numeroPersonas,
        negocioId: negocioId,
      );

      if (mesa == null) {
        emit(
          DisponibilidadConError(
            'No hay mesas disponibles en $zona para $numeroPersonas personas en ese horario.\n\n'
            'Intenta con otra zona o un horario diferente.',
          ),
        );
      } else {
        // Emitir estado con la mesa encontrada y la duración configurada
        emit(
          MesaEncontrada(
            mesa,
            zona,
            _negocioActual?.duracionPromedioMinutos ?? 60,
          ),
        );
      }
    } catch (e) {
      emit(DisponibilidadConError('Error al buscar mesa: ${e.toString()}'));
    }
  }

  /// Obtiene los intervalos horarios del negocio para una fecha
  Future<List<String>> obtenerIntervalosHorarioNegocio(DateTime fecha) async {
    try {
      final id = _negocioActual?.id ?? _negocioId;
      if (id == null) return [];
      
      return await _horarioAperturaRepo.obtenerIntervalosDisponibles(
        id,
        fecha,
        intervaloMinutos: _negocioActual?.duracionPromedioMinutos ?? 60,
      );
    } catch (e) {
      return [];
    }
  }

  /// Crear reserva ya verificada por SMS de Firebase
  /// Este método se usa cuando el cliente ya verificó su teléfono por SMS
  /// y no necesita verificación adicional con código interno.
  Future<void> crearReservaVerificadaPorSMS({
    required String emailCliente,
    required String telefonoVerificado,
    required String? nombreCliente,
    required String mesaId,
    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
  }) async {
    try {
      emit(ProcesandoReserva());
      
      print('🔄 Creando reserva verificada por SMS...');
      print('   📧 Email: $emailCliente');
      print('   📱 Teléfono: $telefonoVerificado');
      print('   👤 Nombre: $nombreCliente');
      print('   🪑 Mesa: $mesaId');
      print('   📅 Fecha: $fecha');
      print('   🕐 Hora: $hora');
      print('   👥 Personas: $numeroPersonas');

      // Crear reserva directamente CONFIRMADA (ya fue verificado por SMS)
      // El caso de uso CrearReserva se encarga de:
      //   1. Validar reglas de negocio
      //   2. Guardar en Firestore con estado confirmada
      //   3. Enviar emails de confirmación al cliente y al dueño
      final negocioId = _negocioActual?.id ?? _negocioId ?? 'default';
      final reserva = await _crearReserva.ejecutar(
        mesaId,
        fecha,
        hora,
        numeroPersonas,
        contactoCliente: emailCliente,
        nombreCliente: nombreCliente,
        telefonoCliente: telefonoVerificado,
        estadoInicial: EstadoReserva.confirmada,
        negocioId: negocioId,
      );
      
      print('✅ Reserva creada con ID: ${reserva.id}');
      print('✅ Proceso de reserva completado exitosamente');

      emit(
        ReservaCreada(
          '✅ Reserva confirmada exitosamente. Recibirás los detalles en tu email.',
        ),
      );
    } catch (e) {
      print('❌ Error creando reserva: $e');
      emit(
        DisponibilidadConError('Error al crear la reserva: ${e.toString()}'),
      );
    }
  }
}
