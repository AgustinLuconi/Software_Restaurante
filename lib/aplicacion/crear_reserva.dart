import '../dominio/entidades/reserva.dart';
import '../dominio/repositorios/horario_apertura_repositorio.dart';
import '../dominio/repositorios/mesa_repositorio.dart';
import '../dominio/repositorios/negocio_repositorio.dart';
import '../dominio/repositorios/reserva_repositorio.dart';

class CrearReserva {
  final ReservaRepositorio reservaRepositorio;
  final MesaRepositorio mesaRepositorio;
  final HorarioAperturaRepositorio horarioAperturaRepositorio;
  final NegocioRepositorio negocioRepositorio;

  CrearReserva(
    this.reservaRepositorio, {
    required this.mesaRepositorio,
    required this.horarioAperturaRepositorio,
    required this.negocioRepositorio,
  });

  Future<Reserva> ejecutar(
    String mesaId,
    DateTime fecha,
    DateTime hora,
    int numeroPersonas, {
    String? contactoCliente,
    String? nombreCliente,
    EstadoReserva estadoInicial = EstadoReserva.pendiente,
    required String negocioId,
  }) async {
    final now = DateTime.now();
    final fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    if (fechaHora.isBefore(now)) {
      throw Exception('La fecha y hora deben ser futuras.');
    }
    
    // Obtener configuración del negocio
    final negocio = await negocioRepositorio.obtenerNegocioPorId(negocioId);
    final maxDiasAnticipacion = negocio?.maxDiasAnticipacionReserva ?? 14;
    final duracionMinutos = negocio?.duracionPromedioMinutos ?? 60;
    
    // Validar que la reserva no sea mayor al límite configurado
    final maximoFechaReserva = now.add(Duration(days: maxDiasAnticipacion));
    if (fechaHora.isAfter(maximoFechaReserva)) {
      throw Exception('Solo se pueden hacer reservas hasta dentro de $maxDiasAnticipacion días como máximo.');
    }
    
    if (numeroPersonas <= 0) {
      throw Exception('El número de personas debe ser mayor a cero.');
    }
    
    // Validar que la mesa tenga capacidad adecuada para el número de personas
    final mesa = await mesaRepositorio.obtenerMesaPorId(mesaId);
    
    if (mesa == null) {
      throw Exception('La mesa seleccionada no existe.');
    }
    
    // Verificar que la mesa puede acomodar al grupo
    if (!mesa.puedeAcomodar(numeroPersonas)) {
      if (mesa.capacidad < numeroPersonas) {
        throw Exception(
          'La mesa seleccionada tiene capacidad para ${mesa.capacidad} persona${mesa.capacidad > 1 ? 's' : ''}, '
          'pero has indicado ${numeroPersonas} personas. '
          'Por favor, selecciona una mesa con mayor capacidad.'
        );
      } else {
        final diferencia = mesa.capacidad - numeroPersonas;
        throw Exception(
          'La mesa seleccionada tiene capacidad para ${mesa.capacidad} personas, '
          'pero solo necesitas ${numeroPersonas}. La diferencia es de $diferencia lugares. '
          'Por favor, selecciona una mesa más adecuada (máximo +3 lugares de diferencia).'
        );
      }
    }
    
    // Verificar que el restaurante esté abierto en ese horario
    final estaAbierto = await horarioAperturaRepositorio.estaAbiertoEn(
      negocioId,
      fechaHora,
    );
    
    if (!estaAbierto) {
      final mensajeError = await horarioAperturaRepositorio.obtenerMensajeHorarioCerrado(
        negocioId,
        fechaHora,
      );
      throw Exception(mensajeError);
    }
    
    // Verificar que la mesa esté disponible en ese horario
    final mesaDisponible = await reservaRepositorio.mesaDisponible(
      mesaId: mesaId,
      fecha: fecha,
      hora: fechaHora,
      duracionMinutos: duracionMinutos,
    );
    
    if (!mesaDisponible) {
      throw Exception('La mesa seleccionada ya está reservada en ese horario. Por favor elige otra mesa u otro horario.');
    }
    
    final reservaTemporal = Reserva(
      id: '',
      mesaId: mesaId,
      fechaHora: fechaHora,
      numeroPersonas: numeroPersonas,
      duracionMinutos: duracionMinutos,
      estado: estadoInicial,
      contactoCliente: contactoCliente,
      nombreCliente: nombreCliente,
    );
    // Firestore genera el ID automáticamente
    final reserva = await reservaRepositorio.crearReserva(reservaTemporal);
    return reserva;
  }
}
