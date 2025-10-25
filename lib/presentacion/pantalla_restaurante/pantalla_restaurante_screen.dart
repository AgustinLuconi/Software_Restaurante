import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pantalla_restaurante_cubit.dart';
import 'pantalla_restaurante_estados_de_cubit.dart';

class PantallaRestauranteScreen extends StatelessWidget {
  const PantallaRestauranteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantallaRestauranteCubit(),
      child: const _PantallaRestauranteView(),
    );
  }
}

class _PantallaRestauranteView extends StatelessWidget {
  const _PantallaRestauranteView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
          tooltip: 'Volver a restaurantes',
        ),
        title: const Text('Sistema de Reservas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<PantallaRestauranteCubit, PantallaRestauranteState>(
        builder: (context, state) {
          if (state is PantallaRestauranteLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PantallaRestauranteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PantallaRestauranteCubit>().reset();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PantallaRestauranteSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Estado inicial
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nombre del restaurante
                  const Text(
                    'Chiringuito',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Color(0xFF2C3E50),
                      fontFamily: 'serif',
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          color: Color.fromARGB(100, 0, 0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Restaurante de Mar',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF7F8C8D),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Botón Ver disponibilidad
                  SizedBox(
                    width: 250,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/disponibilidad');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ver Disponibilidad',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón Nuestra Historia
                  SizedBox(
                    width: 250,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/historia');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2C3E50),
                        side: const BorderSide(
                          color: Color(0xFF2C3E50),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Nuestra Historia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón Mis Reservas
                  SizedBox(
                    width: 250,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.go('/mis-reservas');
                      },
                      icon: const Icon(Icons.event_note),
                      label: const Text(
                        'Mis Reservas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF27AE60),
                        side: const BorderSide(
                          color: Color(0xFF27AE60),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
