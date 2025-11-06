import '../dominio/entidades/negocio.dart';
import '../dominio/repositorios/negocio_repositorio.dart';

class NegocioRepositorioMemoria implements NegocioRepositorio {
  final List<Negocio> _negocios = [];
  final Map<String, String> _passwords = {}; // email -> password
  final Map<String, Map<String, String>> _horariosServicio = {}; // negocioId -> horarios
  int _contadorId = 1;
  bool _inicializado = false;

  // Constructor que inicializa datos de ejemplo
  NegocioRepositorioMemoria() {
    _inicializarDatosEjemplo();
  }

  void _inicializarDatosEjemplo() {
    // Protección: solo inicializar una vez
    if (_inicializado) return;
    _inicializado = true;

    // Limpiar cualquier dato previo para evitar duplicados
    _negocios.clear();
    _passwords.clear();
    _horariosServicio.clear();

    // Agregar el restaurante Chiringuito con credenciales predefinidas
    final chiringuito = Negocio(
      id: 'negocio_1',
      nombre: 'Chiringuito',
      nombreResponsable: 'Juan Pérez',
      email: 'chiringuito@restaurant.com',
      telefono: '+54 261 123-4567',
      direccion: 'Av. San Martín 1234, Mendoza',
      descripcion: 'Restaurante de comida mediterránea con especialidad en mariscos y pescados frescos',
      especialidad: 'Comida Mediterránea',
    );

    _negocios.add(chiringuito);
    _passwords['chiringuito@restaurant.com'] = 'chiringuito123';
    
    // Horarios predeterminados para Chiringuito
    _horariosServicio['negocio_1'] = {
      'Almuerzo': '12:00 - 15:30',
      'Cena': '20:00 - 23:30',
    };
    
    // Resetear el contador después del negocio inicial
    _contadorId = 2;
  }

  @override
  Future<Negocio?> registrarNegocio({
    required String nombre,
    required String nombreResponsable,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  }) async {
    // Verificar si el email ya existe
    final negocioExistente = _negocios.any((n) => n.email == email);
    if (negocioExistente) {
      return null; // Email ya registrado
    }

    final nuevoNegocio = Negocio(
      id: 'negocio_${_contadorId++}',
      nombre: nombre,
      nombreResponsable: nombreResponsable,
      email: email,
      telefono: telefono,
      direccion: direccion,
      descripcion: 'Nuevo restaurante',
      especialidad: 'Comida variada',
    );

    _negocios.add(nuevoNegocio);
    _passwords[email] = password;

    return nuevoNegocio;
  }

  @override
  Future<Negocio?> autenticarNegocio({
    required String email,
    required String password,
  }) async {
    // Buscar el negocio por email
    final negocio = _negocios.where((n) => n.email == email).firstOrNull;
    
    if (negocio == null) {
      return null; // Email no encontrado
    }

    // Verificar la contraseña
    if (_passwords[email] != password) {
      return null; // Contraseña incorrecta
    }

    return negocio;
  }

  @override
  Future<List<Negocio>> obtenerTodosLosNegocios() async {
    return List.from(_negocios);
  }

  @override
  Future<Negocio?> obtenerNegocioPorId(String id) async {
    try {
      return _negocios.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Negocio?> obtenerNegocioPorEmail(String email) async {
    try {
      return _negocios.firstWhere((n) => n.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> actualizarNegocio(Negocio negocio) async {
    try {
      final index = _negocios.indexWhere((n) => n.id == negocio.id);
      if (index != -1) {
        _negocios[index] = negocio;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, String>> obtenerHorariosServicio(String negocioId) async {
    return _horariosServicio[negocioId] ?? {
      'Almuerzo': '12:00 - 15:30',
      'Cena': '20:00 - 23:30',
    };
  }

  @override
  Future<bool> actualizarHorariosServicio(String negocioId, Map<String, String> horarios) async {
    try {
      _horariosServicio[negocioId] = Map.from(horarios);
      return true;
    } catch (e) {
      return false;
    }
  }
}
