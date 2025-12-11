import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../service_locator.dart';
import '../widgets_comunes/registro_negocio_stepper.dart';
import 'pantalla_inicio_cubit.dart';
import 'pantalla_inicio_estados_de_cubit.dart';

class PantallaInicioScreen extends StatelessWidget {
  const PantallaInicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PantallaInicioCubit>(),
      child: const _PantallaInicioView(),
    );
  }
}

class _PantallaInicioView extends StatelessWidget {
  const _PantallaInicioView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sistema de Reservas',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          // Botón de login para negocios
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                _mostrarOpcionesNegocio(context);
              },
              icon: Icon(Icons.business, size: 18, color: colorScheme.primary),
              label: Text(
                '¿Tienes un negocio?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PantallaInicioCubit, PantallaInicioState>(
        builder: (context, state) {
          if (state is PantallaInicioCargando) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PantallaInicioConError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.mensaje,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PantallaInicioCubit>().reiniciar();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PantallaInicioExitoso) {
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
                    state.mensaje,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Estado inicial - Lista de restaurantes
          return Column(
              children: [
                // Header mejorado
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      // Logo circular
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Restaurantes Disponibles',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona tu restaurante favorito',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                
                // Lista de restaurantes
                Expanded(
                  child: ListView(
                      padding: const EdgeInsets.all(20.0),
                      children: [
                        const SizedBox(height: 10),
                        // Negocios registrados por usuarios (incluyendo Chiringuito)
                        ...state.negocios.map((negocio) {
                          // El Chiringuito tiene funcionalidad completa
                          final esChiringuito = negocio.id == 'negocio_1';
                          
                          return Column(
                            children: [
                              _buildRestauranteCard(
                                context,
                                nombre: negocio.nombre,
                                descripcion: negocio.descripcion.isEmpty 
                                    ? 'Nuevo restaurante' 
                                    : negocio.descripcion,
                                especialidad: negocio.especialidad.isEmpty 
                                    ? negocio.direccion 
                                    : negocio.especialidad,
                                icono: esChiringuito ? Icons.sailing : Icons.restaurant,
                                color: esChiringuito 
                                    ? const Color(0xFF3498DB) 
                                    : const Color(0xFF9B59B6),
                                destacado: esChiringuito,
                                onTap: () {
                                  if (esChiringuito) {
                                    context.go('/restaurante');
                                  } else {
                                    _mostrarProximamente(context);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                        
                        // Restaurantes de relleno visual
                        _buildRestauranteCard(
                          context,
                          nombre: 'La Parrilla',
                          descripcion: 'Asador Argentino',
                          especialidad: 'Carnes a la parrilla y vinos selectos',
                          icono: Icons.local_fire_department,
                          color: const Color(0xFFE74C3C),
                          destacado: false,
                          onTap: () {
                            _mostrarProximamente(context);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildRestauranteCard(
                          context,
                          nombre: 'Trattoria Bella',
                          descripcion: 'Cocina Italiana',
                          especialidad: 'Pastas caseras y pizzas al horno de leña',
                          icono: Icons.local_pizza,
                          color: const Color(0xFF27AE60),
                          destacado: false,
                          onTap: () {
                            _mostrarProximamente(context);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildRestauranteCard(
                          context,
                          nombre: 'Sushi Zen',
                          descripcion: 'Restaurante Japonés',
                          especialidad: 'Sushi, sashimi y cocina oriental',
                          icono: Icons.set_meal,
                          color: const Color(0xFFE67E22),
                          destacado: false,
                          onTap: () {
                            _mostrarProximamente(context);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        _buildRestauranteCard(
                          context,
                          nombre: 'El Jardín Verde',
                          descripcion: 'Restaurante Vegano',
                          especialidad: 'Comida saludable y orgánica',
                          icono: Icons.eco,
                          color: const Color(0xFF16A085),
                          destacado: false,
                          onTap: () {
                            _mostrarProximamente(context);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                ),
              ],
            );
        },
      ),
    );
  }

  void _mostrarProximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 Restaurante próximamente disponible'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarOpcionesNegocio(BuildContext context) {
    // Capturar el cubit ANTES de abrir cualquier diálogo
    final cubit = context.read<PantallaInicioCubit>();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.business, color: Theme.of(dialogContext).primaryColor),
              const SizedBox(width: 12),
              const Text('Área de Negocios'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué deseas hacer?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Botón Registrar Negocio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _mostrarRegistroNegocio(context, cubit);
                  },
                  icon: const Icon(Icons.add_business),
                  label: const Text('Registrar mi Negocio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Botón Ingresar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _mostrarLoginNegocio(context, cubit);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Ingresar a mi Negocio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3498DB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: Color(0xFF3498DB),
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarRegistroNegocio(BuildContext context, PantallaInicioCubit cubit) {
    // Usar el nuevo widget con Stepper
    mostrarRegistroNegocioStepper(context, cubit);
  }

  void _mostrarLoginNegocio(BuildContext context, PantallaInicioCubit cubit) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.login, color: Color(0xFF3498DB)),
              SizedBox(width: 12),
              Text('Ingresar a mi Negocio'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su correo';
                    }
                    if (!value.contains('@')) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de recuperación próximamente disponible'),
                        ),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Autenticar usando el repositorio capturado
                  final negocio = await cubit.negocioRepositorio.autenticarNegocio(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  
                  Navigator.pop(context);
                  
                  if (negocio != null) {
                    // Autenticación exitosa - navegar a pantalla_dueño
                    context.go('/dueno', extra: negocio);
                  } else {
                    // Credenciales incorrectas
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Email o contraseña incorrectos'),
                        backgroundColor: Color(0xFFE74C3C),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
              ),
              child: const Text('Ingresar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestauranteCard(
    BuildContext context, {
    required String nombre,
    required String descripcion,
    required String especialidad,
    required IconData icono,
    required Color color,
    required bool destacado,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: destacado ? 12 : 6,
      shadowColor: destacado ? color.withOpacity(0.5) : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: destacado
            ? BorderSide(color: color.withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: destacado
                  ? [
                      Colors.white,
                      color.withOpacity(0.08),
                    ]
                  : [
                      Colors.white,
                      color.withOpacity(0.03),
                    ],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Icono del restaurante
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.8),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icono,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Información del restaurante
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            if (destacado)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color, color.withOpacity(0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Destacado',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          descripcion,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Flecha indicadora
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Especialidad en la parte inferior
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        especialidad,
                        style: TextStyle(
                          fontSize: 14,
                          color: color.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
