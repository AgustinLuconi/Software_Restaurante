import '../dominio/entidades/mesa.dart';
import '../dominio/repositorios/mesa_repositorio.dart';

class MesaRepositorioMemoria implements MesaRepositorio {
  final List<Mesa> _mesas;
  int _contadorId = 1;

  MesaRepositorioMemoria(this._mesas) {
    // Inicializar el contador con el ID más alto existente
    if (_mesas.isNotEmpty) {
      final ids = _mesas.map((m) => int.tryParse(m.id) ?? 0).toList();
      _contadorId = ids.reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  @override
  Future<List<Mesa>> obtenerMesas() async {
    return List.unmodifiable(_mesas);
  }

  @override
  Future<List<Mesa>> obtenerMesasDisponibles(DateTime fecha, DateTime hora, int numeroPersonas) async {
    // Simulación: todas las mesas disponibles si pueden acomodar el número de personas
    return _mesas.where((mesa) => mesa.puedeAcomodar(numeroPersonas)).toList();
  }

  @override
  Future<List<Mesa>> obtenerMesasPorNegocio(String negocioId) async {
    return _mesas.where((mesa) => mesa.negocioId == negocioId).toList();
  }

  @override
  Future<Mesa?> agregarMesa(Mesa mesa) async {
    try {
      final nuevaMesa = Mesa(
        id: _contadorId.toString(),
        nombre: mesa.nombre,
        capacidad: mesa.capacidad,
        negocioId: mesa.negocioId,
      );
      _mesas.add(nuevaMesa);
      _contadorId++;
      return nuevaMesa;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> actualizarMesa(Mesa mesa) async {
    try {
      final index = _mesas.indexWhere((m) => m.id == mesa.id);
      if (index != -1) {
        _mesas[index] = mesa;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> eliminarMesa(String mesaId) async {
    try {
      final index = _mesas.indexWhere((m) => m.id == mesaId);
      if (index != -1) {
        _mesas.removeAt(index);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
