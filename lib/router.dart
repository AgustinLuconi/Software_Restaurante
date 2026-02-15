import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dominio/entidades/negocio.dart';
import 'presentacion/disponibilidad/disponibilidad_screen.dart';
import 'presentacion/historia/historia_screen.dart';
import 'presentacion/mis_reservas/mis_reservas_screen.dart';
import 'presentacion/pantalla_dueno/pantalla_dueno_cubit.dart';
import 'presentacion/pantalla_dueno/pantalla_dueno_screen.dart';
import 'presentacion/pantalla_inicio/pantalla_inicio_cubit.dart';
import 'presentacion/pantalla_inicio/pantalla_inicio_screen.dart';
import 'presentacion/pantalla_restaurante/pantalla_restaurante_screen.dart';
import 'service_locator.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => getIt<PantallaInicioCubit>(),
          child: const PantallaInicioScreen(),
        );
      },
    ),
    GoRoute(
      path: '/restaurante',
      name: 'restaurante',
      builder: (context, state) {
        final negocioId = state.extra as String?;
        return PantallaRestauranteScreen(negocioId: negocioId);
      },
    ),
    GoRoute(
      path: '/historia',
      name: 'historia',
      builder: (context, state) {
        final negocioId = state.extra as String?;
        return HistoriaScreen(negocioId: negocioId);
      },
    ),
    GoRoute(
      path: '/disponibilidad',
      name: 'disponibilidad',
      builder: (context, state) {
        final negocioId = state.extra as String?;
        return DisponibilidadScreen(negocioId: negocioId);
      },
    ),
    GoRoute(
      path: '/mis-reservas',
      name: 'mis-reservas',
      builder: (context, state) => const MisReservasScreen(),
    ),
    GoRoute(
      path: '/dueno',
      name: 'dueno',
      builder: (context, state) {
        final negocio = state.extra as Negocio?;
        return BlocProvider(
          create: (context) {
            final cubit = getIt<PantallaDuenoCubit>();
            // Si tenemos un negocio autenticado, establecerlo en el cubit
            if (negocio != null) {
              cubit.establecerNegocioAutenticado(negocio);
            }
            return cubit;
          },
          child: const PantallaDuenoScreen(),
        );
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Text('Página no encontrada: ${state.matchedLocation}'),
        ),
      ),
);
