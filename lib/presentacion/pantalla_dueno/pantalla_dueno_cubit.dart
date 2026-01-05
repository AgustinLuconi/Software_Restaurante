import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import '../../dominio/servicios/servicio_notificaciones.dart';
import 'pantalla_dueno_estados_de_cubit.dart';

class PantallaDuenoCubit extends Cubit<PantallaDuenoState> {
  final NegocioRepositorio negocioRepositorio;
  final MesaRepositorio mesaRepositorio;
  final ReservaRepositorio reservaRepositorio;
  final ServicioNotificaciones servicioNotificaciones;

  PantallaDuenoCubit(
    this.negocioRepositorio,
    this.mesaRepositorio,
    this.reservaRepositorio,
    this.servicioNotificaciones,
  ) : super(const PantallaDuenoInicial());

  // Método para establecer un negocio autenticado directamente
  void establecerNegocioAutenticado(Negocio negocio) {
    emit(PantallaDuenoAutenticado(negocio));
  }

  Future<void> autenticar(String email, String password) async {
    try {
      emit(const PantallaDuenoCargando());

      final negocio = await negocioRepositorio.autenticarNegocio(
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

  Future<bool> actualizarTelefono(Negocio negocio, String nuevoTelefono) async {
    try {
      final negocioActualizado = negocio.copyWith(telefono: nuevoTelefono);
      final exito = await negocioRepositorio.actualizarNegocio(negocioActualizado);
      
      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }
      
      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar teléfono: $e'));
      return false;
    }
  }

  Future<bool> actualizarEspecialidad(Negocio negocio, String nuevaEspecialidad) async {
    try {
      final negocioActualizado = negocio.copyWith(especialidad: nuevaEspecialidad);
      final exito = await negocioRepositorio.actualizarNegocio(negocioActualizado);
      
      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }
      
      return exito;
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar especialidad: $e'));
      return false;
    }
  }

  Future<Map<String, String>> obtenerHorarios(String negocioId) async {
    return await negocioRepositorio.obtenerHorariosServicio(negocioId);
  }

  Future<bool> actualizarHorarios(String negocioId, Map<String, String> horarios) async {
    try {
      return await negocioRepositorio.actualizarHorariosServicio(negocioId, horarios);
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar horarios: $e'));
      return false;
    }
  }

  // Métodos para gestión de mesas
  Future<List<Mesa>> obtenerMesasDelNegocio(String negocioId) async {
    return await mesaRepositorio.obtenerMesasPorNegocio(negocioId);
  }

  Future<Mesa?> agregarMesa(String negocioId, String nombre, int capacidad) async {
    try {
      final nuevaMesa = Mesa(
        id: '', // Se generará en el repositorio
        nombre: nombre,
        capacidad: capacidad,
        negocioId: negocioId,
      );
      return await mesaRepositorio.agregarMesa(nuevaMesa);
    } catch (e) {
      emit(PantallaDuenoConError('Error al agregar mesa: $e'));
      return null;
    }
  }

  Future<bool> actualizarMesa(Mesa mesa) async {
    try {
      return await mesaRepositorio.actualizarMesa(mesa);
    } catch (e) {
      emit(PantallaDuenoConError('Error al actualizar mesa: $e'));
      return false;
    }
  }

  Future<bool> eliminarMesa(String mesaId) async {
    try {
      return await mesaRepositorio.eliminarMesa(mesaId);
    } catch (e) {
      emit(PantallaDuenoConError('Error al eliminar mesa: $e'));
      return false;
    }
  }

  // Métodos para ver reservas
  Future<List<Reserva>> obtenerReservasDelNegocio(String negocioId) async {
    try {
      // Obtener todas las reservas y filtrar por negocio
      // Nota: Aquí asumimos que las reservas están asociadas a mesas del negocio
      final mesas = await mesaRepositorio.obtenerMesasPorNegocio(negocioId);
      final mesaIds = mesas.map((m) => m.id).toSet();
      
      final todasReservas = await reservaRepositorio.obtenerReserva();
      return todasReservas.where((r) => mesaIds.contains(r.mesaId)).toList();
    } catch (e) {
      emit(PantallaDuenoConError('Error al obtener reservas: $e'));
      return [];
    }
  }

  // Métodos para administrar reservas
  Future<bool> confirmarReserva(String reservaId) async {
    try {
      final reservas = await reservaRepositorio.obtenerReserva();
      final reserva = reservas.firstWhere((r) => r.id == reservaId);
      reserva.confirmar();
      
      // Notificar al cliente
      await servicioNotificaciones.notificarReservaConfirmada(reserva.clienteId, reserva);
      
      return true;
    } catch (e) {
      emit(PantallaDuenoConError('Error al confirmar reserva: $e'));
      return false;
    }
  }

  Future<bool> cancelarReservaAdmin(String reservaId) async {
    try {
      final reservas = await reservaRepositorio.obtenerReserva();
      final reserva = reservas.firstWhere((r) => r.id == reservaId);
      
      print('🔍 Cancelando reserva: ${reserva.id}');
      print('🔍 Cliente ID: ${reserva.clienteId}');
      print('🔍 Contacto Cliente: ${reserva.contactoCliente}');
      
      await reservaRepositorio.cancelarReserva(reservaId);
      
      // Notificar al cliente que el negocio canceló la reserva
      // Usar contactoCliente en lugar de clienteId
      final clienteNotificacion = reserva.contactoCliente ?? reserva.clienteId;
      await servicioNotificaciones.notificarReservaCancelada(
        clienteNotificacion,
        reserva,
        porNegocio: true,
      );
      
      // También enviar a cliente_123 para que aparezca en el panel general
      await servicioNotificaciones.notificarReservaCancelada(
        'cliente_123',
        reserva,
        porNegocio: true,
      );
      
      print('✅ Notificación enviada a: $clienteNotificacion y a cliente_123');
      
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
      final reservasActivas = reservas.where((r) => r.estado != EstadoReserva.cancelada).toList();
      
      // Reservas por día (últimos 7 días)
      Map<String, int> reservasPorDia = {};
      for (int i = 6; i >= 0; i--) {
        final fecha = ahora.subtract(Duration(days: i));
        final fechaStr = '${fecha.day}/${fecha.month}';
        reservasPorDia[fechaStr] = reservasActivas.where((r) {
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
        reservasPorMes[mesNombre] = reservasActivas.where((r) {
          return r.fechaHora.year == fecha.year && r.fechaHora.month == fecha.month;
        }).length;
      }
      
      // Horarios pico (agrupar por hora)
      Map<int, int> reservasPorHora = {};
      for (var reserva in reservasActivas) {
        final hora = reserva.fechaHora.hour;
        reservasPorHora[hora] = (reservasPorHora[hora] ?? 0) + 1;
      }
      
      // Ordenar horarios por cantidad de reservas
      final horariosOrdenados = reservasPorHora.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      List<Map<String, dynamic>> horariosPico = [];
      List<Map<String, dynamic>> horariosPocoMovimiento = [];
      
      if (horariosOrdenados.isNotEmpty) {
        // Top 3 horarios pico
        horariosPico = horariosOrdenados.take(3).map((e) => {
          'hora': '${e.key.toString().padLeft(2, '0')}:00',
          'reservas': e.value,
        }).toList();
        
        // Top 3 horarios con poco movimiento (invertir orden)
        horariosPocoMovimiento = horariosOrdenados.reversed.take(3).map((e) => {
          'hora': '${e.key.toString().padLeft(2, '0')}:00',
          'reservas': e.value,
        }).toList();
      }
      
      // Total de reservas
      final totalReservas = reservasActivas.length;
      final reservasHoy = reservasActivas.where((r) {
        return r.fechaHora.year == ahora.year &&
               r.fechaHora.month == ahora.month &&
               r.fechaHora.day == ahora.day;
      }).length;
      
      final reservasMesActual = reservasActivas.where((r) {
        return r.fechaHora.year == ahora.year && r.fechaHora.month == ahora.month;
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
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return meses[mes];
  }
}

