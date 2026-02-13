import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/entidades/zona.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../dominio/repositorios/horario_apertura_repositorio.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import '../../dominio/repositorios/zona_repositorio.dart';
import '../../adaptadores/servicio_email.dart';
import 'pantalla_dueno_estados_de_cubit.dart';

class PantallaDuenoCubit extends Cubit<PantallaDuenoState> {
  final NegocioRepositorio _negocioRepositorio;
  final MesaRepositorio _mesaRepositorio;
  final ReservaRepositorio _reservaRepositorio;
  final ServicioEmail _servicioEmail;
  final HorarioAperturaRepositorio _horarioAperturaRepositorio;
  final ZonaRepositorio _zonaRepositorio;

  PantallaDuenoCubit(
    this._negocioRepositorio,
    this._mesaRepositorio,
    this._reservaRepositorio,
    this._servicioEmail,
    this._horarioAperturaRepositorio,
    this._zonaRepositorio,
  ) : super(const PantallaDuenoInicial());

  // Método para establecer un negocio autenticado directamente
  void establecerNegocioAutenticado(Negocio negocio) {
    emit(PantallaDuenoAutenticado(negocio));
  }

  Future<void> autenticar(String email, String password) async {
    try {
      emit(const PantallaDuenoCargando());

      final negocio = await _negocioRepositorio.autenticarNegocio(
        email: email,
        password: password,
      );

      if (negocio != null) {
        emit(PantallaDuenoAutenticado(negocio));
      } else {
        emit(const PantallaDuenoConError('Email o contraseña incorrectos'));
      }
    } catch (e) {
      emit(PantallaDuenoConError('Error al autenticar: $e'));
    }
  }

  void cerrarSesion() {
    emit(const PantallaDuenoInicial());
  }

  /// Autentica y retorna el negocio sin emitir estado (para uso desde otras pantallas)
  Future<Negocio?> autenticarYObtener(String email, String password) async {
    try {
      return await _negocioRepositorio.autenticarNegocio(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }

  /// Busca un negocio por email
  Future<Negocio?> obtenerNegocioPorEmail(String email) async {
    try {
      return await _negocioRepositorio.obtenerNegocioPorEmail(email);
    } catch (e) {
      return null;
    }
  }

  Future<bool> actualizarTelefono(Negocio negocio, String nuevoTelefono) async {
    try {
      final negocioActualizado = negocio.copyWith(telefono: nuevoTelefono);
      final exito = await _negocioRepositorio.actualizarNegocio(
        negocioActualizado,
      );

      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }

      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar teléfono: $e'));
      return false;
    }
  }

  Future<bool> actualizarEspecialidad(
    Negocio negocio,
    String nuevaEspecialidad,
  ) async {
    try {
      final negocioActualizado = negocio.copyWith(
        especialidad: nuevaEspecialidad,
      );
      final exito = await _negocioRepositorio.actualizarNegocio(
        negocioActualizado,
      );

      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }

      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar especialidad: $e'));
      return false;
    }
  }

