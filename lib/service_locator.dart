import 'package:get_it/get_it.dart';

import 'adaptadores/adaptador_en_memoria_mesa.dart';
import 'adaptadores/adaptador_en_memoria_reserva.dart';
import 'adaptadores/lista_espera_repositorio_memoria.dart';
import 'adaptadores/negocio_repositorio_memoria.dart';
import 'adaptadores/servicio_notificaciones_consola.dart';
import 'aplicacion/agregar_a_lista_de_espera.dart';
import 'aplicacion/cancelar_reserva.dart';
import 'aplicacion/crear_reserva.dart';
import 'aplicacion/obtener_mesas_disponibles.dart';
import 'aplicacion/obtener_reserva.dart';
import 'aplicacion/procesar_lista_de_espera.dart';
import 'aplicacion/ver_reserva.dart';
import 'dominio/entidades/mesa.dart';
import 'dominio/repositorios/lista_espera_repositorio.dart';
import 'dominio/repositorios/mesa_repositorio.dart';
import 'dominio/repositorios/negocio_repositorio.dart';
import 'dominio/repositorios/reserva_repositorio.dart';
import 'dominio/servicios/servicio_notificaciones.dart';
import 'presentacion/pantalla_dueno/pantalla_dueno_cubit.dart';
import 'presentacion/pantalla_inicio/pantalla_inicio_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Datos de ejemplo para mesas del restaurante Chiringuito (negocio_1)
  final mesasEjemplo = [
    Mesa(id: '1', nombre: 'Mesa 1', capacidad: 2, negocioId: 'negocio_1'),
    Mesa(id: '2', nombre: 'Mesa 2', capacidad: 4, negocioId: 'negocio_1'),
    Mesa(id: '3', nombre: 'Mesa 3', capacidad: 6, negocioId: 'negocio_1'),
    Mesa(id: '4', nombre: 'Mesa 4', capacidad: 8, negocioId: 'negocio_1'),
  ];

  // Registrar repositorios como singletons
  getIt.registerLazySingleton<ReservaRepositorio>(
    () => ReservaRepositorioMemoria(),
  );

  getIt.registerLazySingleton<MesaRepositorio>(
    () => MesaRepositorioMemoria(mesasEjemplo),
  );

  getIt.registerLazySingleton<ListaEsperaRepositorio>(
    () => ListaEsperaRepositorioMemoria(),
  );

  getIt.registerLazySingleton<NegocioRepositorio>(
    () => NegocioRepositorioMemoria(),
  );

  // Registrar servicios
  getIt.registerLazySingleton<ServicioNotificaciones>(
    () => ServicioNotificacionesConsola(),
  );

  // Registrar casos de uso
  getIt.registerFactory(() => CrearReserva(getIt<ReservaRepositorio>()));
  
  // CancelarReserva con ProcesarListaDeEspera
  getIt.registerFactory(() => CancelarReserva(
        getIt<ReservaRepositorio>(),
        procesarListaDeEspera: getIt<ProcesarListaDeEspera>(),
      ));
  
  getIt.registerFactory(() => ObtenerReserva(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => ObtenerReservaPorId(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => VerReserva(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => ObtenerMesasDisponibles(getIt<MesaRepositorio>()));
  
  // Nuevos casos de uso para lista de espera
  getIt.registerFactory(() => AgregarAListaDeEspera(getIt<ListaEsperaRepositorio>()));
  
  getIt.registerFactory(() => ProcesarListaDeEspera(
        getIt<ReservaRepositorio>(),
        getIt<ListaEsperaRepositorio>(),
        getIt<ServicioNotificaciones>(),
      ));
  
  // Cubits
  getIt.registerFactory(() => PantallaDuenoCubit(
        getIt<NegocioRepositorio>(),
        getIt<MesaRepositorio>(),
        getIt<ReservaRepositorio>(),
      ));
  getIt.registerFactory(() => PantallaInicioCubit(getIt<NegocioRepositorio>()));
}
