import 'package:cloud_firestore/cloud_firestore.dart';

import '../dominio/entidades/reserva.dart';

/// Servicio centralizado para enviar emails a clientes y dueños
///
/// Este servicio reemplaza el antiguo sistema de notificaciones in-app (campanita)
/// y envía todas las comunicaciones directamente por email.
class ServicioEmail {
  /// Nombre del restaurante (se puede configurar)
  static const String _nombreApp = 'Sistema de Reservas';

  // ============================================================
  // EMAILS AL CLIENTE
  // ============================================================

  /// Envía email de confirmación de reserva al cliente
  Future<void> enviarReservaConfirmada({
    required String emailCliente,
    required String nombreCliente,
    required String nombreNegocio,
    required DateTime fechaHora,
    required String nombreMesa,
    required int numeroPersonas,
    String? telefono,
    String? reservaId,
  }) async {
    final fecha = _formatearFecha(fechaHora);
    final hora = _formatearHora(fechaHora);

    final html = _wrapTemplate(
      titulo: '✅ Reserva Confirmada',
      contenido: '''
        <h2 style="color: #333; margin-bottom: 20px;">¡Tu reserva ha sido confirmada!</h2>
        
        <p style="font-size: 16px; color: #666;">
          Hola $nombreCliente, tu reserva está confirmada. Te esperamos en:
        </p>

        ${_buildDetallesReserva(nombreCliente: nombreCliente, nombreNegocio: nombreNegocio, nombreMesa: nombreMesa, fecha: fecha, hora: hora, personas: numeroPersonas)}

        <div style="background-color: #E8F5E9; padding: 15px; border-left: 4px solid #4CAF50; margin: 20px 0;">
          <p style="margin: 0; color: #2E7D32;">
            <strong>✅ Estado:</strong> Confirmada
          </p>
        </div>

        <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin-top: 20px;">
          <p style="margin: 0; font-size: 14px; color: #666;">
            <strong>💡 Importante:</strong>
          </p>
          <ul style="margin: 10px 0; color: #666; font-size: 14px;">
            <li>Llega 10 minutos antes de tu reserva</li>
            <li>Si necesitas cancelar, hazlo con al menos 2 horas de anticipación</li>
            <li>Guarda este email para consultar los detalles</li>
          </ul>
        </div>

        <p style="color: #666; font-size: 14px; margin-top: 20px;">
          ¿Necesitas ayuda? Contacta directamente con $nombreNegocio.
        </p>
      ''',
    );

    await _enviarEmail(
      to: emailCliente,
      subject: '✅ Reserva confirmada - $nombreNegocio',
      html: html,
    );

    print('📧 Email de confirmación enviado a: $emailCliente');
  }

  /// Envía email cuando el CLIENTE cancela su propia reserva
  Future<void> enviarReservaCanceladaPorCliente({
    required String emailCliente,
    required String nombreCliente,
    required String nombreNegocio,
    required DateTime fechaHora,
    required String nombreMesa,
    required int numeroPersonas,
  }) async {
    final fecha = _formatearFecha(fechaHora);
    final hora = _formatearHora(fechaHora);

    final html = _wrapTemplate(
      titulo: 'Reserva Cancelada',
      contenido: '''
        <h2 style="color: #333; margin-bottom: 20px;">Reserva cancelada</h2>
        
        <p style="font-size: 16px; color: #666;">
          Tu reserva ha sido cancelada exitosamente.
        </p>

        ${_buildDetallesReserva(nombreCliente: nombreCliente, nombreNegocio: nombreNegocio, nombreMesa: nombreMesa, fecha: fecha, hora: hora, personas: numeroPersonas)}

        <div style="background-color: #FFEBEE; padding: 15px; border-left: 4px solid #F44336; margin: 20px 0;">
          <p style="margin: 0; color: #C62828;">
            <strong>❌ Estado:</strong> Cancelada
          </p>
        </div>

        <p style="color: #666; font-size: 14px;">
          Esperamos verte pronto. Puedes hacer una nueva reserva cuando quieras.
        </p>
      ''',
    );

    await _enviarEmail(
      to: emailCliente,
      subject: 'Reserva cancelada - $nombreNegocio',
      html: html,
    );

    print('📧 Email de cancelación (por cliente) enviado a: $emailCliente');
  }

