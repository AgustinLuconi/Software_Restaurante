import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class VerReserva {
  final ReservaRepositorio reservaRepositorio;

  VerReserva(this.reservaRepositorio);

  Future<List<Reserva>> execute(String clienteId) async {
    try {
      final reservas = await reservaRepositorio.obtenerReserva();
      return reservas.where((r) => r.clienteId == clienteId).toList();
    } catch (e) {
      // Puedes lanzar la excepción o retornar lista vacía
      // throw Exception('Error al obtener reservas: $e');
      return [];
    }
  }
}
