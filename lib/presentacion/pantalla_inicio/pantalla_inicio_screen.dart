import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/entidades/negocio.dart';
import '../../service_locator.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Reservas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón de login para negocios
          TextButton.icon(
            onPressed: () {
              _mostrarOpcionesNegocio(context);
            },
            icon: const Icon(Icons.business, color: Colors.white),
            label: const Text(
              '¿Tienes un negocio?',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<PantallaInicioCubit, PantallaInicioState>(
        builder: (context, state) {
          if (state is PantallaInicioLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PantallaInicioError) {
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
                      context.read<PantallaInicioCubit>().reset();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PantallaInicioSuccess) {
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

          // Estado inicial - Lista de restaurantes
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3498DB),
                      const Color(0xFF2980B9),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Restaurantes Disponibles',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecciona un restaurante para hacer tu reserva',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Lista de restaurantes
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
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
                      onTap: () {
                        _mostrarProximamente(context);
                      },
                    ),
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
    final formKey = GlobalKey<FormState>();
    final nombreNegocioController = TextEditingController();
    final nombreContactoController = TextEditingController();
    final emailController = TextEditingController();
    final telefonoController = TextEditingController();
    final direccionController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_business, color: Color(0xFF27AE60)),
              SizedBox(width: 12),
              Text('Registrar Negocio'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreNegocioController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Negocio *',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: nombreContactoController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Responsable *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico *',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (!value.contains('@')) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña *',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Contraseña *',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (value != passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                  // Registrar el negocio usando el cubit capturado
                  final nuevoNegocio = await cubit.registrarNegocio(
                    nombre: nombreNegocioController.text,
                    nombreResponsable: nombreContactoController.text,
                    email: emailController.text,
                    telefono: telefonoController.text,
                    direccion: direccionController.text,
                    password: passwordController.text,
                  );
                  
                  Navigator.pop(context);
                  
                  if (nuevoNegocio != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ¡${nuevoNegocio.nombre} registrado exitosamente!'),
                        backgroundColor: const Color(0xFF27AE60),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ El email ya está registrado'),
                        backgroundColor: Color(0xFFE74C3C),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
              ),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
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
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              // Icono del restaurante
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icono,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              
              // Información del restaurante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            especialidad,
                            style: TextStyle(
                              fontSize: 14,
                              color: color.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Flecha indicadora
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
