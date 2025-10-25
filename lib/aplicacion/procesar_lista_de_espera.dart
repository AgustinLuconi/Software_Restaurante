import '../dominio/repositorios/reserva_repositorio.dart';
import '../dominio/repositorios/lista_espera_repositorio.dart';
import '../dominio/servicios/servicio_notificaciones.dart';
import 'package:intl/intl.dart';

class ProcesarListaDeEspera {
  final ReservaRepositorio reservaRepositorio;
  final ListaEsperaRepositorio listaEsperaRepositorio;
  final ServicioNotificaciones servicioNotificaciones;

  ProcesarListaDeEspera(
    this.reservaRepositorio,
    this.listaEsperaRepositorio,
    this.servicioNotificaciones,
  );

  Future<void> ejecutar(String reservaId) async {
    // 1. Obtener la reserva cancelada
    final reserva = await reservaRepositorio.obtenerReservaPorId(reservaId);

    if (reserva == null) {
      throw Exception('Reserva no encontrada con ID: $reservaId');
    }

    // 2. Consultar entradas en lista de espera para ese slot
    final entradasEnEspera = await listaEsperaRepositorio.obtenerEntradasParaSlot(
      reserva.fechaHora,
      reserva.fechaHora,
    );

    // 3. Si hay entradas, procesar la primera (FIFO)
    if (entradasEnEspera.isNotEmpty) {
      final primeraEntrada = entradasEnEspera.first;

      // Formatear fecha y hora para el mensaje
      final formatoFecha = DateFormat('dd/MM/yyyy');
      final formatoHora = DateFormat('HH:mm');
      final fechaStr = formatoFecha.format(reserva.fechaHora);
      final horaStr = formatoHora.format(reserva.fechaHora);

      // Crear mensaje de notificación
      final mensaje = '''
¡Buenas noticias! Se ha liberado una mesa para el ${fechaStr} a las ${horaStr}.
Mesa disponible para ${primeraEntrada.numeroPersonas} personas.
Por favor, confirma tu reserva lo antes posible.
      ''';

      // Notificar al usuario
      await servicioNotificaciones.notificarDisponibilidad(
        primeraEntrada.usuarioId,
        mensaje,
      );

      // Eliminar la entrada de la lista de espera
      await listaEsperaRepositorio.eliminarEntrada(primeraEntrada.id);

      print('✅ Se procesó la lista de espera para la reserva $reservaId');
      print('   Usuario notificado: ${primeraEntrada.usuarioId}');
    } else {
      print('ℹ️  No hay entradas en lista de espera para este horario');
    }
  }
}
