import '../dominio/entidades/mesa.dart';
import '../dominio/repositorios/mesa_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class MesaRepositorioMemoria implements MesaRepositorio {
  final List<Mesa> _mesas;
  final ReservaRepositorio? reservaRepositorio;
  int _contadorId = 1;

  MesaRepositorioMemoria(this._mesas, {this.reservaRepositorio}) {
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
    // Filtrar mesas que pueden acomodar el número de personas
    final mesasCandidatas = _mesas.where((mesa) => mesa.puedeAcomodar(numeroPersonas)).toList();
    
    // Si no hay repositorio de reservas, devolver todas las mesas candidatas
    if (reservaRepositorio == null) {
      return mesasCandidatas;
    }
    
    // Filtrar mesas que NO estén reservadas en ese horario
    final mesasDisponibles = <Mesa>[];
    
    for (final mesa in mesasCandidatas) {
      final estaDisponible = await reservaRepositorio!.mesaDisponible(
        mesaId: mesa.id,
        fecha: fecha,
        hora: hora,
      );
      
      if (estaDisponible) {
        mesasDisponibles.add(mesa);
      }
    }
    
    return mesasDisponibles;
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
