import 'package:get_it/get_it.dart';

import 'adaptadores/adaptador_memoria_mesa.dart';
import 'adaptadores/adaptador_memoria_reserva.dart';
import 'adaptadores/adaptador_memoria_codigo_verificacion.dart';
import 'adaptadores/adaptador_memoria_horario_apertura.dart';
import 'adaptadores/adaptador_memoria_negocio.dart';
import 'adaptadores/servicio_autenticacion_firebase.dart';
import 'adaptadores/servicio_email.dart';
import 'adaptadores/servicio_verificacion_cliente.dart';
import 'aplicacion/cancelar_reserva.dart';
import 'aplicacion/crear_reserva.dart';
import 'aplicacion/obtener_reserva.dart';
import 'dominio/entidades/mesa.dart';
import 'dominio/repositorios/codigo_verificacion_repositorio.dart';
import 'dominio/repositorios/horario_apertura_repositorio.dart';
import 'dominio/repositorios/mesa_repositorio.dart';
import 'dominio/repositorios/negocio_repositorio.dart';
import 'dominio/repositorios/reserva_repositorio.dart';
import 'presentacion/pantalla_dueno/pantalla_dueno_cubit.dart';
import 'presentacion/pantalla_inicio/pantalla_inicio_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Evitar registrar dos veces (puede pasar en hot reload)
  if (getIt.isRegistered<ReservaRepositorio>()) {
    return;
  }

  // Servicio de autenticación con Firebase
  getIt.registerLazySingleton<ServicioAutenticacion>(
    () => ServicioAutenticacion(),
  );

  // Servicio de verificación para clientes (SMS + localStorage)
  getIt.registerLazySingleton<ServicioVerificacionCliente>(
    () => ServicioVerificacionCliente(),
  );

  // Datos de ejemplo para mesas del restaurante Chiringuito (negocio_1)
  // Ahora con zonas asignadas
  final mesasEjemplo = [
    // Terraza - 3 mesas
    Mesa(
      id: '1',
      nombre: 'Terraza 1',
      capacidad: 2,
      negocioId: 'negocio_1',
      zona: ZonaMesa.terraza,
    ),
    Mesa(
      id: '2',
      nombre: 'Terraza 2',
      capacidad: 4,
      negocioId: 'negocio_1',
      zona: ZonaMesa.terraza,
    ),
    Mesa(
      id: '3',
      nombre: 'Terraza 3',
      capacidad: 6,
      negocioId: 'negocio_1',
      zona: ZonaMesa.terraza,
    ),
    // Salón - 3 mesas
    Mesa(
      id: '4',
      nombre: 'Salón 1',
      capacidad: 2,
      negocioId: 'negocio_1',
      zona: ZonaMesa.salon,
    ),
    Mesa(
      id: '5',
      nombre: 'Salón 2',
      capacidad: 4,
      negocioId: 'negocio_1',
      zona: ZonaMesa.salon,
    ),
    Mesa(
      id: '6',
      nombre: 'Salón 3',
      capacidad: 8,
      negocioId: 'negocio_1',
      zona: ZonaMesa.salon,
    ),
    // Jardín - 2 mesas
    Mesa(
      id: '7',
      nombre: 'Jardín 1',
      capacidad: 4,
      negocioId: 'negocio_1',
      zona: ZonaMesa.jardin,
    ),
    Mesa(
      id: '8',
      nombre: 'Jardín 2',
      capacidad: 6,
      negocioId: 'negocio_1',
      zona: ZonaMesa.jardin,
    ),
    // VIP - 1 mesa
    Mesa(
      id: '9',
      nombre: 'VIP Premium',
      capacidad: 10,
      negocioId: 'negocio_1',
      zona: ZonaMesa.vip,
    ),
  ];

  // Registrar repositorios como singletons
  getIt.registerLazySingleton<ReservaRepositorio>(
    () => ReservaRepositorioMemoria(),
  );

  getIt.registerLazySingleton<MesaRepositorio>(
    () => MesaRepositorioMemoria(
      mesasEjemplo,
      reservaRepositorio: getIt<ReservaRepositorio>(),
    ),
  );

  getIt.registerLazySingleton<NegocioRepositorio>(
    () => NegocioRepositorioMemoria(),
  );

  // Servicio de Email (reemplaza las notificaciones in-app)
  getIt.registerLazySingleton<ServicioEmail>(() => ServicioEmail());

  getIt.registerLazySingleton<CodigoVerificacionRepositorio>(
    () => CodigoVerificacionRepositorioMemoria(),
  );

  getIt.registerLazySingleton<HorarioAperturaRepositorio>(
    () => HorarioAperturaRepositorioMemoria(),
  );

  // Registrar casos de uso
  getIt.registerFactory(
    () => CrearReserva(
      getIt<ReservaRepositorio>(),
      mesaRepositorio: getIt<MesaRepositorio>(),
      horarioAperturaRepositorio: getIt<HorarioAperturaRepositorio>(),
      negocioRepositorio: getIt<NegocioRepositorio>(),
    ),
  );

  // CancelarReserva
  getIt.registerFactory(
    () => CancelarReserva(
      getIt<ReservaRepositorio>(),
      negocioRepositorio: getIt<NegocioRepositorio>(),
    ),
  );

  getIt.registerFactory(() => ObtenerReserva(getIt<ReservaRepositorio>()));

  // Cubits
  getIt.registerFactory(
    () => PantallaDuenoCubit(
      getIt<NegocioRepositorio>(),
      getIt<MesaRepositorio>(),
      getIt<ReservaRepositorio>(),
      getIt<ServicioEmail>(),
    ),
  );
  getIt.registerFactory(() => PantallaInicioCubit(getIt<NegocioRepositorio>()));
}
