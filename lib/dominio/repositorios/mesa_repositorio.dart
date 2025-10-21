import '../entidades/mesa.dart';

abstract class MesaRepositorio {
	Future<List<Mesa>> obtenerMesas();
	Future<List<Mesa>> obtenerMesasDisponibles(DateTime fecha, DateTime hora, int numeroPersonas);
}
