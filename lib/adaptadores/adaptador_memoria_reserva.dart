import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class ReservaRepositorioMemoria implements ReservaRepositorio {
  final List<Reserva> _reservas = [];

  @override
  Future<void> crearReserva(Reserva reserva) async {
    _reservas.add(reserva);
  }

  @override
  Future<List<Reserva>> obtenerReserva() async {
    return List.unmodifiable(_reservas);
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    final reserva = _reservas.firstWhere(
      (r) => r.id == reservaId,
      orElse: () => throw Exception('Reserva no encontrada'),
    );
    reserva.cancelar();
  }

  @override
  Future<Reserva?> obtenerReservaPorId(String reservaId) async {
    try {
      return _reservas.firstWhere((r) => r.id == reservaId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Reserva>> obtenerReservasPorMesaYHorario({
    required String mesaId,
    required DateTime fecha,
    required DateTime hora,
  }) async {
    // Filtrar reservas activas (confirmadas o pendientes) para la mesa en la fecha especificada
    return _reservas.where((reserva) {
      // Solo considerar reservas confirmadas o pendientes
      if (reserva.estado != EstadoReserva.confirmada && 
          reserva.estado != EstadoReserva.pendiente) {
        return false;
      }

      // Verificar que sea la misma mesa
      if (reserva.mesaId != mesaId) {
        return false;
      }

      // Verificar que sea el mismo día
      final fechaReserva = reserva.fechaHora;
      if (fechaReserva.year != fecha.year ||
          fechaReserva.month != fecha.month ||
          fechaReserva.day != fecha.day) {
        return false;
      }

      // Verificar si hay conflicto de horario (intervalo de 1 hora)
      // Una reserva ocupa 1 hora desde su hora de inicio
      final inicioReserva = DateTime(
        fechaReserva.year,
        fechaReserva.month,
        fechaReserva.day,
        fechaReserva.hour,
        0,
      );
      final finReserva = inicioReserva.add(const Duration(hours: 1));

      final inicioSolicitado = DateTime(
        hora.year,
        hora.month,
        hora.day,
        hora.hour,
        0,
      );
      final finSolicitado = inicioSolicitado.add(const Duration(hours: 1));

      // Hay conflicto si los intervalos se superponen
      return inicioSolicitado.isBefore(finReserva) && finSolicitado.isAfter(inicioReserva);
    }).toList();
  }

  @override
  Future<bool> mesaDisponible({
    required String mesaId,
    required DateTime fecha,
    required DateTime hora,
  }) async {
    final reservasConflictivas = await obtenerReservasPorMesaYHorario(
      mesaId: mesaId,
      fecha: fecha,
      hora: hora,
    );

    // La mesa está disponible si no hay reservas conflictivas
    return reservasConflictivas.isEmpty;
  }
}

