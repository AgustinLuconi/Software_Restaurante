import '../dominio/entidades/mesa.dart';
import '../dominio/repositorios/mesa_repositorio.dart';

class ObtenerMesasDisponibles {
  final MesaRepositorio mesaRepositorio;

  ObtenerMesasDisponibles(this.mesaRepositorio);

  Future<List<Mesa>> execute(DateTime fecha, DateTime hora, int numeroPersonas) async {
    final now = DateTime.now();
    final fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    if (fechaHora.isBefore(now)) {
      throw Exception('La fecha y hora deben ser futuras.');
    }
    try {
      return await mesaRepositorio.obtenerMesasDisponibles(fecha, hora, numeroPersonas);
    } catch (e) {
      // Puedes lanzar la excepción o retornar lista vacía según preferencia
      // throw Exception('Error al obtener mesas disponibles: $e');
      return [];
    }
  }
}
