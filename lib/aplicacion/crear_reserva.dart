import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/horario_apertura_repositorio.dart';
import '../dominio/repositorios/mesa_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class CrearReserva {
  final ReservaRepositorio reservaRepositorio;
  final MesaRepositorio? mesaRepositorio;
  final HorarioAperturaRepositorio? horarioAperturaRepositorio;

  CrearReserva(
    this.reservaRepositorio, {
    this.mesaRepositorio,
    this.horarioAperturaRepositorio,
  });

  Future<Reserva> ejecutar(
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
    
    // Validar que la reserva no sea mayor a 2 semanas (14 días)
    final maximoFechaReserva = now.add(const Duration(days: 14));
    if (fechaHora.isAfter(maximoFechaReserva)) {
      throw Exception('Solo se pueden hacer reservas hasta dentro de 2 semanas como máximo.');
    }
    
    if (numeroPersonas <= 0) {
      throw Exception('El número de personas debe ser mayor a cero.');
    }
    
    // Validar que la mesa tenga capacidad adecuada para el número de personas
    if (mesaRepositorio != null) {
      final mesa = await mesaRepositorio!.obtenerMesaPorId(mesaId);
      
      if (mesa == null) {
        throw Exception('La mesa seleccionada no existe.');
      }
      
      // Verificar que la mesa puede acomodar al grupo
      if (!mesa.puedeAcomodar(numeroPersonas)) {
        // Determinar el mensaje específico según el problema
        if (mesa.capacidad < numeroPersonas) {
          throw Exception(
            'La mesa seleccionada tiene capacidad para ${mesa.capacidad} persona${mesa.capacidad > 1 ? 's' : ''}, '
            'pero has indicado ${numeroPersonas} personas. '
            'Por favor, selecciona una mesa con mayor capacidad.'
          );
        } else {
          // La mesa es demasiado grande (diferencia > 3)
          final diferencia = mesa.capacidad - numeroPersonas;
          throw Exception(
            'La mesa seleccionada tiene capacidad para ${mesa.capacidad} personas, '
            'pero solo necesitas ${numeroPersonas}. La diferencia es de $diferencia lugares. '
            'Por favor, selecciona una mesa más adecuada (máximo +3 lugares de diferencia).'
          );
        }
      }
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
