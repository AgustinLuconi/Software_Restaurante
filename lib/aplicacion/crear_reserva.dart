import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/horario_apertura_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class CrearReserva {
  final ReservaRepositorio reservaRepositorio;
  final HorarioAperturaRepositorio? horarioAperturaRepositorio;

  CrearReserva(
    this.reservaRepositorio, {
    this.horarioAperturaRepositorio,
  });

  Future<Reserva> execute(
    String clienteId,
    String mesaId,
    DateTime fecha,
    DateTime hora,
    int numeroPersonas, {
    String? contactoCliente,
    String? nombreCliente,
    EstadoReserva estadoInicial = EstadoReserva.pendiente,
    String negocioId = 'negocio_1', // ID del negocio por defecto
  }) async {
    final now = DateTime.now();
    final fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    if (fechaHora.isBefore(now)) {
      throw Exception('La fecha y hora deben ser futuras.');
    }
    if (numeroPersonas <= 0) {
      throw Exception('El número de personas debe ser mayor a cero.');
    }
    
    // Verificar que el restaurante esté abierto en ese horario
    if (horarioAperturaRepositorio != null) {
      final estaAbierto = await horarioAperturaRepositorio!.estaAbiertoEn(
        negocioId,
        fechaHora,
      );
      
      if (!estaAbierto) {
        final mensajeError = await horarioAperturaRepositorio!.obtenerMensajeHorarioCerrado(
          negocioId,
          fechaHora,
        );
        throw Exception(mensajeError);
      }
    }
    
    // Verificar que la mesa esté disponible en ese horario
    final mesaDisponible = await reservaRepositorio.mesaDisponible(
      mesaId: mesaId,
      fecha: fecha,
      hora: fechaHora,
    );
    
    if (!mesaDisponible) {
      throw Exception('La mesa seleccionada ya está reservada en ese horario. Por favor elige otra mesa u otro horario.');
    }
    
    final reserva = Reserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clienteId: clienteId,
      mesaId: mesaId,
      fechaHora: fechaHora,
      numeroPersonas: numeroPersonas,
      estado: estadoInicial,
      contactoCliente: contactoCliente,
      nombreCliente: nombreCliente,
    );
    await reservaRepositorio.crearReserva(reserva);
    return reserva;
  }
}
