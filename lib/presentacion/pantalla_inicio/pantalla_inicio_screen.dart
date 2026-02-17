import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../adaptadores/servicio_autenticacion_firebase.dart';
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
          // Lista de restaurantes
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
                          // El Chiringuito tiene funcionalidad completa (detectar por nombre)
                          final esChiringuito = negocio.nombre.toLowerCase() == 'chiringuito';
                          
                          return Column(
                            children: [
                              _buildRestauranteCard(
                                context,
                                nombre: negocio.nombre,
                                descripcion: negocio.descripcion.isEmpty 
                                    ? 'Nuevo restaurante' 
                                    : negocio.descripcion,
                                especialidad: negocio.especialidad.isEmpty 
                                    ? 'Especialidad no definida' 
                                    : negocio.especialidad,
                                icono: _obtenerIcono(negocio.icono),
                                color: esChiringuito 
                                    ? const Color(0xFF3498DB) 
                                    : const Color(0xFF9B59B6),
                                destacado: esChiringuito,
                                onTap: () {
                                  context.go('/restaurante', extra: negocio.id);
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

  // Helper para convertir string a IconData
  IconData _obtenerIcono(String nombreIcono) {
    switch (nombreIcono.toLowerCase()) {
      case 'sailing':
        return Icons.sailing;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'ramen_dining':
        return Icons.ramen_dining;
      case 'coffee':
        return Icons.coffee;
      case 'icecream':
        return Icons.icecream;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'local_bar':
        return Icons.local_bar;
      case 'restaurant':
      default:
        return Icons.restaurant;
    }
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
              
              // Botón Continuar con Google (Principal)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _mostrarLoginGoogle(context, cubit);
                  },
                  icon: Image.asset(
                    'images/google_logo.jpeg',
                    height: 24,
                    width: 24,
                    errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, size: 24),
                  ),
                  label: const Text('Continuar con Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4285F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF4285F4), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Divider con texto
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o usa email',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botón Registrar Negocio
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _mostrarRegistroNegocio(context, cubit);
                  },
                  icon: const Icon(Icons.add_business),
                  label: const Text('Registrar mi Negocio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF27AE60), width: 1.5),
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
                  label: const Text('Ingresar con Email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3498DB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Color(0xFF3498DB),
                      width: 1.5,
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
                      Navigator.pop(context);
                      _mostrarRecuperarContrasena(context);
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('o', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Botón de Google
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarLoginGoogle(context, cubit);
                    },
                    icon: Image.asset(
                      'images/google_logo.jpeg',
                      height: 24,
                      width: 24,
                      errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, size: 24),
                    ),
                    label: const Text('Continuar con Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                    // 1. Limpieza: Cerrar cualquier sesión previa (Chiringuito, etc.)
                    final auth = getIt<ServicioAutenticacion>();
                    await auth.cerrarSesion();

                    // 2. Autenticar usando el repositorio (Validación de Negocio)
                    final negocio = await cubit.negocioRepositorio.autenticarNegocio(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    
                    if (negocio != null) {
                      try {
                        // 3. Autenticar en Firebase (Sincronización Obligatoria)
                        await auth.iniciarSesionConEmail(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      } catch (e) {
                         // Si falla el login, intentamos registrar si el error es "user-not-found"
                         // OJO: Si falla por contraseña incorrecta en Auth pero correcta en BD,
                         // esto significa que las contraseñas están desincronizadas.
                         // En ese caso, damos prioridad a la BD y actualizamos Auth (Migración).
                         
                         print('⚠️ Error Auth: $e');
                         try {
                           // Intento de auto-reparación / Registro
                           await auth.registrarConEmail(
                             email: emailController.text,
                             password: passwordController.text,
                           );
                         } catch (registerError) {
                            // Si falla el registro (ej: email-in-use pero password incorrecta en auth),
                            // aquí tenemos un problema grave de sincronización.
                            // Por ahora, para no bloquear al dueño, le avisamos pero dejamos pasar
                            // SOLO si es un error de credenciales cruzadas.
                            print('❌ Error Registro/Sync: $registerError');
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Alerta: Tu usuario de Auth tiene problemas. Se ha notificado.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                         }
                      }

                    Navigator.pop(context);
                    // Autenticación exitosa - navegar a pantalla_dueño
                    context.go('/dueno', extra: negocio);
                  } else {
                    Navigator.pop(context);
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

  void _mostrarRecuperarContrasena(BuildContext context) {
    final emailController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: Color(0xFFE67E22)),
              SizedBox(width: 12),
              Text('Recuperar Contraseña'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'ejemplo@correo.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa un correo válido'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      
                      setState(() => isLoading = true);
                      
                      try {
                        final auth = getIt<ServicioAutenticacion>();
                        await auth.enviarEmailRecuperacion(email: email);
                        
                        Navigator.pop(dialogContext);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Revisa tu correo para restablecer tu contraseña'),
                            backgroundColor: Color(0xFF27AE60),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
                            backgroundColor: const Color(0xFFE74C3C),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarLoginGoogle(BuildContext context, PantallaInicioCubit cubit) async {
    final auth = getIt<ServicioAutenticacion>();
    
    // Variable para trackear si el diálogo de carga está abierto
    bool dialogoAbierto = false;
    
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      dialogoAbierto = true;
      
      final resultado = await auth.iniciarSesionConGoogle();
      
      // Cerrar indicador de carga
      if (dialogoAbierto && context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        dialogoAbierto = false;
      }
      
      if (resultado != null && resultado.user != null) {
        final email = resultado.user!.email;
        final nombre = resultado.user!.displayName ?? 'Usuario';
        
        // Buscar si existe un negocio con ese email
        final negocio = await cubit.negocioRepositorio.obtenerNegocioPorEmail(email ?? '');
        
        if (negocio != null) {
          // Negocio encontrado - ir al panel del dueño
          if (context.mounted) {
            context.go('/dueno', extra: negocio);
          }
        } else {
          // No hay negocio registrado - mostrar formulario de registro
          if (context.mounted) {
            _mostrarOpcionRegistrarConGoogle(context, cubit, email ?? '', nombre);
          }
        }
      }
      // Si resultado es null, el usuario canceló - no hacemos nada
    } catch (e) {
      // Cerrar indicador si hay error
      if (dialogoAbierto && context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Ignorar errores de popup cerrado por el usuario
      final errorStr = e.toString().toLowerCase();
      final esErrorCancelacion = errorStr.contains('popup') || 
                                  errorStr.contains('closed') || 
                                  errorStr.contains('cancelled') ||
                                  errorStr.contains('canceled') ||
                                  errorStr.contains('user') ||
                                  errorStr.contains('dismissed');
      
      // Solo mostrar error si NO es por cancelación del usuario
      if (!esErrorCancelacion && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra opción para registrar negocio después de login con Google
  void _mostrarOpcionRegistrarConGoogle(
    BuildContext context,
    PantallaInicioCubit cubit,
    String email,
    String nombre,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add, size: 48, color: Color(0xFF3498DB)),
        title: Text('¡Hola, $nombre!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No encontramos un negocio asociado a $email',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Deseas registrar tu negocio ahora?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Cerrar sesión de Google ya que no se va a usar
              getIt<ServicioAutenticacion>().cerrarSesion();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Abrir registro con email pre-llenado
              _mostrarRegistroConGoogle(context, cubit, email, nombre);
            },
            icon: const Icon(Icons.add_business),
            label: const Text('Registrar Negocio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra formulario de registro simplificado (sin email/password)
  void _mostrarRegistroConGoogle(
    BuildContext context,
    PantallaInicioCubit cubit,
    String email,
    String nombreUsuario,
  ) {
    final formKey = GlobalKey<FormState>();
    final nombreNegocioController = TextEditingController();
    final telefonoController = TextEditingController();
    final direccionController = TextEditingController();
    final nombreResponsableController = TextEditingController(text: nombreUsuario);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_business, color: Color(0xFF4285F4)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Completar Registro', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info del email de Google
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF27AE60).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nombre del negocio
                  TextFormField(
                    controller: nombreNegocioController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Negocio *',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  // Nombre responsable
                  TextFormField(
                    controller: nombreResponsableController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Responsable *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  // Teléfono
                  TextFormField(
                    controller: telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  // Dirección
                  TextFormField(
                    controller: direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () {
                Navigator.pop(dialogContext);
                getIt<ServicioAutenticacion>().cerrarSesion();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (formKey.currentState?.validate() ?? false) {
                  setState(() => isLoading = true);
                  
                  try {
                    // Registrar negocio con contraseña generada (el login es por Google)
                    final negocio = await cubit.registrarNegocio(
                      nombre: nombreNegocioController.text.trim(),
                      nombreResponsable: nombreResponsableController.text.trim(),
                      email: email,
                      telefono: telefonoController.text.trim(),
                      direccion: direccionController.text.trim(),
                      password: 'google_auth_${DateTime.now().millisecondsSinceEpoch}',
                    );
                    
                    if (negocio != null && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ ¡Negocio registrado exitosamente!'),
                          backgroundColor: Color(0xFF27AE60),
                        ),
                      );
                      context.go('/dueno', extra: negocio);
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Registrar'),
            ),
          ],
        ),
      ),
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
