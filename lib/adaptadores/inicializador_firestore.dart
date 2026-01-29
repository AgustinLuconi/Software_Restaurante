import 'package:cloud_firestore/cloud_firestore.dart';

/// Script para inicializar datos en Firestore
/// Este script crea los datos de ejemplo del restaurante Chiringuito
class InicializadorFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa todos los datos de ejemplo
  Future<void> inicializarDatos() async {
    print('🚀 Iniciando carga de datos en Firestore...');
    
    // 1. Verificar si ya existen datos
    final negociosExistentes = await _firestore.collection('negocios').limit(1).get();
    if (negociosExistentes.docs.isNotEmpty) {
      print('⚠️ Ya existen datos en Firestore. Cancelando inicialización.');
      return;
    }

    // 2. Crear el negocio Chiringuito
    final negocioId = await _crearNegocioChiringuito();
    if (negocioId == null) {
      print('❌ Error creando negocio. Abortando.');
      return;
    }

    // 3. Crear las mesas del negocio
    await _crearMesas(negocioId);

    // 4. Crear los horarios de apertura
    await _crearHorarios(negocioId);

    print('✅ Inicialización completada exitosamente');
  }

  Future<String?> _crearNegocioChiringuito() async {
    try {
      final docRef = await _firestore.collection('negocios').add({
        'nombre': 'Chiringuito',
        'nombreResponsable': 'Administrador',
        'email': 'gestor.reservas.restaurante@gmail.com',
        'telefono': '+54 261 123 4567',
        'direccion': 'Av. Costanera 1234, Mendoza',
        'password': 'chiringuito123', // En producción, usar hash
        'descripcion': 'Restaurante con vista al mar y cocina mediterránea',
        'especialidad': 'Mariscos y paella',
        'minHorasParaCancelar': 2,
        'maxDiasAnticipacionReserva': 30,
        'duracionPromedioMinutos': 60,
        'horariosAtencion': {
          'lunes': 'Cerrado',
          'martes': 'Cerrado',
          'miercoles': '12:00 - 15:30 / 20:00 - 23:30',
          'jueves': '12:00 - 15:30 / 20:00 - 23:30',
          'viernes': '12:00 - 15:30 / 20:00 - 23:30',
          'sabado': '12:00 - 16:00 / 20:00 - 00:00',
          'domingo': '12:00 - 16:00',
        },
      });
      
      print('✅ Negocio Chiringuito creado con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creando negocio: $e');
      return null;
    }
  }

  Future<void> _crearMesas(String negocioId) async {
    final mesas = [
      // Terraza - 3 mesas
      {'nombre': 'Terraza 1', 'capacidad': 2, 'zona': 'terraza'},
      {'nombre': 'Terraza 2', 'capacidad': 4, 'zona': 'terraza'},
      {'nombre': 'Terraza 3', 'capacidad': 6, 'zona': 'terraza'},
      // Salón - 3 mesas
      {'nombre': 'Salón 1', 'capacidad': 2, 'zona': 'salon'},
      {'nombre': 'Salón 2', 'capacidad': 4, 'zona': 'salon'},
      {'nombre': 'Salón 3', 'capacidad': 8, 'zona': 'salon'},
      // Jardín - 2 mesas
      {'nombre': 'Jardín 1', 'capacidad': 4, 'zona': 'jardin'},
      {'nombre': 'Jardín 2', 'capacidad': 6, 'zona': 'jardin'},
      // VIP - 1 mesa
      {'nombre': 'VIP Premium', 'capacidad': 10, 'zona': 'vip'},
    ];

    final batch = _firestore.batch();
    
    for (final mesa in mesas) {
      final docRef = _firestore.collection('mesas').doc();
      batch.set(docRef, {
        ...mesa,
        'negocioId': negocioId,
      });
    }

    await batch.commit();
    print('✅ ${mesas.length} mesas creadas');
  }

  Future<void> _crearHorarios(String negocioId) async {
    try {
      await _firestore.collection('horarios_apertura').add({
        'negocioId': negocioId,
        'horariosSemanal': [
          // Lunes - Cerrado
          {
            'nombreDia': 'Lunes',
            'cerrado': true,
            'intervalos': [],
          },
          // Martes - Cerrado
          {
            'nombreDia': 'Martes',
            'cerrado': true,
            'intervalos': [],
          },
          // Miércoles
          {
            'nombreDia': 'Miércoles',
            'cerrado': false,
            'intervalos': [
              {'horaInicio': 12, 'minutoInicio': 0, 'horaFin': 15, 'minutoFin': 30},
              {'horaInicio': 20, 'minutoInicio': 0, 'horaFin': 23, 'minutoFin': 30},
            ],
          },
          // Jueves
          {
            'nombreDia': 'Jueves',
            'cerrado': false,
            'intervalos': [
              {'horaInicio': 12, 'minutoInicio': 0, 'horaFin': 15, 'minutoFin': 30},
              {'horaInicio': 20, 'minutoInicio': 0, 'horaFin': 23, 'minutoFin': 30},
            ],
          },
          // Viernes
          {
            'nombreDia': 'Viernes',
            'cerrado': false,
            'intervalos': [
              {'horaInicio': 12, 'minutoInicio': 0, 'horaFin': 15, 'minutoFin': 30},
              {'horaInicio': 20, 'minutoInicio': 0, 'horaFin': 23, 'minutoFin': 30},
            ],
          },
          // Sábado
          {
            'nombreDia': 'Sábado',
            'cerrado': false,
            'intervalos': [
              {'horaInicio': 12, 'minutoInicio': 0, 'horaFin': 16, 'minutoFin': 0},
              {'horaInicio': 20, 'minutoInicio': 0, 'horaFin': 24, 'minutoFin': 0},
            ],
          },
          // Domingo
          {
            'nombreDia': 'Domingo',
            'cerrado': false,
            'intervalos': [
              {'horaInicio': 12, 'minutoInicio': 0, 'horaFin': 16, 'minutoFin': 0},
            ],
          },
        ],
      });
      
      print('✅ Horarios de apertura creados');
    } catch (e) {
      print('❌ Error creando horarios: $e');
    }
  }
}
