import '../dominio/entidades/mesa.dart';
import '../dominio/repositorios/mesa_repositorio.dart';

class MesaRepositorioMemoria implements MesaRepositorio {
  final List<Mesa> _mesas;

  MesaRepositorioMemoria(this._mesas);

  @override
  Future<List<Mesa>> obtenerMesas() async {
    return List.unmodifiable(_mesas);
  }

  @override
  Future<List<Mesa>> obtenerMesasDisponibles(DateTime fecha, DateTime hora, int numeroPersonas) async {
    // Simulación: todas las mesas disponibles si pueden acomodar el número de personas
    return _mesas.where((mesa) => mesa.puedeAcomodar(numeroPersonas)).toList();
  }
}