  Future<bool> actualizarNombre(Negocio negocio, String nuevoNombre) async {
    try {
      final negocioActualizado = negocio.copyWith(nombre: nuevoNombre);
      final exito = await _negocioRepositorio.actualizarNegocio(
        negocioActualizado,
      );

      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }

      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar nombre: $e'));
      return false;
    }
  }

  Future<bool> actualizarIcono(Negocio negocio, String nuevoIcono) async {
    try {
      final negocioActualizado = negocio.copyWith(icono: nuevoIcono);
      final exito = await _negocioRepositorio.actualizarNegocio(
        negocioActualizado,
      );

      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }

      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar icono: $e'));
      return false;
    }
  }

  Future<bool> actualizarDescripcion(
    Negocio negocio,
    String nuevaDescripcion,
  ) async {
    try {
      final negocioActualizado = negocio.copyWith(
        descripcion: nuevaDescripcion,
      );
      final exito = await _negocioRepositorio.actualizarNegocio(
        negocioActualizado,
      );

      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }

      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar descripción: $e'));
      return false;
    }
  }

  Future<Map<String, String>> obtenerHorarios(String negocioId) async {
    final horario = await _horarioAperturaRepositorio.obtenerHorarioPorNegocio(
      negocioId,
    );
    if (horario == null) return {};
    return _horarioAperturaRepositorio.horarioAMapString(horario);
  }

  Future<bool> actualizarHorarios(
    String negocioId,
    Map<String, String> horarios,
  ) async {
    try {
      final horario = _horarioAperturaRepositorio.mapStringAHorario(
        negocioId,
        horarios,
      );
      return await _horarioAperturaRepositorio.guardarHorario(horario);
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar horarios: $e'));
      return false;
    }
  }

  // Nuevo método para actualizar la configuración de reglas de negocio
  Future<bool> actualizarConfiguracionReglas(
    Negocio negocio, {
    required int duracionPromedioMinutos,
    required int minHorasParaCancelar,
    required int maxDiasAnticipacionReserva,
  }) async {
    try {
      final negocioActualizado = negocio.copyWith(
        duracionPromedioMinutos: duracionPromedioMinutos,
        minHorasParaCancelar: minHorasParaCancelar,
        maxDiasAnticipacionReserva: maxDiasAnticipacionReserva,
      );

      final exito = await _negocioRepositorio.actualizarNegocio(
        negocioActualizado,
      );

      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }

      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar configuración: $e'));
      return false;
    }
  }

  // Métodos para gestión de mesas
  Future<List<Mesa>> obtenerMesasDelNegocio(String negocioId) async {
    return await _mesaRepositorio.obtenerMesasPorNegocio(negocioId);
  }

  Future<Mesa?> agregarMesa(
    String negocioId,
    String nombre,
    int capacidad,
    String zonaId,
  ) async {
    try {
      final nuevaMesa = Mesa(
        id: '', // Se generará en el repositorio
        nombre: nombre,
        capacidad: capacidad,
        negocioId: negocioId,
        zonaId: zonaId,
      );
      return await _mesaRepositorio.agregarMesa(nuevaMesa);
    } catch (e) {
      emit(PantallaDuenoConError('Error al agregar mesa: $e'));
      return null;
    }
  }

  Future<bool> actualizarMesa(Mesa mesa) async {
    try {
      return await _mesaRepositorio.actualizarMesa(mesa);
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar mesa: $e'));
      return false;
    }
  }

  Future<bool> eliminarMesa(String mesaId) async {
    try {
      return await _mesaRepositorio.eliminarMesa(mesaId);
    } catch (e) {
      emit(PantallaDuenoConError('Error al eliminar mesa: $e'));
      return false;
    }
  }

  /// Actualiza la contraseña del negocio en Firestore
  Future<bool> actualizarPassword(String negocioId, String nuevaPassword) async {
    try {
      return await _negocioRepositorio.actualizarPassword(negocioId, nuevaPassword);
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar contraseña: $e'));
      return false;
    }
  }

  /// Actualiza el email del negocio
  Future<bool> actualizarEmailNegocio(String negocioId, String nuevoEmail) async {
    try {
      final exito = await _negocioRepositorio.actualizarEmail(negocioId, nuevoEmail);
      if (exito) {
        final state = this.state;
        if (state is PantallaDuenoAutenticado) {
          emit(PantallaDuenoAutenticado(state.negocio.copyWith(email: nuevoEmail)));
        }
      }
      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar email: $e'));
      return false;
    }
  }

  /// Actualiza la dirección del negocio
  Future<bool> actualizarDireccion(Negocio negocio, String nuevaDireccion) async {
    try {
      final negocioActualizado = negocio.copyWith(direccion: nuevaDireccion);
      final exito = await _negocioRepositorio.actualizarNegocio(negocioActualizado);
      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }
      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar dirección: $e'));
      return false;
    }
  }

  // Métodos para ver reservas
  Future<List<Reserva>> obtenerReservasDelNegocio(String negocioId) async {
    try {
      // Obtener las mesas del negocio y luego sus reservas
      final mesas = await _mesaRepositorio.obtenerMesasPorNegocio(negocioId);
      if (mesas.isEmpty) return [];

      final mesaIds = mesas.map((m) => m.id).toList();
      return await _reservaRepositorio.obtenerReservasPorMesaIds(mesaIds);
    } catch (e) {
      emit(PantallaDuenoConError('Error al obtener reservas: $e'));
      return [];
    }
  }

  // Métodos para administrar reservas
  Future<bool> confirmarReserva(String reservaId) async {
    try {
      final reserva = await _reservaRepositorio.obtenerReservaPorId(reservaId);
      if (reserva == null) {
        emit(const PantallaDuenoConError('Reserva no encontrada'));
        return false;
      }

      if (reserva.estado == EstadoReserva.cancelada) {
        emit(const PantallaDuenoConError('No se puede confirmar una reserva cancelada'));
        return false;
      }

      if (reserva.estado == EstadoReserva.confirmada) {
        emit(const PantallaDuenoConError('La reserva ya está confirmada'));
        return false;
      }

      // Persistir el cambio de estado en Firestore
      await _reservaRepositorio.confirmarReserva(reservaId);

      // Usar copyWith para crear la versión confirmada (para email)
      final reservaConfirmada = reserva.copyWith(estado: EstadoReserva.confirmada);

      // Obtener nombre del negocio y mesa para el email
      final state = this.state;
      final nombreNegocio =
          state is PantallaDuenoAutenticado
              ? state.negocio.nombre
              : 'Restaurante';
      final mesa = await _mesaRepositorio.obtenerMesaPorId(reserva.mesaId);

      // Enviar email al cliente
      await _servicioEmail.notificarReservaConfirmada(
        reservaConfirmada,
        nombreNegocio: nombreNegocio,
        nombreMesa: mesa?.nombre ?? 'Mesa',
      );

      return true;
    } catch (e) {
      emit(PantallaDuenoConError('Error al confirmar reserva: $e'));
      return false;
    }
  }

  Future<bool> cancelarReservaAdmin(String reservaId, {String? motivo}) async {
    try {
      final reserva = await _reservaRepositorio.obtenerReservaPorId(reservaId);
      if (reserva == null) {
        emit(const PantallaDuenoConError('Reserva no encontrada'));
        return false;
      }

      print('🔍 Cancelando reserva: ${reserva.id}');
      print('🔍 Contacto Cliente: ${reserva.contactoCliente}');

      await _reservaRepositorio.cancelarReserva(reservaId);

      // Obtener nombre del negocio y mesa para el email
      final state = this.state;
      final nombreNegocio =
          state is PantallaDuenoAutenticado
              ? state.negocio.nombre
              : 'Restaurante';
      final mesa = await _mesaRepositorio.obtenerMesaPorId(reserva.mesaId);

      // Enviar email al cliente informando la cancelación
      await _servicioEmail.notificarReservaCanceladaPorRestaurante(
        reserva,
        nombreNegocio: nombreNegocio,
        nombreMesa: mesa?.nombre ?? 'Mesa',
        motivo: motivo,
      );

      print('✅ Email de cancelación enviado a: ${reserva.contactoCliente}');

      return true;
    } catch (e) {
      print('❌ Error al cancelar reserva: $e');
      emit(PantallaDuenoConError('Error al cancelar reserva: $e'));
      return false;
    }
  }

  // Métodos para métricas
  Future<Map<String, dynamic>> obtenerMetricasReservas(String negocioId) async {
    try {
      final reservas = await obtenerReservasDelNegocio(negocioId);
      final ahora = DateTime.now();

      // Filtrar solo reservas confirmadas y no canceladas para métricas
      final reservasActivas =
          reservas.where((r) => r.estado != EstadoReserva.cancelada).toList();

      // Reservas por día (últimos 7 días)
      Map<String, int> reservasPorDia = {};
      for (int i = 6; i >= 0; i--) {
        final fecha = ahora.subtract(Duration(days: i));
        final fechaStr = '${fecha.day}/${fecha.month}';
        reservasPorDia[fechaStr] =
            reservasActivas.where((r) {
              return r.fechaHora.year == fecha.year &&
                  r.fechaHora.month == fecha.month &&
                  r.fechaHora.day == fecha.day;
            }).length;
      }

      // Reservas por mes (últimos 6 meses)
      Map<String, int> reservasPorMes = {};
      for (int i = 5; i >= 0; i--) {
        final fecha = DateTime(ahora.year, ahora.month - i, 1);
        final mesNombre = _obtenerNombreMes(fecha.month);
        reservasPorMes[mesNombre] =
            reservasActivas.where((r) {
              return r.fechaHora.year == fecha.year &&
                  r.fechaHora.month == fecha.month;
            }).length;
      }

      // Horarios pico (agrupar por hora)
      Map<int, int> reservasPorHora = {};
      for (var reserva in reservasActivas) {
        final hora = reserva.fechaHora.hour;
        reservasPorHora[hora] = (reservasPorHora[hora] ?? 0) + 1;
      }

      // Ordenar horarios por cantidad de reservas
      final horariosOrdenados =
          reservasPorHora.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      List<Map<String, dynamic>> horariosPico = [];
      List<Map<String, dynamic>> horariosPocoMovimiento = [];

      if (horariosOrdenados.isNotEmpty) {
        // Top 3 horarios pico
        horariosPico =
            horariosOrdenados
                .take(3)
                .map(
                  (e) => {
                    'hora': '${e.key.toString().padLeft(2, '0')}:00',
                    'reservas': e.value,
                  },
                )
                .toList();

        // Top 3 horarios con poco movimiento (invertir orden)
        horariosPocoMovimiento =
            horariosOrdenados.reversed
                .take(3)
                .map(
                  (e) => {
                    'hora': '${e.key.toString().padLeft(2, '0')}:00',
                    'reservas': e.value,
                  },
                )
                .toList();
      }

      // Total de reservas
      final totalReservas = reservasActivas.length;
      final reservasHoy =
          reservasActivas.where((r) {
            return r.fechaHora.year == ahora.year &&
                r.fechaHora.month == ahora.month &&
                r.fechaHora.day == ahora.day;
          }).length;

      final reservasMesActual =
          reservasActivas.where((r) {
            return r.fechaHora.year == ahora.year &&
                r.fechaHora.month == ahora.month;
          }).length;

      return {
        'reservasPorDia': reservasPorDia,
        'reservasPorMes': reservasPorMes,
        'horariosPico': horariosPico,
        'horariosPocoMovimiento': horariosPocoMovimiento,
        'totalReservas': totalReservas,
        'reservasHoy': reservasHoy,
        'reservasMesActual': reservasMesActual,
      };
    } catch (e) {
      emit(PantallaDuenoConError('Error al obtener métricas: $e'));
      return {};
    }
  }

  String _obtenerNombreMes(int mes) {
    const meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return meses[mes];
  }

  // ─── GESTIÓN DE ZONAS ─────────────────────────────────────

  /// Obtiene las zonas de un negocio
  Future<List<Zona>> obtenerZonasDelNegocio(String negocioId) async {
    try {
      return await _zonaRepositorio.obtenerZonasPorNegocio(negocioId);
    } catch (e) {
      emit(PantallaDuenoConError('Error al obtener zonas: $e'));
      return [];
    }
  }

  /// Crea una nueva zona
  Future<Zona?> crearZona(Zona zona) async {
    try {
      return await _zonaRepositorio.crearZona(zona);
    } catch (e) {
      emit(PantallaDuenoConError('Error al crear zona: $e'));
      return null;
    }
  }

  /// Actualiza una zona existente
  Future<bool> actualizarZona(Zona zona) async {
    try {
      return await _zonaRepositorio.actualizarZona(zona);
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar zona: $e'));
      return false;
    }
  }

  /// Verifica si una zona tiene mesas asignadas
  Future<bool> tieneMesasEnZona(String zonaId) async {
    try {
      return await _zonaRepositorio.tieneMesasAsignadas(zonaId);
    } catch (e) {
      return false;
    }
  }

  /// Elimina una zona (valida que no tenga mesas asignadas)
  Future<bool> eliminarZona(String zonaId) async {
    try {
      final tieneMesas = await _zonaRepositorio.tieneMesasAsignadas(zonaId);
      if (tieneMesas) {
        emit(const PantallaDuenoConError(
          'No se puede eliminar la zona porque tiene mesas asignadas',
        ));
        return false;
      }
      return await _zonaRepositorio.eliminarZona(zonaId);
    } catch (e) {
      emit(PantallaDuenoConError('Error al eliminar zona: $e'));
      return false;
    }
  }
}
