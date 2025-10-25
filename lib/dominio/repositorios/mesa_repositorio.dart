import '../entidades/mesa.dart';

abstract class MesaRepositorio {
	Future<List<Mesa>> obtenerMesas();
	Future<List<Mesa>> obtenerMesasDisponibles(DateTime fecha, DateTime hora, int numeroPersonas);
	Future<List<Mesa>> obtenerMesasPorNegocio(String negocioId);
	Future<Mesa?> agregarMesa(Mesa mesa);
	Future<bool> actualizarMesa(Mesa mesa);
	Future<bool> eliminarMesa(String mesaId);
}
