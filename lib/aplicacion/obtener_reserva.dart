import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class ObtenerReserva {
  final ReservaRepositorio reservaRepositorio;

  ObtenerReserva(this.reservaRepositorio);

  /// Obtiene reservas filtradas por contacto del cliente.
  /// Si [contactoCliente] se proporciona, solo retorna las de ese cliente.
  /// Si no, retorna todas (uso administrativo).
  Future<List<Reserva>> ejecutar({String? contactoCliente}) async {
    try {
      if (contactoCliente != null && contactoCliente.isNotEmpty) {
        return await reservaRepositorio.obtenerReservasPorContacto(contactoCliente);
      }
      return await reservaRepositorio.obtenerReserva();
    } catch (e) {
      return [];
    }
  }
}