  /// Envía email cuando el RESTAURANTE cancela la reserva del cliente
  Future<void> enviarReservaCanceladaPorRestaurante({
    required String emailCliente,
    required String nombreCliente,
    required String nombreNegocio,
    required DateTime fechaHora,
    required String nombreMesa,
    required int numeroPersonas,
    String? motivo,
  }) async {
    final fecha = _formatearFecha(fechaHora);
    final hora = _formatearHora(fechaHora);

    final motivoHtml =
        motivo != null && motivo.isNotEmpty
            ? '''
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <p style="margin: 0; color: #666; font-size: 14px;">
              <strong>📝 Motivo:</strong><br>
              $motivo
            </p>
          </div>
        '''
            : '';

    final html = _wrapTemplate(
      titulo: '⚠️ Reserva Cancelada',
      contenido: '''
        <h2 style="color: #333; margin-bottom: 20px;">Tu reserva ha sido cancelada</h2>
        
        <div style="background-color: #FFF3CD; padding: 15px; border-left: 4px solid #FF9800; margin: 20px 0;">
          <p style="margin: 0; color: #856404;">
            <strong>⚠️ Atención:</strong> El restaurante ha cancelado tu reserva.
          </p>
        </div>

        ${_buildDetallesReserva(nombreCliente: nombreCliente, nombreNegocio: nombreNegocio, nombreMesa: nombreMesa, fecha: fecha, hora: hora, personas: numeroPersonas)}

        $motivoHtml

        <p style="color: #666; font-size: 16px;">
          Lamentamos los inconvenientes. Puedes hacer una nueva reserva para otra fecha.
        </p>

        <p style="color: #666; font-size: 14px;">
          Si tienes dudas, contacta directamente con $nombreNegocio.
        </p>
      ''',
    );

    await _enviarEmail(
      to: emailCliente,
      subject: '⚠️ Tu reserva ha sido cancelada - $nombreNegocio',
      html: html,
    );

    print('📧 Email de cancelación (por restaurante) enviado a: $emailCliente');
  }

  // ============================================================
  // EMAILS AL DUEÑO DEL RESTAURANTE
  // ============================================================

  /// Notifica al dueño sobre una nueva reserva
  Future<void> enviarNuevaReservaAlDueno({
    required String emailDueno,
    required String nombreCliente,
    required String emailCliente,
    required String? telefonoCliente,
    required DateTime fechaHora,
    required String nombreMesa,
    required int numeroPersonas,
    required String nombreNegocio,
  }) async {
    final fecha = _formatearFecha(fechaHora);
    final hora = _formatearHora(fechaHora);

    final html = _wrapTemplate(
      titulo: '📋 Nueva Reserva',
      contenido: '''
        <h2 style="color: #333; margin-bottom: 20px;">📋 Nueva Reserva Recibida</h2>
        
        <p style="font-size: 16px; color: #666;">
          Tienes una nueva reserva confirmada en $nombreNegocio:
        </p>

        ${_buildDetallesReserva(nombreCliente: nombreCliente, nombreNegocio: nombreNegocio, nombreMesa: nombreMesa, fecha: fecha, hora: hora, personas: numeroPersonas)}

        <div style="background-color: #E8F5E9; padding: 15px; border-left: 4px solid #4CAF50; margin: 20px 0;">
          <p style="margin: 0; color: #2E7D32;">
            <strong>📧 Email cliente:</strong> $emailCliente<br>
            ${telefonoCliente != null ? '<strong>📱 Teléfono:</strong> $telefonoCliente' : ''}
          </p>
        </div>
      ''',
    );

    await _enviarEmail(
      to: emailDueno,
      subject: '🔔 Nueva reserva - $fecha $hora',
      html: html,
    );

    print('📧 Email de nueva reserva enviado al dueño: $emailDueno');
  }

