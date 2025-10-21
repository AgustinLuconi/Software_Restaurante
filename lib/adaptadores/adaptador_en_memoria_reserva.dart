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
}
