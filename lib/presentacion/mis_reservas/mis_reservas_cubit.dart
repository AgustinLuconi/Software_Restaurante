import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cancelar_reserva.dart';
import '../../aplicacion/obtener_reserva.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import '../../service_locator.dart';
import 'mis_reservas_estados_de_cubit.dart';

import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../adaptadores/servicio_email.dart';

class MisReservasCubit extends Cubit<MisReservasState> {
  final ObtenerReserva _obtenerReserva;
  final CancelarReserva _cancelarReserva;
  final ReservaRepositorio _reservaRepositorio;
  final NegocioRepositorio _negocioRepositorio;
  final MesaRepositorio _mesaRepositorio;
  final ServicioEmail _servicioEmail;

  MisReservasCubit()
      : _obtenerReserva = getIt<ObtenerReserva>(),
        _cancelarReserva = getIt<CancelarReserva>(),
        _reservaRepositorio = getIt<ReservaRepositorio>(),
        _negocioRepositorio = getIt<NegocioRepositorio>(),
        _mesaRepositorio = getIt<MesaRepositorio>(),
        _servicioEmail = getIt<ServicioEmail>(),
        super(MisReservasInicial());

  Future<void> cargarReservas() async {
    try {
      emit(MisReservasCargando());
      final reservas = await _obtenerReserva.ejecutar();
      emit(MisReservasExitoso(reservas));
    } catch (e) {
      emit(MisReservasConError('Error al cargar las reservas: ${e.toString()}'));
    }
  }

  Future<void> cancelarReserva(String reservaId, {String? negocioId}) async {
    try {
      emit(MisReservasCargando());

      // 1. Obtener la reserva para tener sus datos antes de cancelar
      final reserva = await _reservaRepositorio.obtenerReservaPorId(reservaId);
      if (reserva == null) throw Exception('Reserva no encontrada');

      // 2. Obtener datos del negocio
      String idNegocio = negocioId ?? '';
      if (idNegocio.isEmpty) {
        // Intentar obtenerlo de la mesa si no vino por parámetro
        // (Aunque idealmente la reserva debería tener negocioId, si no lo tiene, buscamos)
        // Nota: En la impl actual, crearReserva ya pide negocioId, así que debería estar.
        // Si la reserva no tiene negocioId explícito (modelos viejos),
        // habría que buscar la mesa y de ahí el negocio.
        final mesa = await _mesaRepositorio.obtenerMesaPorId(reserva.mesaId);
        idNegocio = mesa?.negocioId ?? 'default';
      }

      final negocio = await _negocioRepositorio.obtenerNegocioPorId(idNegocio);
      final nombreNegocio = negocio?.nombre ?? 'Restaurante';
      final emailDueno = negocio?.email;

      // 3. Obtener datos de la mesa
      final mesa = await _mesaRepositorio.obtenerMesaPorId(reserva.mesaId);
      final nombreMesa = mesa?.nombre ?? 'Mesa';

      // 4. Ejecutar cancelación
      await _cancelarReserva.ejecutar(reservaId, negocioId: idNegocio);
      
      // 5. Enviar notificaciones
      print('📧 Enviando notificaciones de cancelación...');
      await _servicioEmail.notificarReservaCanceladaPorCliente(
        reserva,
        nombreNegocio: nombreNegocio,
        nombreMesa: nombreMesa,
        emailDueno: emailDueno,
      );

      emit(ReservaCancelada('Reserva cancelada exitosamente'));
      
      // 6. Recargar las reservas
      await cargarReservas();
    } catch (e) {
      print('❌ Error al cancelar reserva: $e');
      emit(ReservaCancelacionError('Error al cancelar: ${e.toString().replaceAll('Exception: ', '')}'));
      // Recargar para volver al estado Exitoso y mostrar la lista
      try { await cargarReservas(); } catch (_) {}
    }
  }
}