  /// Notifica al dueño cuando un cliente cancela su reserva
  Future<void> enviarCancelacionClienteAlDueno({
    required String emailDueno,
    required String nombreCliente,
    required DateTime fechaHora,
    required String nombreMesa,
    required int numeroPersonas,
    required String nombreNegocio,
  }) async {
    final fecha = _formatearFecha(fechaHora);
    final hora = _formatearHora(fechaHora);

    final html = _wrapTemplate(
      titulo: '❌ Reserva Cancelada',
      contenido: '''
        <h2 style="color: #333; margin-bottom: 20px;">Un cliente ha cancelado su reserva</h2>
        
        ${_buildDetallesReserva(nombreCliente: nombreCliente, nombreNegocio: nombreNegocio, nombreMesa: nombreMesa, fecha: fecha, hora: hora, personas: numeroPersonas)}

        <div style="background-color: #FFEBEE; padding: 15px; border-left: 4px solid #F44336; margin: 20px 0;">
          <p style="margin: 0; color: #C62828;">
            <strong>ℹ️</strong> La mesa ha quedado disponible para ese horario.
          </p>
        </div>
      ''',
    );

    await _enviarEmail(
      to: emailDueno,
      subject: '❌ Reserva cancelada por cliente - $fecha $hora',
      html: html,
    );

    print('📧 Email de cancelación por cliente enviado al dueño: $emailDueno');
  }

  // ============================================================
  // MÉTODOS DE CONVENIENCIA (para usar con entidades Reserva)
  // ============================================================

  /// Envía confirmación al cliente usando la entidad Reserva
  Future<void> notificarReservaConfirmada(
    Reserva reserva, {
    required String nombreNegocio,
    required String nombreMesa,
    String? emailDueno,
  }) async {
    final email = reserva.contactoCliente;
    if (email == null || !email.contains('@')) {
      print('⚠️ No se puede enviar email: contacto no es email válido');
      return;
    }

    await enviarReservaConfirmada(
      emailCliente: email,
      nombreCliente: reserva.nombreCliente ?? 'Cliente',
      nombreNegocio: nombreNegocio,
      fechaHora: reserva.fechaHora,
      nombreMesa: nombreMesa,
      numeroPersonas: reserva.numeroPersonas,
      reservaId: reserva.id,
    );

    // También notificar al dueño si tenemos su email
    if (emailDueno != null) {
      await enviarNuevaReservaAlDueno(
        emailDueno: emailDueno,
        nombreCliente: reserva.nombreCliente ?? 'Cliente',
        emailCliente: email,
        telefonoCliente: null, // Se podría agregar si está disponible
        fechaHora: reserva.fechaHora,
        nombreMesa: nombreMesa,
        numeroPersonas: reserva.numeroPersonas,
        nombreNegocio: nombreNegocio,
      );
    }
  }

  /// Envía notificación de cancelación por cliente
  Future<void> notificarReservaCanceladaPorCliente(
    Reserva reserva, {
    required String nombreNegocio,
    required String nombreMesa,
    String? emailDueno,
  }) async {
    final email = reserva.contactoCliente;
    if (email == null || !email.contains('@')) {
      print('⚠️ No se puede enviar email: contacto no es email válido');
      return;
    }

    await enviarReservaCanceladaPorCliente(
      emailCliente: email,
      nombreCliente: reserva.nombreCliente ?? 'Cliente',
      nombreNegocio: nombreNegocio,
      fechaHora: reserva.fechaHora,
      nombreMesa: nombreMesa,
      numeroPersonas: reserva.numeroPersonas,
    );

    // También notificar al dueño
    if (emailDueno != null) {
      await enviarCancelacionClienteAlDueno(
        emailDueno: emailDueno,
        nombreCliente: reserva.nombreCliente ?? 'Cliente',
        fechaHora: reserva.fechaHora,
        nombreMesa: nombreMesa,
        numeroPersonas: reserva.numeroPersonas,
        nombreNegocio: nombreNegocio,
      );
    }
  }

  /// Envía notificación de cancelación por el restaurante
  Future<void> notificarReservaCanceladaPorRestaurante(
    Reserva reserva, {
    required String nombreNegocio,
    required String nombreMesa,
    String? motivo,
  }) async {
    final email = reserva.contactoCliente;
    if (email == null || !email.contains('@')) {
      print('⚠️ No se puede enviar email: contacto no es email válido');
      return;
    }

    await enviarReservaCanceladaPorRestaurante(
      emailCliente: email,
      nombreCliente: reserva.nombreCliente ?? 'Cliente',
      nombreNegocio: nombreNegocio,
      fechaHora: reserva.fechaHora,
      nombreMesa: nombreMesa,
      numeroPersonas: reserva.numeroPersonas,
      motivo: motivo,
    );
  }

