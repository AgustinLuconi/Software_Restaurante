import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class ObtenerReserva {
  final ReservaRepositorio reservaRepositorio;

  ObtenerReserva(this.reservaRepositorio);

  Future<List<Reserva>> execute() async {
    try {
      return await reservaRepositorio.obtenerReserva();
    } catch (e) {
      // Puedes lanzar la excepción o retornar lista vacía
      // throw Exception('Error al obtener reservas: $e');
      return [];
    }
  }
}

class ObtenerReservaPorId {
  final ReservaRepositorio reservaRepositorio;

  ObtenerReservaPorId(this.reservaRepositorio);

  Future<Reserva?> execute(String reservaId) async {
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);
    if (reserva == null) {
      // Puedes lanzar una excepción o retornar null
      // throw Exception('Reserva no encontrada');
      return null;
    }
    return reserva;
  }
}
