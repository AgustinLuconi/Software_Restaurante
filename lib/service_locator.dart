import 'package:get_it/get_it.dart';

// Adaptadores de Firestore (base de datos real)
import 'adaptadores/adaptador_firestore_reserva.dart';
import 'adaptadores/adaptador_firestore_mesa.dart';
import 'adaptadores/adaptador_firestore_negocio.dart';
import 'adaptadores/adaptador_firestore_horario.dart';
import 'adaptadores/adaptador_firestore_zona.dart';

// Servicios
import 'adaptadores/servicio_autenticacion_firebase.dart';
import 'adaptadores/servicio_email.dart';
import 'adaptadores/servicio_verificacion_cliente.dart';

// Casos de uso
import 'aplicacion/cancelar_reserva.dart';
import 'aplicacion/crear_reserva.dart';
import 'aplicacion/obtener_reserva.dart';

// Repositorios (interfaces)
import 'dominio/repositorios/horario_apertura_repositorio.dart';
import 'dominio/repositorios/mesa_repositorio.dart';
import 'dominio/repositorios/negocio_repositorio.dart';
import 'dominio/repositorios/reserva_repositorio.dart';
import 'dominio/repositorios/zona_repositorio.dart';

// Cubits
import 'presentacion/pantalla_dueno/pantalla_dueno_cubit.dart';
import 'presentacion/pantalla_inicio/pantalla_inicio_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Evitar registrar dos veces (puede pasar en hot reload)
  if (getIt.isRegistered<ReservaRepositorio>()) {
    return;
  }

  // ============================================================
  // SERVICIOS
  // ============================================================

  // Servicio de autenticación con Firebase
  getIt.registerLazySingleton<ServicioAutenticacion>(
    () => ServicioAutenticacion(),
  );

  // Servicio de verificación para clientes (SMS + localStorage)
  getIt.registerLazySingleton<ServicioVerificacionCliente>(
    () => ServicioVerificacionCliente(),
  );

  // Servicio de Email (envía correos via Firebase Trigger Email)
  getIt.registerLazySingleton<ServicioEmail>(() => ServicioEmail());

  // ============================================================
  // REPOSITORIOS (FIRESTORE)
  // ============================================================

  // Repositorio de reservas (primero, ya que otros dependen de él)
  getIt.registerLazySingleton<ReservaRepositorio>(
    () => ReservaRepositorioFirestore(),
  );

  // Repositorio de mesas (depende de reservas para verificar disponibilidad)
  getIt.registerLazySingleton<MesaRepositorio>(
    () => MesaRepositorioFirestore(
      reservaRepositorio: getIt<ReservaRepositorio>(),
    ),
  );

  // Repositorio de negocios
  getIt.registerLazySingleton<NegocioRepositorio>(
    () => NegocioRepositorioFirestore(),
  );

  // Repositorio de horarios de apertura
  getIt.registerLazySingleton<HorarioAperturaRepositorio>(
    () => HorarioAperturaRepositorioFirestore(),
  );

  // Repositorio de zonas
  getIt.registerLazySingleton<ZonaRepositorio>(() => AdaptadorFirestoreZona());

  // ============================================================
  // CASOS DE USO
  // ============================================================

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

  // ============================================================
  // CUBITS
  // ============================================================

  getIt.registerFactory(
    () => PantallaDuenoCubit(
      getIt<NegocioRepositorio>(),
      getIt<MesaRepositorio>(),
      getIt<ReservaRepositorio>(),
      getIt<ServicioEmail>(),
      getIt<HorarioAperturaRepositorio>(),
      getIt<ZonaRepositorio>(),
    ),
  );
  getIt.registerFactory(() => PantallaInicioCubit(getIt<NegocioRepositorio>()));
}
