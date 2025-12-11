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
  Future<Mesa?> obtenerMesaPorId(String mesaId) async {
    try {
      return _mesas.firstWhere((mesa) => mesa.id == mesaId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Mesa>> obtenerMesasDisponibles(DateTime fecha, DateTime hora, int numeroPersonas) async {
    // Filtrar mesas que pueden acomodar el número de personas
    // con la nueva lógica: capacidad >= numeroPersonas && capacidad <= numeroPersonas + 3
    final mesasCandidatas = _mesas.where((mesa) => mesa.puedeAcomodar(numeroPersonas)).toList();
    
    // Si no hay repositorio de reservas, devolver todas las mesas candidatas ordenadas
    if (reservaRepositorio == null) {
      return _ordenarMesasPorCapacidad(mesasCandidatas, numeroPersonas);
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
    
    // Ordenar por capacidad: primero las más cercanas al número de personas solicitado
    return _ordenarMesasPorCapacidad(mesasDisponibles, numeroPersonas);
  }

  /// Ordena las mesas por capacidad, priorizando las más cercanas al número de personas
  List<Mesa> _ordenarMesasPorCapacidad(List<Mesa> mesas, int numeroPersonas) {
    final mesasOrdenadas = List<Mesa>.from(mesas);
    mesasOrdenadas.sort((a, b) {
      // Calcular la diferencia con el número de personas solicitado
      // SIN valor absoluto, queremos ordenar de menor a mayor capacidad
      final diferenciaA = a.capacidad - numeroPersonas;
      final diferenciaB = b.capacidad - numeroPersonas;
      
      // Ordenar por capacidad ascendente (primero la más justa, después las más grandes)
      return diferenciaA.compareTo(diferenciaB);
    });
    return mesasOrdenadas;
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
        zona: mesa.zona,
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

  @override
  Future<List<ZonaMesa>> obtenerZonasDisponibles(String negocioId) async {
    // Obtener las zonas únicas de las mesas del negocio
    final mesasNegocio = _mesas.where((m) => m.negocioId == negocioId).toList();
    final zonasSet = mesasNegocio.map((m) => m.zona).toSet();
    return zonasSet.toList();
  }

  @override
  Future<Mesa?> buscarMesaDisponibleEnZona({
    required ZonaMesa zona,
    required DateTime fecha,
    required DateTime hora,
    required int numeroPersonas,
    required String negocioId,
  }) async {
    // Filtrar mesas de la zona específica que pueden acomodar el número de personas
    final mesasZona = _mesas.where((mesa) => 
      mesa.zona == zona && 
      mesa.negocioId == negocioId &&
      mesa.puedeAcomodar(numeroPersonas)
    ).toList();

    if (mesasZona.isEmpty) {
      return null;
    }

    // Si no hay repositorio de reservas, devolver la primera mesa candidata
    if (reservaRepositorio == null) {
      final mesasOrdenadas = _ordenarMesasPorCapacidad(mesasZona, numeroPersonas);
      return mesasOrdenadas.isNotEmpty ? mesasOrdenadas.first : null;
    }

    // Buscar la primera mesa disponible (ordenadas por mejor ajuste de capacidad)
    final mesasOrdenadas = _ordenarMesasPorCapacidad(mesasZona, numeroPersonas);
    
    for (final mesa in mesasOrdenadas) {
      final estaDisponible = await reservaRepositorio!.mesaDisponible(
        mesaId: mesa.id,
        fecha: fecha,
        hora: hora,
      );
      
      if (estaDisponible) {
        return mesa; // Encontramos una mesa disponible
      }
    }

    return null; // No hay mesas disponibles en esa zona
  }
}
