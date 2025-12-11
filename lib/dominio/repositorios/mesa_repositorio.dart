import '../entidades/mesa.dart';

abstract class MesaRepositorio {
	Future<List<Mesa>> obtenerMesas();
	Future<Mesa?> obtenerMesaPorId(String mesaId);
	Future<List<Mesa>> obtenerMesasDisponibles(DateTime fecha, DateTime hora, int numeroPersonas);
	Future<List<Mesa>> obtenerMesasPorNegocio(String negocioId);
	Future<Mesa?> agregarMesa(Mesa mesa);
	Future<bool> actualizarMesa(Mesa mesa);
	Future<bool> eliminarMesa(String mesaId);
	
	/// Obtiene las zonas disponibles en el restaurante
	Future<List<ZonaMesa>> obtenerZonasDisponibles(String negocioId);
	
	/// Busca automáticamente una mesa disponible en la zona especificada
	/// Retorna la mejor mesa disponible (la que mejor se ajusta al número de personas)
	/// o null si no hay mesas disponibles en esa zona
	Future<Mesa?> buscarMesaDisponibleEnZona({
		required ZonaMesa zona,
		required DateTime fecha,
		required DateTime hora,
		required int numeroPersonas,
		required String negocioId,
	});
}
