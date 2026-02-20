import 'package:flutter_bloc/flutter_bloc.dart';

import '../../aplicacion/cancelar_reserva.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import '../../service_locator.dart';
import 'mis_reservas_estados_de_cubit.dart';

class MisReservasCubit extends Cubit<MisReservasState> {
  final CancelarReserva _cancelarReserva;
  final ReservaRepositorio _reservaRepositorio;

  /// Teléfono verificado del cliente actual
  String? _telefonoVerificado;
  String? get telefonoVerificado => _telefonoVerificado;

  /// NegocioId del restaurante actual
  String? _negocioId;
  String? get negocioId => _negocioId;

  MisReservasCubit()
      : _cancelarReserva = getIt<CancelarReserva>(),
        _reservaRepositorio = getIt<ReservaRepositorio>(),
        super(MisReservasInicial());

  /// Carga las reservas filtradas por teléfono verificado y negocioId
  Future<void> cargarReservasFiltradas({
    required String telefono,
    required String negocioId,
  }) async {
    try {
      emit(MisReservasCargando());
      _telefonoVerificado = telefono;
      _negocioId = negocioId;

      final reservas = await _reservaRepositorio.obtenerReservasPorTelefonoYNegocio(
        telefonoCliente: telefono,
        negocioId: negocioId,
      );
      emit(MisReservasExitoso(reservas));
    } catch (e) {
      emit(MisReservasConError('Error al cargar las reservas: ${e.toString()}'));
    }
  }

  /// Recargar usando los filtros anteriores
  Future<void> recargarReservas() async {
    if (_telefonoVerificado != null && _negocioId != null) {
      await cargarReservasFiltradas(
        telefono: _telefonoVerificado!,
        negocioId: _negocioId!,
      );
    }
  }

  Future<void> cancelarReserva(String reservaId) async {
    try {
      emit(MisReservasCargando());

      final idNegocio = _negocioId ?? 'default';
      await _cancelarReserva.ejecutar(reservaId, negocioId: idNegocio);

      emit(ReservaCancelada('Reserva cancelada exitosamente'));
      
      // Recargar las reservas filtradas
      await recargarReservas();
    } catch (e) {
      print('❌ Error al cancelar reserva: $e');
      emit(ReservaCancelacionError('Error al cancelar: ${e.toString().replaceAll('Exception: ', '')}'));
      try { await recargarReservas(); } catch (_) {}
    }
  }
}
