import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../dominio/repositorios/negocio_repositorio.dart';
import '../../dominio/repositorios/reserva_repositorio.dart';
import 'pantalla_dueno_estados_de_cubit.dart';

class PantallaDuenoCubit extends Cubit<PantallaDuenoState> {
  final NegocioRepositorio negocioRepositorio;
  final MesaRepositorio mesaRepositorio;
  final ReservaRepositorio reservaRepositorio;

  PantallaDuenoCubit(
    this.negocioRepositorio,
    this.mesaRepositorio,
    this.reservaRepositorio,
  ) : super(const PantallaDuenoInitial());

  // Método para establecer un negocio autenticado directamente
  void establecerNegocioAutenticado(Negocio negocio) {
    emit(PantallaDuenoAutenticado(negocio));
  }

  Future<void> autenticar(String email, String password) async {
    try {
      emit(const PantallaDuenoLoading());

      final negocio = await negocioRepositorio.autenticarNegocio(
        email: email,
        password: password,
      );

      if (negocio != null) {
        emit(PantallaDuenoAutenticado(negocio));
      } else {
        emit(const PantallaDuenoError('Email o contraseña incorrectos'));
      }
    } catch (e) {
      emit(PantallaDuenoError('Error al autenticar: $e'));
    }
  }

  void cerrarSesion() {
    emit(const PantallaDuenoInitial());
  }

  void limpiarError() {
    emit(const PantallaDuenoInitial());
  }

  Future<bool> actualizarTelefono(Negocio negocio, String nuevoTelefono) async {
    try {
      final negocioActualizado = negocio.copyWith(telefono: nuevoTelefono);
      final exito = await negocioRepositorio.actualizarNegocio(negocioActualizado);
      
      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }
      
      return exito;
    } catch (e) {
      emit(PantallaDuenoError('Error al actualizar teléfono: $e'));
      return false;
    }
  }

  Future<bool> actualizarEspecialidad(Negocio negocio, String nuevaEspecialidad) async {
    try {
      final negocioActualizado = negocio.copyWith(especialidad: nuevaEspecialidad);
      final exito = await negocioRepositorio.actualizarNegocio(negocioActualizado);
      
      if (exito) {
        emit(PantallaDuenoAutenticado(negocioActualizado));
      }
      
      return exito;
    } catch (e) {
      emit(PantallaDuenoError('Error al actualizar especialidad: $e'));
      return false;
    }
  }

  Future<Map<String, String>> obtenerHorarios(String negocioId) async {
    return await negocioRepositorio.obtenerHorariosServicio(negocioId);
  }

  Future<bool> actualizarHorarios(String negocioId, Map<String, String> horarios) async {
    try {
      return await negocioRepositorio.actualizarHorariosServicio(negocioId, horarios);
    } catch (e) {
      emit(PantallaDuenoError('Error al actualizar horarios: $e'));
      return false;
    }
  }

  // Métodos para gestión de mesas
  Future<List<Mesa>> obtenerMesasDelNegocio(String negocioId) async {
    return await mesaRepositorio.obtenerMesasPorNegocio(negocioId);
  }

  Future<Mesa?> agregarMesa(String negocioId, String nombre, int capacidad) async {
    try {
      final nuevaMesa = Mesa(
        id: '', // Se generará en el repositorio
        nombre: nombre,
        capacidad: capacidad,
        negocioId: negocioId,
      );
      return await mesaRepositorio.agregarMesa(nuevaMesa);
    } catch (e) {
      emit(PantallaDuenoError('Error al agregar mesa: $e'));
      return null;
    }
  }

  Future<bool> actualizarMesa(Mesa mesa) async {
    try {
      return await mesaRepositorio.actualizarMesa(mesa);
    } catch (e) {
      emit(PantallaDuenoError('Error al actualizar mesa: $e'));
      return false;
    }
  }

  Future<bool> eliminarMesa(String mesaId) async {
    try {
      return await mesaRepositorio.eliminarMesa(mesaId);
    } catch (e) {
      emit(PantallaDuenoError('Error al eliminar mesa: $e'));
      return false;
    }
  }

  // Métodos para ver reservas
  Future<List<Reserva>> obtenerReservasDelNegocio(String negocioId) async {
    try {
      // Obtener todas las reservas y filtrar por negocio
      // Nota: Aquí asumimos que las reservas están asociadas a mesas del negocio
      final mesas = await mesaRepositorio.obtenerMesasPorNegocio(negocioId);
      final mesaIds = mesas.map((m) => m.id).toSet();
      
      final todasReservas = await reservaRepositorio.obtenerReserva();
      return todasReservas.where((r) => mesaIds.contains(r.mesaId)).toList();
    } catch (e) {
      emit(PantallaDuenoError('Error al obtener reservas: $e'));
      return [];
    }
  }
}
