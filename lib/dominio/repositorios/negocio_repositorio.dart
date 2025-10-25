import '../entidades/negocio.dart';

abstract class NegocioRepositorio {
  Future<Negocio?> registrarNegocio({
    required String nombre,
    required String nombreResponsable,
    required String email,
    required String telefono,
    required String direccion,
    required String password,
  });

  Future<Negocio?> autenticarNegocio({
    required String email,
    required String password,
  });

  Future<List<Negocio>> obtenerTodosLosNegocios();

  Future<Negocio?> obtenerNegocioPorId(String id);

  Future<Negocio?> obtenerNegocioPorEmail(String email);

  Future<bool> actualizarNegocio(Negocio negocio);

  Future<Map<String, String>> obtenerHorariosServicio(String negocioId);

  Future<bool> actualizarHorariosServicio(String negocioId, Map<String, String> horarios);
}