  // ============================================================
  // MÉTODOS PRIVADOS - Templates y envío
  // ============================================================

  /// Función base para enviar emails usando Firebase Trigger Email Extension
  /// Los emails se agregan a la colección 'mail' en Firestore y la extensión
  /// los procesa automáticamente para enviarlos via SMTP.
  Future<void> _enviarEmail({
    required String to,
    required String subject,
    required String html,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📧 Preparando email...');
      print('Para: $to');
      print('Asunto: $subject');

      // Agregar documento a Firestore - la extensión Trigger Email lo procesará
      final docRef = await FirebaseFirestore.instance.collection('mail').add({
        'to': [to], // La extensión espera un array de destinatarios
        'message': {
          'subject': subject,
          'html': html,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Email agregado a cola de envío');
      print('📋 ID del documento: ${docRef.id}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ Error al agregar email a Firestore: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// Template base HTML con estilos
  String _wrapTemplate({required String titulo, required String contenido}) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: white;">
    
    <!-- Header -->
    <div style="background-color: #27AE60; padding: 30px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 24px;">$titulo</h1>
    </div>

    <!-- Content -->
    <div style="padding: 30px;">
      $contenido
    </div>

    <!-- Footer -->
    <div style="background-color: #f5f5f5; padding: 20px; text-align: center; border-top: 1px solid #ddd;">
      <p style="margin: 0; color: #666; font-size: 12px;">
        © ${DateTime.now().year} $_nombreApp
      </p>
      <p style="margin: 8px 0 0 0; color: #999; font-size: 11px;">
        Este es un email automático, por favor no respondas a este mensaje.
      </p>
    </div>

  </div>
</body>
</html>
    ''';
  }

  /// Construye la tabla de detalles de reserva
  String _buildDetallesReserva({
    required String nombreCliente,
    required String nombreNegocio,
    required String nombreMesa,
    required String fecha,
    required String hora,
    required int personas,
  }) {
    return '''
<table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
  <tr>
    <td style="padding: 12px 0; color: #666; font-size: 14px; border-bottom: 1px solid #eee;">
      👤 Nombre:
    </td>
    <td style="padding: 12px 0; font-weight: bold; font-size: 14px; border-bottom: 1px solid #eee;">
      $nombreCliente
    </td>
  </tr>
  <tr>
    <td style="padding: 12px 0; color: #666; font-size: 14px; border-bottom: 1px solid #eee;">
      🏪 Restaurante:
    </td>
    <td style="padding: 12px 0; font-weight: bold; font-size: 14px; border-bottom: 1px solid #eee;">
      $nombreNegocio
    </td>
  </tr>
  <tr>
    <td style="padding: 12px 0; color: #666; font-size: 14px; border-bottom: 1px solid #eee;">
      📍 Mesa:
    </td>
    <td style="padding: 12px 0; font-weight: bold; font-size: 14px; border-bottom: 1px solid #eee;">
      $nombreMesa
    </td>
  </tr>
  <tr>
    <td style="padding: 12px 0; color: #666; font-size: 14px; border-bottom: 1px solid #eee;">
      📅 Fecha:
    </td>
    <td style="padding: 12px 0; font-weight: bold; font-size: 14px; border-bottom: 1px solid #eee;">
      $fecha
    </td>
  </tr>
  <tr>
    <td style="padding: 12px 0; color: #666; font-size: 14px; border-bottom: 1px solid #eee;">
      🕐 Horario:
    </td>
    <td style="padding: 12px 0; font-weight: bold; font-size: 14px; border-bottom: 1px solid #eee;">
      $hora
    </td>
  </tr>
  <tr>
    <td style="padding: 12px 0; color: #666; font-size: 14px;">
      👥 Personas:
    </td>
    <td style="padding: 12px 0; font-weight: bold; font-size: 14px;">
      $personas
    </td>
  </tr>
</table>
    ''';
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    const dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    final diaSemana = dias[fecha.weekday - 1];
    final dia = fecha.day;
    final mes = meses[fecha.month - 1];
    final anio = fecha.year;

    return '$diaSemana $dia de $mes de $anio';
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto hs';
  }
}
