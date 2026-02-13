import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class ObtenerReserva {
  final ReservaRepositorio reservaRepositorio;

  ObtenerReserva(this.reservaRepositorio);

  Future<List<Reserva>> ejecutar() async {
    try {
      return await reservaRepositorio.obtenerReserva();
    } catch (e) {
      // Puedes lanzar la excepción o retornar lista vacía
      // throw Exception('Error al obtener reservas: $e');
      return [];
    }
  }
}
