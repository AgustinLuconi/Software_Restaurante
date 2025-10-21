import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class CrearReserva {
  final ReservaRepositorio reservaRepositorio;

  CrearReserva(this.reservaRepositorio);

  Future<Reserva> execute(String clienteId, String mesaId, DateTime fecha, DateTime hora, int numeroPersonas) async {
    final now = DateTime.now();
    final fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    if (fechaHora.isBefore(now)) {
      throw Exception('La fecha y hora deben ser futuras.');
    }
    if (numeroPersonas <= 0) {
      throw Exception('El número de personas debe ser mayor a cero.');
    }
    final reserva = Reserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clienteId: clienteId,
      mesaId: mesaId,
      fechaHora: fechaHora,
      numeroPersonas: numeroPersonas,
      estado: EstadoReserva.pendiente,
    );
    await reservaRepositorio.crearReserva(reserva);
    return reserva;
  }
}
