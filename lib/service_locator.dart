import 'package:get_it/get_it.dart';

import 'adaptadores/adaptador_en_memoria_mesa.dart';
import 'adaptadores/adaptador_en_memoria_reserva.dart';
import 'aplicacion/cancelar_reserva.dart';
import 'aplicacion/crear_reserva.dart';
import 'aplicacion/obtener_mesas_disponibles.dart';
import 'aplicacion/obtener_reserva.dart';
import 'aplicacion/ver_reserva.dart';
import 'dominio/entidades/mesa.dart';
import 'dominio/repositorios/mesa_repositorio.dart';
import 'dominio/repositorios/reserva_repositorio.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Datos de ejemplo para mesas
  final mesasEjemplo = [
    Mesa(id: '1', nombre: 'Mesa 1', capacidad: 2),
    Mesa(id: '2', nombre: 'Mesa 2', capacidad: 4),
    Mesa(id: '3', nombre: 'Mesa 3', capacidad: 6),
    Mesa(id: '4', nombre: 'Mesa 4', capacidad: 8),
  ];

  // Registrar repositorios como singletons
  getIt.registerLazySingleton<ReservaRepositorio>(
    () => ReservaRepositorioMemoria(),
  );

  getIt.registerLazySingleton<MesaRepositorio>(
    () => MesaRepositorioMemoria(mesasEjemplo),
  );

  // Registrar casos de uso
  getIt.registerFactory(() => CrearReserva(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => CancelarReserva(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => ObtenerReserva(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => ObtenerReservaPorId(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => VerReserva(getIt<ReservaRepositorio>()));
  getIt.registerFactory(() => ObtenerMesasDisponibles(getIt<MesaRepositorio>()));
}
