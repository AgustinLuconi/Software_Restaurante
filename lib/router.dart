import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentacion/disponibilidad/disponibilidad_screen.dart';
import 'presentacion/historia/historia_screen.dart';
import 'presentacion/mis_reservas/mis_reservas_screen.dart';
import 'presentacion/pantalla_inicio/pantalla_inicio_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const PantallaInicioScreen(),
    ),
    GoRoute(
      path: '/historia',
      name: 'historia',
      builder: (context, state) => const HistoriaScreen(),
    ),
    GoRoute(
      path: '/disponibilidad',
      name: 'disponibilidad',
      builder: (context, state) => const DisponibilidadScreen(),
    ),
    GoRoute(
      path: '/mis-reservas',
      name: 'mis-reservas',
      builder: (context, state) => const MisReservasScreen(),
    ),
    // Aquí puedes agregar más rutas según necesites
    // GoRoute(
    //   path: '/reservas',
    //   name: 'reservas',
    //   builder: (context, state) => const ReservasScreen(),
    // ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página no encontrada: ${state.matchedLocation}'),
    ),
  ),
);
