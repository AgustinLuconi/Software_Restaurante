
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../adaptadores/servicio_autenticacion_firebase.dart';
import '../../dominio/entidades/historia_restaurante.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/negocio.dart';
import '../../dominio/entidades/reserva.dart';
import '../../service_locator.dart';
import '../widgets_comunes/tarjeta_accion_gradiente.dart';
import '../widgets_comunes/tarjeta_info.dart';
import 'pantalla_dueno_cubit.dart';
import 'pantalla_dueno_estados_de_cubit.dart';

class PantallaDuenoScreen extends StatelessWidget {
  const PantallaDuenoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // No crear un nuevo BlocProvider aquí, usar el que viene del router
    return const _PantallaDuenoView();
  }
}

class _PantallaDuenoView extends StatelessWidget {
  const _PantallaDuenoView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantallaDuenoCubit, PantallaDuenoState>(
      listener: (context, state) {
        if (state is PantallaDuenoConError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is PantallaDuenoAutenticado) {
          return _buildPanelDueno(context, state.negocio);
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/');
              },
            ),
            title: const Text('Acceso Restringido'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  const Text(
                    'Área exclusiva para dueños',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Debe autenticarse desde la pantalla de inicio\ncon las credenciales de su negocio',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al inicio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelDueno(BuildContext context, negocio) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _mostrarConfirmacionCerrarSesion(context);
          },
          tooltip: 'Cerrar sesión',
        ),
        title: Text('Panel de ${negocio.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _mostrarConfirmacionCerrarSesion(context);
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con bienvenida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _obtenerIcono(negocio.icono),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¡Bienvenido!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            negocio.nombre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Color(0xFF7F8C8D),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  negocio.nombreResponsable,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Título de acciones rápidas
            Text(
              'Acciones Rápidas',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Lista horizontal de opciones principales
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: [
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.event_note,
                      title: 'Reservas',
                      subtitle: 'Gestionar',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      ),
                      onTap: () => _mostrarReservas(context, negocio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.table_bar,
                      title: 'Mesas',
                      subtitle: 'Configurar',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF229954)],
                      ),
                      onTap: () => _mostrarGestionMesas(context, negocio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.schedule,
                      title: 'Horarios',
                      subtitle: 'Definir',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                      ),
                      onTap: () => _mostrarGestionHorarios(context, negocio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.map,
                      title: 'Zonas',
                      subtitle: 'Sectores',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                      ),
                      onTap: () => _mostrarGestionZonas(context, negocio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.bar_chart,
                      title: 'Métricas',
                      subtitle: 'Análisis',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                      ),
                      onTap: () => _mostrarMetricas(context, negocio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.settings_suggest,
                      title: 'Reglas',
                      subtitle: 'Tiempos',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F8C8D), Color(0xFF2C3E50)],
                      ),
                      onTap: () => _mostrarConfiguracionReglas(context, negocio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TarjetaAccionGradiente(
                      icon: Icons.history_edu,
                      title: 'Historia',
                      subtitle: 'Editar Contenido',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
                      ),
                      onTap: () => _mostrarEditorHistoria(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información del negocio
            Text(
              'Información del Negocio',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TarjetaInfo(
              icon: Icons.store,
              titulo: 'Nombre del Restaurante',
              subtitulo: negocio.nombre,
              color: const Color(0xFF2980B9),
              onTap: () => _mostrarEditarNombre(context, negocio),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: () => _mostrarEditarNombre(context, negocio),
                tooltip: 'Editar',
              ),
            ),
            const SizedBox(height: 12),

            TarjetaInfo(
              icon: _obtenerIcono(negocio.icono),
              titulo: 'Icono/Logo',
              subtitulo: _obtenerLabelIcono(negocio.icono),
              color: const Color(0xFF27AE60),
              onTap: () => _mostrarEditarIcono(context, negocio),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: () => _mostrarEditarIcono(context, negocio),
                tooltip: 'Editar',
              ),
            ),
            const SizedBox(height: 12),

            TarjetaInfo(
              icon: Icons.email,
              titulo: 'Correo Electrónico',
              subtitulo: negocio.email,
              color: colorScheme.primary,
              onTap: () => _mostrarEditarEmail(context, negocio),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: () => _mostrarEditarEmail(context, negocio),
                tooltip: 'Editar',
              ),
            ),
            const SizedBox(height: 12),

            TarjetaInfo(
              icon: Icons.phone,
              titulo: 'Teléfono',
              subtitulo: negocio.telefono,
              color: const Color(0xFF27AE60), // Usar constante si es posible, o variable local
              onTap: () => _mostrarEditarTelefono(context, negocio),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (negocio.telefonoVerificado)
                    const BadgeVerificado(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                    onPressed: () => _mostrarEditarTelefono(context, negocio),
                    tooltip: 'Editar',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            TarjetaInfo(
              icon: Icons.location_on,
              titulo: 'Dirección',
              subtitulo: negocio.direccion,
              color: colorScheme.tertiary,
              onTap: () => _mostrarEditarDireccion(context, negocio),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: () => _mostrarEditarDireccion(context, negocio),
                tooltip: 'Editar',
              ),
            ),
            const SizedBox(height: 12),

            TarjetaInfo(
              icon: Icons.restaurant_menu,
              titulo: 'Especialidad',
              subtitulo: negocio.especialidad,
              color: const Color(0xFF9B59B6),
              onTap: () => _mostrarEditarEspecialidad(context, negocio),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: () => _mostrarEditarEspecialidad(context, negocio),
                tooltip: 'Editar',
              ),
            ),
            const SizedBox(height: 12),

            TarjetaInfo(
              icon: Icons.description,
              titulo: 'Descripción',
              subtitulo: negocio.descripcion.isEmpty 
                  ? 'Sin descripción' 
                  : negocio.descripcion,
              color: const Color(0xFF16A085),
              onTap: () => _mostrarEditarDescripcion(context, negocio),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: () => _mostrarEditarDescripcion(context, negocio),
                tooltip: 'Editar',
              ),
            ),

            const SizedBox(height: 24),

            // Sección de seguridad de la cuenta
            Text(
              'Seguridad de la Cuenta',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Botón de cambiar contraseña
            TarjetaInfo(
              icon: Icons.lock_outline,
              titulo: 'Cambiar Contraseña',
              subtitulo: 'Actualiza tu contraseña de acceso',
              color: const Color(0xFF3498DB),
              onTap: () => _mostrarCambiarContrasena(context),
            ),

            const SizedBox(height: 12),

            // Botón de verificación de teléfono (separado de la info principal)
            TarjetaInfoConEstado(
              icon: Icons.verified_user_outlined,
              titulo: 'Verificar Teléfono',
              subtitulo: negocio.telefonoVerificado 
                  ? 'Tu número está verificado' 
                  : 'Verifica tu número para mayor seguridad',
              color: negocio.telefonoVerificado 
                  ? const Color(0xFF27AE60) 
                  : const Color(0xFFE67E22),
              estaVerificado: negocio.telefonoVerificado,
              onTap: () => _mostrarVerificacionTelefono(context, negocio),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  void _mostrarConfirmacionCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFE74C3C)),
              SizedBox(width: 12),
              Text('Cerrar Sesión'),
            ],
          ),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<PantallaDuenoCubit>().cerrarSesion();
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarEditarTelefono(BuildContext context, negocio) {
    final controller = TextEditingController(text: negocio.telefono);
    String? errorMessage;
    // Capturar cubit con el contexto válido antes del diálogo
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) { // Este context sombrea al externo
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFF27AE60)),
                  SizedBox(width: 12),
                  Text('Editar Teléfono'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Número de Teléfono',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      hintText: 'Ej: +54 9 261 123-4567',
                      errorText: errorMessage,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuevoTelefono = controller.text.trim();
                    if (nuevoTelefono.isEmpty) {
                      setState(() => errorMessage = 'El teléfono no puede estar vacío');
                      return;
                    }

                    // Validar formato de teléfono argentino
                    final auth = getIt<ServicioAutenticacion>();
                    final validacion = auth.validarTelefonoArgentino(nuevoTelefono);
                    if (validacion['valido'] != true) {
                      setState(() => errorMessage = validacion['error'] as String?);
                      return;
                    }

                    // Usar el cubit capturado
                    final exito = await cubit.actualizarTelefono(
                      negocio,
                      nuevoTelefono,
                    );

                    Navigator.pop(dialogContext);

                    if (exito) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Teléfono actualizado correctamente'),
                          backgroundColor: Color(0xFF27AE60),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Error al actualizar teléfono'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarEditarEspecialidad(BuildContext context, negocio) {
    final controller = TextEditingController(text: negocio.especialidad);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.restaurant_menu, color: Color(0xFF9B59B6)),
              SizedBox(width: 12),
              Text('Editar Especialidad'),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Especialidad',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.restaurant_menu),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaEspecialidad = controller.text.trim();
                if (nuevaEspecialidad.isNotEmpty) {
                  final cubit = context.read<PantallaDuenoCubit>();
                  final exito = await cubit.actualizarEspecialidad(
                    negocio,
                    nuevaEspecialidad,
                  );

                  Navigator.pop(dialogContext);

                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✅ Especialidad actualizada correctamente',
                        ),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Error al actualizar especialidad'),
                        backgroundColor: Color(0xFFE74C3C),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
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

  // Helper para obtener label legible del ícono
  String _obtenerLabelIcono(String nombreIcono) {
    switch (nombreIcono.toLowerCase()) {
      case 'sailing':
        return 'Playa';
      case 'local_fire_department':
        return 'Parrilla';
      case 'local_pizza':
        return 'Pizzería';
      case 'ramen_dining':
        return 'Asiático';
      case 'coffee':
        return 'Cafetería';
      case 'icecream':
        return 'Heladería';
      case 'bakery_dining':
        return 'Panadería';
      case 'local_bar':
        return 'Bar';
      case 'restaurant':
        return 'Restaurante';
      default:
        return 'Restaurante';
    }
  }

  void _mostrarEditarNombre(BuildContext context, negocio) {
    final controller = TextEditingController(text: negocio.nombre);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.store, color: Color(0xFF2980B9)),
              SizedBox(width: 12),
              Text('Editar Nombre'),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del restaurante',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final cubit = context.read<PantallaDuenoCubit>();
                final exito = await cubit.actualizarNombre(
                  negocio,
                  controller.text.trim(),
                );
                Navigator.pop(dialogContext);
                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Nombre actualizado'),
                      backgroundColor: Color(0xFF27AE60),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Error al actualizar nombre'),
                      backgroundColor: Color(0xFFE74C3C),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2980B9),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarEditarIcono(BuildContext context, negocio) {
    final iconos = [
      {'nombre': 'restaurant', 'icono': Icons.restaurant, 'label': 'Restaurante'},
      {'nombre': 'sailing', 'icono': Icons.sailing, 'label': 'Playa'},
      {'nombre': 'local_fire_department', 'icono': Icons.local_fire_department, 'label': 'Parrilla'},
      {'nombre': 'local_pizza', 'icono': Icons.local_pizza, 'label': 'Pizzería'},
      {'nombre': 'ramen_dining', 'icono': Icons.ramen_dining, 'label': 'Asiático'},
      {'nombre': 'coffee', 'icono': Icons.coffee, 'label': 'Cafetería'},
      {'nombre': 'icecream', 'icono': Icons.icecream, 'label': 'Heladería'},
      {'nombre': 'bakery_dining', 'icono': Icons.bakery_dining, 'label': 'Panadería'},
      {'nombre': 'local_bar', 'icono': Icons.local_bar, 'label': 'Bar'},
    ];

    String iconoSeleccionado = negocio.icono;
    // Capturar cubit con el contexto válido
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.image, color: Color(0xFF27AE60)),
                  SizedBox(width: 12),
                  Text('Seleccionar Icono'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400, // Altura fija para la lista
                child: ListView.separated(
                  itemCount: iconos.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = iconos[index];
                    final esSeleccionado = item['nombre'] == iconoSeleccionado;
                    return ListTile(
                      onTap: () {
                        setState(() {
                          iconoSeleccionado = item['nombre'] as String;
                        });
                      },
                      leading: Icon(
                        item['icono'] as IconData,
                        size: 32,
                        color: esSeleccionado 
                            ? const Color(0xFF27AE60)
                            : Colors.grey[600],
                      ),
                      title: Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: esSeleccionado 
                              ? const Color(0xFF27AE60)
                              : Colors.black87,
                          fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: esSeleccionado
                          ? const Icon(Icons.check_circle, color: Color(0xFF27AE60))
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: esSeleccionado 
                              ? const Color(0xFF27AE60).withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      tileColor: esSeleccionado 
                          ? const Color(0xFF27AE60).withOpacity(0.1)
                          : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Usar cubit capturado
                    final exito = await cubit.actualizarIcono(
                      negocio,
                      iconoSeleccionado,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(dialogContext);
                    if (exito) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Icono actualizado'),
                          backgroundColor: Color(0xFF27AE60),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Error al actualizar icono'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarEditarDescripcion(BuildContext context, negocio) {
    final controller = TextEditingController(text: negocio.descripcion);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.description, color: Color(0xFF16A085)),
              SizedBox(width: 12),
              Text('Editar Descripción'),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Descripción del restaurante',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              hintText: 'Describe tu restaurante...',
            ),
            maxLines: 4,
            maxLength: 300,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaDescripcion = controller.text.trim();
                final cubit = context.read<PantallaDuenoCubit>();
                final exito = await cubit.actualizarDescripcion(
                  negocio,
                  nuevaDescripcion,
                );

                Navigator.pop(dialogContext);

                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✅ Descripción actualizada correctamente',
                      ),
                      backgroundColor: Color(0xFF27AE60),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Error al actualizar descripción'),
                      backgroundColor: Color(0xFFE74C3C),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A085),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarEditarEmail(BuildContext context, negocio) {
    final auth = getIt<ServicioAutenticacion>();
    final nuevoEmailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    // Verificar si es login con Google
    final esGoogle = auth.esLoginGoogle;
    // Capturar cubit con el contexto válido
    final cubit = context.read<PantallaDuenoCubit>();

    bool obscureText = true;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.email, color: Color(0xFF3498DB)),
                  SizedBox(width: 12),
                  Text('Cambiar Email'),
                ],
              ),
              content:
                  esGoogle
                      ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No puedes cambiar el email porque iniciaste sesión con Google.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Email actual: ${negocio.email}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nuevoEmailController,
                            decoration: const InputDecoration(
                              labelText: 'Nuevo Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña actual',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                              ),
                              helperText: 'Requerida por seguridad',
                            ),
                            obscureText: obscureText,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Se enviará un email de verificación al nuevo correo.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                if (!esGoogle)
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              final nuevoEmail =
                                  nuevoEmailController.text.trim();
                              final password = passwordController.text;

                              if (nuevoEmail.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Completa todos los campos'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                                setState(() => isLoading = true);

                                try {
                                  // 1. Verificar contraseña contra BD (Seguridad Real)
                                  final authBD = await cubit.negocioRepositorio
                                      .autenticarNegocio(
                                    email: negocio.email,
                                    password: password,
                                  );

                                  if (authBD == null) {
                                    throw Exception('Contraseña incorrecta (Verificación BD)');
                                  }

                                  // 2. Intentar actualizar en Firebase Auth si coincide
                                  final user = FirebaseAuth.instance.currentUser;
                                  bool authActualizado = false;

                                  if (user != null &&
                                      user.email == negocio.email) {
                                    try {
                                      await auth.cambiarEmail(
                                        nuevoEmail: nuevoEmail,
                                        passwordActual: password,
                                      );
                                      authActualizado = true;
                                    } catch (e) {
                                      // Si falla Auth pero BD estaba ok, decidimos si continuar
                                      // En este caso, si falla por credenciales, ya validamos BD arriba.
                                      // Si falla por "email-already-in-use", eso es bloqueante.
                                      print('⚠️ Error Auth: $e');
                                      rethrow; 
                                    }
                                  } else {
                                    print(
                                        '⚠️ Mismatch: Auth(${user?.email}) != BD(${negocio.email}). Saltando Auth update.');
                                  }

                                  // 3. Actualizar en Firestore
                                  final exito = await cubit.negocioRepositorio
                                      .actualizarEmail(
                                    negocio.id,
                                    nuevoEmail,
                                  );

                                  if (!context.mounted) return;

                                  if (exito) {
                                      // Actualizar estado local
                                      final negocioActualizado = negocio.copyWith(email: nuevoEmail);
                                      cubit.establecerNegocioAutenticado(negocioActualizado);
                                  }

                                  Navigator.pop(dialogContext);

                                  if (exito) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '✅ Email actualizado ${authActualizado ? "(Completo)" : "(Solo BD - Login Legacy)"}'),
                                        backgroundColor: const Color(0xFF27AE60),
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  } else {
                                    throw Exception(
                                        'Error al actualizar en base de datos');
                                  }
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '❌ Error: ${e.toString().replaceAll("Exception: ", "")}'),
                                        backgroundColor: const Color(0xFFE74C3C),
                                      ),
                                    );
                                  }
                                }
                              },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Cambiar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarEditarDireccion(BuildContext context, negocio) {
    final controller = TextEditingController(text: negocio.direccion);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFE67E22)),
              SizedBox(width: 12),
              Text('Editar Dirección'),
            ],
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaDireccion = controller.text.trim();
                if (nuevaDireccion.isNotEmpty) {
                  final cubit = context.read<PantallaDuenoCubit>();
                  final negocioActualizado = negocio.copyWith(
                    direccion: nuevaDireccion,
                  );
                  final exito = await cubit.negocioRepositorio
                      .actualizarNegocio(negocioActualizado);

                  if (exito) {
                    cubit.establecerNegocioAutenticado(negocioActualizado);
                  }

                  Navigator.pop(dialogContext);

                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Dirección actualizada correctamente'),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Error al actualizar dirección'),
                        backgroundColor: Color(0xFFE74C3C),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarCambiarContrasena(BuildContext context) {
    // Capturar cubit del contexto padre antes de abrir el diálogo
    final cubit = context.read<PantallaDuenoCubit>();
    final auth = getIt<ServicioAutenticacion>();
    final passwordActualController = TextEditingController();
    final passwordNuevaController = TextEditingController();
    final passwordConfirmarController = TextEditingController();
    bool isLoading = false;
    bool obscureActual = true;
    bool obscureNueva = true;
    bool obscureConfirmar = true;

    // Verificar si es login con Google
    final esGoogle = auth.esLoginGoogle;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.lock_outline, color: Color(0xFF3498DB)),
                  SizedBox(width: 12),
                  Text('Cambiar Contraseña'),
                ],
              ),
              content:
                  esGoogle
                      ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No puedes cambiar la contraseña porque iniciaste sesión con Google.\n\nTu cuenta está protegida por tu cuenta de Google.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: passwordActualController,
                              decoration: InputDecoration(
                                labelText: 'Contraseña actual',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureActual
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => obscureActual = !obscureActual,
                                    );
                                  },
                                ),
                              ),
                              obscureText: obscureActual,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordNuevaController,
                              decoration: InputDecoration(
                                labelText: 'Nueva contraseña',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureNueva
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => obscureNueva = !obscureNueva,
                                    );
                                  },
                                ),
                                helperText: 'Mínimo 6 caracteres',
                              ),
                              obscureText: obscureNueva,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordConfirmarController,
                              decoration: InputDecoration(
                                labelText: 'Confirmar nueva contraseña',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirmar
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          obscureConfirmar = !obscureConfirmar,
                                    );
                                  },
                                ),
                              ),
                              obscureText: obscureConfirmar,
                            ),
                          ],
                        ),
                      ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              final passwordActual =
                                  passwordActualController.text;
                              final passwordNueva =
                                  passwordNuevaController.text;
                              final passwordConfirmar =
                                  passwordConfirmarController.text;

                              // Validaciones
                              if (passwordActual.isEmpty ||
                                  passwordNueva.isEmpty ||
                                  passwordConfirmar.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Completa todos los campos'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              if (passwordNueva.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'La nueva contraseña debe tener al menos 6 caracteres',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              if (passwordNueva != passwordConfirmar) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Las contraseñas no coinciden',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                // 1. Verificar contraseña actual contra BD (siempre)
                                // 1. Verificar contraseña actual contra BD (siempre)
                                // Usamos el cubit capturado del contexto padre
                                final state = cubit.state;
                                if (state is! PantallaDuenoAutenticado) {
                                  throw Exception('Negocio no autenticado');
                                }
                                final negocio = state.negocio;

                                final authBD = await cubit.negocioRepositorio
                                    .autenticarNegocio(
                                  email: negocio.email,
                                  password: passwordActual,
                                );

                                if (authBD == null) {
                                  throw Exception('Contraseña actual incorrecta');
                                }

                                // 2. Si NO es Google, intentar actualizar en Auth
                                bool authActualizado = false;
                                if (!esGoogle) {
                                    try {
                                      await auth.cambiarPassword(
                                        passwordActual: passwordActual,
                                        passwordNueva: passwordNueva,
                                      );
                                      authActualizado = true;
                                    } catch (e) {
                                      // Si falla auth, decidimos si continuar
                                      print('⚠️ Error Auth Password: $e');
                                      // Si es mismatch, continuamos. Si es weak-password, frenamos.
                                      if (e.toString().contains('weak-password')) rethrow;
                                    }
                                }

                                // 3. Actualizar en Firestore (Siempre)
                                await cubit.negocioRepositorio.actualizarPassword(
                                  negocio.id,
                                  passwordNueva,
                                );
                                
                                // Actualizar estado local si existe el método en el negocio (opcional/future proof)
                                // final negocioActualizado = negocio.copyWith(password: passwordNueva);
                                // cubit.establecerNegocioAutenticado(negocioActualizado);

                                if (!context.mounted) return;
                                Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authActualizado 
                                        ? '✅ Contraseña actualizada (Auth + BD)' 
                                        : '✅ Contraseña de respaldo actualizada (Solo BD)',
                                    ),
                                    backgroundColor: const Color(0xFF27AE60),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } catch (e) {
                                setState(() => isLoading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ ${e.toString().replaceAll('Exception: ', '')}',
                                      ),
                                      backgroundColor: const Color(0xFFE74C3C),
                                    ),
                                  );
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Cambiar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarVerificacionTelefono(BuildContext context, dynamic negocio) {
    final cubit = context.read<PantallaDuenoCubit>();
    final auth = getIt<ServicioAutenticacion>();
    final telefonoController = TextEditingController(text: negocio.telefono);
    final codigoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        int paso = 1; // 1: ingresar teléfono, 2: ingresar código
        bool isLoading = false;
        int tiempoRestante = 0;
        String? errorMessage;
        bool verificadoExitosamente = false;

        return StatefulBuilder(
          builder: (context, setState) {
            // Timer de reenvío
            void iniciarTimer() {
              tiempoRestante = 60;
              Future.doWhile(() async {
                await Future.delayed(const Duration(seconds: 1));
                if (tiempoRestante > 0 && context.mounted) {
                  setState(() => tiempoRestante--);
                  return true;
                }
                return false;
              });
            }

            Future<void> enviarCodigo() async {
              final telefono = telefonoController.text.trim();

              // Validar teléfono
              final validacion = auth.validarTelefonoArgentino(telefono);
              if (validacion['valido'] != true) {
                setState(() => errorMessage = validacion['error']);
                return;
              }

              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              await auth.enviarCodigoSMS(
                numeroTelefono: telefono,
                onCodeSent: (mensaje) {
                  setState(() {
                    isLoading = false;
                    paso = 2;
                  });
                  iniciarTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📱 $mensaje'),
                      backgroundColor: const Color(0xFF27AE60),
                    ),
                  );
                },
                onError: (error) {
                  setState(() {
                    isLoading = false;
                    errorMessage = error;
                  });
                },
                onAutoVerified: () {
                  setState(() {
                    verificadoExitosamente = true;
                    isLoading = false;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pop(dialogContext);
                  });
                },
              );
            }

            Future<void> verificarCodigo() async {
              final codigo = codigoController.text.trim();

              if (codigo.length != 6) {
                setState(() => errorMessage = 'El código debe tener 6 dígitos');
                return;
              }

              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                await auth.verificarCodigoSMS(codigo: codigo);
                
                // Si llegamos aquí, Auth se actualizó correctamente
                await cubit.negocioRepositorio.actualizarTelefono(
                  negocio.id,
                  telefonoController.text,
                  verificado: true,
                );

                setState(() {
                  verificadoExitosamente = true;
                  isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ ¡Teléfono verificado y vinculado!'),
                    backgroundColor: Color(0xFF27AE60),
                    duration: Duration(seconds: 3),
                  ),
                );

                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) Navigator.pop(dialogContext);
                });
              } catch (e) {
                // Manejo especial para conflicto de credenciales
                // Si el error es "account-exists-with-different-credential", significa que 
                // el código SMS era CORRRECTO (porque Firebase validó la credencial), 
                // pero no se pudo vincular a la cuenta Auth.
                // Aceptamos la verificación como válida para el negocio.
                if (e.toString().contains('account-exists-with-different-credential') || 
                    e.toString().contains('credential-already-in-use')) {
                  
                  await cubit.negocioRepositorio.actualizarTelefono(
                    negocio.id,
                    telefonoController.text,
                    verificado: true,
                  );

                  setState(() {
                    verificadoExitosamente = true;
                    isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Teléfono verificado (Vinculado a otra cuenta)'),
                      backgroundColor: Color(0xFFF39C12), // Naranja de advertencia
                      duration: Duration(seconds: 4),
                    ),
                  );

                  Future.delayed(const Duration(seconds: 3), () {
                    if (context.mounted) Navigator.pop(dialogContext);
                  });
                } else {
                  setState(() {
                    isLoading = false;
                    errorMessage = e.toString().replaceAll('Exception: ', '');
                  });
                }
              }
            }

            if (verificadoExitosamente) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF27AE60),
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '¡Teléfono Verificado!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu número ${telefonoController.text} ha sido verificado correctamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    paso == 1 ? Icons.phone_android : Icons.sms,
                    color: const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 12),
                  Text(paso == 1 ? 'Verificar Teléfono' : 'Ingresar Código'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (paso == 1) ...[
                      const Text(
                        'Ingresa tu número de teléfono para recibir un código SMS de verificación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: '+54 9 11 1234-5678',
                          helperText: 'Formato argentino con código de área',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Se enviará un SMS con código de verificación',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (paso == 2) ...[
                      Text(
                        'Ingresa el código de 6 dígitos enviado a:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        telefonoController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Verificación',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: '123456',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (tiempoRestante > 0)
                        Text(
                          'Reenviar código en ${tiempoRestante}s',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        TextButton.icon(
                          onPressed: isLoading ? null : enviarCodigo,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reenviar código'),
                        ),
                    ],
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (paso == 2)
                  TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () => setState(() {
                              paso = 1;
                              codigoController.clear();
                              errorMessage = null;
                            }),
                    child: const Text('Cambiar número'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : (paso == 1 ? enviarCodigo : verificarCodigo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(paso == 1 ? 'Enviar SMS' : 'Verificar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarGestionHorarios(BuildContext context, negocio) async {
    final cubit = context.read<PantallaDuenoCubit>();
    // 1. Obtener los horarios actuales de la base de datos
    final horariosActuales = await cubit.obtenerHorarios(negocio.id);

    // 2. Preparar los controladores para la edición
    // Convertimos el Mapa {'Día': 'Hora'} en una Lista de pares de controladores para poder editar visualmente
    List<Map<String, TextEditingController>> filasEdicion = [];

    if (horariosActuales.isEmpty) {
      // Si no hay nada, agregamos una fila vacía por defecto
      filasEdicion.add({
        'dia': TextEditingController(text: ''),
        'hora': TextEditingController(text: ''),
      });
    } else {
      horariosActuales.forEach((dia, hora) {
        filasEdicion.add({
          'dia': TextEditingController(text: dia),
          'hora': TextEditingController(text: hora),
        });
      });
    }

    // 3. Mostrar el Diálogo
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Usamos StatefulBuilder para poder actualizar la lista (agregar/quitar filas) dentro del diálogo
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.schedule, color: Color(0xFFE67E22)),
                  SizedBox(width: 12),
                  Text('Gestionar Horarios'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Define los rangos de atención. Ejemplo:\n"Lun - Vie" : "12:00 - 22:00"',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Lista de Filas de Edición
                      ...filasEdicion.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controladores = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Campo Día
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: controladores['dia'],
                                  decoration: InputDecoration(
                                    labelText: 'Días / Título',
                                    hintText: 'Ej: Sab-Dom',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(12),
                                    fillColor: Colors.grey[50],
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Campo Hora
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: controladores['hora'],
                                  decoration: InputDecoration(
                                    labelText: 'Horario',
                                    hintText: 'Ej: 18:00 - 02:00',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(12),
                                    fillColor: Colors.grey[50],
                                    filled: true,
                                  ),
                                ),
                              ),
                              // Botón Eliminar Fila
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    filasEdicion.removeAt(index);
                                  });
                                },
                                tooltip: 'Eliminar fila',
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      // Botón Agregar Nueva Fila
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            filasEdicion.add({
                              'dia': TextEditingController(),
                              'hora': TextEditingController(),
                            });
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar Otro Horario'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE67E22),
                          side: const BorderSide(color: Color(0xFFE67E22)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 4. Reconstruir el Mapa a partir de los controladores
                    final Map<String, String> nuevosHorarios = {};

                    for (var fila in filasEdicion) {
                      final dia = fila['dia']!.text.trim();
                      final hora = fila['hora']!.text.trim();

                      if (dia.isNotEmpty && hora.isNotEmpty) {
                        nuevosHorarios[dia] = hora;
                      }
                    }

                    // Guardar usando el Cubit
                    final exito = await cubit.actualizarHorarios(
                      negocio.id,
                      nuevosHorarios,
                    );

                    if (context.mounted) Navigator.pop(dialogContext);

                    if (exito && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✅ Horarios configurados correctamente',
                          ),
                          backgroundColor: Color(0xFF27AE60),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Error al guardar horarios'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE67E22),
                  ),
                  child: const Text('Guardar Todo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarReservas(BuildContext context, negocio) async {
    final cubit = context.read<PantallaDuenoCubit>();

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Cargando reservas...'),
            ],
          ),
        );
      },
    );

    final reservas = await cubit.obtenerReservasDelNegocio(negocio.id);
    final mesas = await cubit.obtenerMesasDelNegocio(negocio.id);
    Navigator.pop(context); // Cerrar diálogo de carga

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filtro: Solo Confirmadas y Canceladas
            final reservasVisibles =
                reservas
                    .where(
                      (r) =>
                          r.estado == EstadoReserva.confirmada ||
                          r.estado == EstadoReserva.cancelada,
                    )
                    .toList();
            final reservasConfirmadas =
                reservas
                    .where((r) => r.estado == EstadoReserva.confirmada)
                    .toList();
            final reservasCanceladas =
                reservas
                    .where((r) => r.estado == EstadoReserva.cancelada)
                    .toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.9,
                constraints: const BoxConstraints(
                  maxWidth: 700,
                  maxHeight: 600,
                ),
                child: Column(
                  children: [
                    // Encabezado
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3498DB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_note,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Administrar Reservas',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  negocio.nombre,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ),

                    // Estadísticas rápidas
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildEstadisticaChip(
                            'Confirmadas',
                            reservasConfirmadas.length,
                            Colors.green,
                          ),
                          _buildEstadisticaChip(
                            'Canceladas',
                            reservasCanceladas.length,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),

                    // Lista de reservas
                    Expanded(
                      child:
                          reservasVisibles.isEmpty
                              ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No hay reservas confirmadas o canceladas',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: reservasVisibles.length,
                                itemBuilder: (context, index) {
                                  final reserva = reservasVisibles[index];
                                  final mesa = mesas.firstWhere(
                                    (m) => m.id == reserva.mesaId,
                                    orElse:
                                        () => Mesa(
                                          id: '',
                                          nombre: 'Desconocida',
                                          capacidad: 0,
                                          negocioId: '',
                                        ),
                                  );

                                  return _buildReservaCardAdmin(
                                    context,
                                    reserva,
                                    mesa,
                                    cubit,
                                    () async {
                                      // Recargar reservas
                                      try {
                                        final nuevasReservas = await cubit
                                            .obtenerReservasDelNegocio(
                                              negocio.id,
                                            );
                                        // Verificar que el contexto todavía está montado
                                        if (context.mounted) {
                                          setState(() {
                                            reservas.clear();
                                            reservas.addAll(nuevasReservas);
                                          });
                                        }
                                      } catch (e) {
                                        print('Error recargando reservas: $e');
                                      }
                                    },
                                  );
                                },
                              ),
                    ),

                    // Botón cerrar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cerrar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEstadisticaChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReservaCardAdmin(
    BuildContext context,
    Reserva reserva,
    Mesa mesa,
    PantallaDuenoCubit cubit,
    VoidCallback onUpdate,
  ) {
    Color getEstadoColor(EstadoReserva estado) {
      switch (estado) {
        case EstadoReserva.confirmada:
          return const Color(0xFF27AE60);
        case EstadoReserva.pendiente:
          return const Color(0xFFF39C12);
        case EstadoReserva.cancelada:
          return const Color(0xFFE74C3C);
      }
    }

    IconData getEstadoIcono(EstadoReserva estado) {
      switch (estado) {
        case EstadoReserva.confirmada:
          return Icons.check_circle;
        case EstadoReserva.pendiente:
          return Icons.schedule;
        case EstadoReserva.cancelada:
          return Icons.cancel;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: getEstadoColor(reserva.estado).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado
            Row(
              children: [
                Icon(
                  getEstadoIcono(reserva.estado),
                  color: getEstadoColor(reserva.estado),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reserva #${reserva.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getEstadoColor(reserva.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reserva.estado.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: getEstadoColor(reserva.estado),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Información de la reserva
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRowSmall(
                        Icons.person,
                        'Cliente',
                        reserva.nombreCliente ?? reserva.contactoCliente ?? 'Sin datos',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(
                        Icons.calendar_today,
                        'Fecha',
                        '${reserva.fechaHora.day}/${reserva.fechaHora.month}/${reserva.fechaHora.year}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(
                        Icons.access_time,
                        'Hora',
                        '${reserva.fechaHora.hour.toString().padLeft(2, '0')}:${reserva.fechaHora.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRowSmall(
                        Icons.table_restaurant,
                        'Mesa',
                        mesa.nombre,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(
                        Icons.people,
                        'Personas',
                        '${reserva.numeroPersonas}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(
                        Icons.chair,
                        'Capacidad mesa',
                        '${mesa.capacidad}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Botones de acción o Estado Finalizado
            if (reserva.fechaHora.isBefore(DateTime.now()) && reserva.estado != EstadoReserva.cancelada) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Reserva Finalizada',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (reserva.estado != EstadoReserva.cancelada) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _mostrarConfirmarCancelarReserva(
                      context,
                      reserva.id,
                      cubit,
                      onUpdate,
                    );
                  },
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text(
                    'Cancelar reserva',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE74C3C),
                    side: const BorderSide(color: Color(0xFFE74C3C)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowSmall(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 13, color: Color(0xFF2C3E50)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _mostrarConfirmarCancelarReserva(
    BuildContext context,
    String reservaId,
    PantallaDuenoCubit cubit,
    VoidCallback onUpdate,
  ) {
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cancel, color: const Color(0xFFE74C3C)),
                const SizedBox(width: 8),
                const Text('Cancelar Reserva'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Estás seguro de que deseas cancelar esta reserva?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: motivoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Motivo de cancelación (opcional)',
                    hintText: 'Ej: Problema con la mesa, evento privado, etc.',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit_note),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF3498DB).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: const Color(0xFF3498DB),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Se enviará un email al cliente informando la cancelación.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('No, mantener'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final motivo = motivoController.text.trim();
                  Navigator.of(dialogContext).pop();

                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (loadingContext) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  final exito = await cubit.cancelarReservaAdmin(
                    reservaId,
                    motivo: motivo.isNotEmpty ? motivo : null,
                  );

                  // Cerrar indicador de carga
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  if (exito && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✅ Reserva cancelada. Se envió email al cliente.',
                        ),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                    onUpdate();
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Error al cancelar la reserva'),
                        backgroundColor: Color(0xFFE74C3C),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar Cancelación'),
              ),
            ],
          ),
    );
  }

  void _mostrarGestionZonas(BuildContext context, Negocio negocio) {
    // Capturar el cubit antes del diálogo
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Inicializar estado local fuera del builder para que persista
        final List<String> zonasEditables = List.from(negocio.zonas);
        if (zonasEditables.isEmpty) {
          zonasEditables.addAll(['Salón', 'Terraza']);
        }
        final nuevaZonaController = TextEditingController();

        return StatefulBuilder(
          builder: (statefulContext, setState) {

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.map, color: Color(0xFF9B59B6)),
                  SizedBox(width: 12),
                  Text('Gestionar Zonas'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Input para nuevas zonas
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nuevaZonaController,
                            decoration: const InputDecoration(
                              hintText: 'Nueva zona (ej: Jardín)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final nueva = nuevaZonaController.text.trim();
                            if (nueva.isNotEmpty) {
                              // Verificar duplicados (case insensitive)
                              if (!zonasEditables.any((z) => z.toLowerCase() == nueva.toLowerCase())) {
                                setState(() {
                                  zonasEditables.add(nueva);
                                  nuevaZonaController.clear();
                                  // Actualizar variable local del negocio para reflejar cambios visuales inmediatos si fuera necesario, 
                                  // pero aquí solo editamos la lista temporal.
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('La zona ya existe'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.add_circle, size: 28),
                          color: const Color(0xFF27AE60),
                          tooltip: 'Agregar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Zonas Disponibles',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    // Lista de zonas
                    Expanded(
                      child: zonasEditables.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay zonas definidas',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: zonasEditables.length,
                              itemBuilder: (ctx, index) {
                                final zona = zonasEditables[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  child: ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF9B59B6),
                                    ),
                                    title: Text(zona),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          zonasEditables.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (zonasEditables.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debe haber al menos una zona'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Guardar cambios usando el cubit
                    // Aquí llamamos al método que implementamos en el cubit
                     final exito = await cubit.actualizarZonas(
                       negocio,
                       zonasEditables,
                     );

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Zonas actualizadas'),
                            backgroundColor: Color(0xFF27AE60),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Error al actualizar zonas'),
                            backgroundColor: Color(0xFFE74C3C),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B59B6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarGestionMesas(BuildContext context, negocio) async {
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.table_bar, color: Color(0xFF27AE60)),
                  const SizedBox(width: 12),
                  const Text('Gestionar Mesas'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: FutureBuilder<List<Mesa>>(
                  future: cubit.obtenerMesasDelNegocio(negocio.id),
                  builder: (statefulContext, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final mesas = snapshot.data ?? [];

                    if (mesas.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.table_bar, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay mesas configuradas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: mesas.length,
                      itemBuilder: (statefulContext, index) {
                        final mesa = mesas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(
                                0xFF27AE60,
                              ).withOpacity(0.1),
                              child: const Icon(
                                Icons.table_bar,
                                color: Color(0xFF27AE60),
                              ),
                            ),
                            title: Text(
                              mesa.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Capacidad: ${mesa.capacidad} personas',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF3498DB),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    _mostrarEditarMesa(
                                      context,
                                      negocio,
                                      mesa,
                                      setState,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmar = await showDialog<bool>(
                                      context: statefulContext,
                                      builder:
                                          (ctx) => AlertDialog(
                                            title: const Text(
                                              'Confirmar eliminación',
                                            ),
                                            content: Text(
                                              '¿Eliminar ${mesa.nombre}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      ctx,
                                                      false,
                                                    ),
                                                child: const Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      ctx,
                                                      true,
                                                    ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirmar == true) {
                                      final exito = await cubit.eliminarMesa(
                                        mesa.id,
                                      );
                                      if (exito) {
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Mesa eliminada correctamente',
                                            ),
                                            backgroundColor: Color(0xFF27AE60),
                                          ),
                                        );
                                        _mostrarGestionMesas(context, negocio);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cerrar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Usar el context original que tiene acceso al cubit
                    _mostrarAgregarMesa(context, negocio);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Mesa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarAgregarMesa(BuildContext context, Negocio negocio) {
    final nombreController = TextEditingController();
    final capacidadController = TextEditingController();
    // Valor inicial para la zona (primera disponible o Salón por defecto)
    String zonaSeleccionada = negocio.zonas.isNotEmpty ? negocio.zonas.first : 'Salón';
    
    // Capturar el cubit FUERA del diálogo
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_circle, color: Color(0xFF27AE60)),
                  SizedBox(width: 12),
                  Text('Agregar Mesa'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Mesa',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.table_bar),
                      hintText: 'Ej: Mesa 5',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: capacidadController,
                    decoration: const InputDecoration(
                      labelText: 'Capacidad (personas)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                      hintText: 'Ej: 4',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: zonaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Zona',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    items: negocio.zonas.map((String zona) {
                      return DropdownMenuItem<String>(
                        value: zona,
                        child: Text(zona),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          zonaSeleccionada = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nombre = nombreController.text.trim();
                    final capacidadStr = capacidadController.text.trim();

                    if (nombre.isEmpty || capacidadStr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor completa todos los campos'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final capacidad = int.tryParse(capacidadStr);
                    if (capacidad == null || capacidad < 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La capacidad debe ser un número válido mayor a 0',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Cerrar el diálogo
                    Navigator.pop(dialogContext);

                    // Ejecutar la acción (usando el cubit capturado arriba)
                    final nuevaMesa = await cubit.agregarMesa(
                      negocio.id,
                      nombre,
                      capacidad,
                      zonaSeleccionada,
                    );

                    if (nuevaMesa != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ ${nuevaMesa.nombre} agregada correctamente',
                          ),
                          backgroundColor: const Color(0xFF27AE60),
                        ),
                      );
                      // Reabrir el diálogo de gestión de mesas
                      _mostrarGestionMesas(context, negocio);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Error al agregar mesa'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarEditarMesa(
    BuildContext context,
    Negocio negocio,
    Mesa mesa,
    StateSetter setState,
  ) {
    final nombreController = TextEditingController(text: mesa.nombre);
    final capacidadController = TextEditingController(
      text: mesa.capacidad.toString(),
    );
    // Verificar si la zona actual aun existe en el negocio, si no, agregarla temporalmente o usar default
    // Importante: mesa.zona es String ahora
    String zonaSeleccionada = mesa.zona;
    if (!negocio.zonas.contains(zonaSeleccionada)) {
        // Si es una zona legacy o eliminada, la permitimos en el dropdown?
        // O mejor, la forzamos a ser una de las válidas si el usuario edita?
        // Para simplificar, si no está, usamos la primera disponible, 
        // pero idealmente deberíamos agregarla a la lista del dropdown aunque sea temporalmente.
        if (negocio.zonas.isNotEmpty) {
             // Si la zona de la mesa no está en la lista del negocio (ej: fue borrada),
             // mantenemos la actual SOLO si queremos mostrarla, pero el dropdown
             // necesita que el valor esté en items.
             // Opción: agregarla temporalmente a la lista de items del dropdown.
        }
    }
    
    // Capturar el cubit FUERA del diálogo
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setState) {
                // Preparamos los items del dropdown asegurando que la zona actual esté presente
                final zonasItems = List<String>.from(negocio.zonas);
                if (!zonasItems.contains(zonaSeleccionada) && zonaSeleccionada.isNotEmpty) {
                    zonasItems.add(zonaSeleccionada);
                }
                
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF3498DB)),
                      SizedBox(width: 12),
                      Text('Editar Mesa'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Mesa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.table_bar),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: capacidadController,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad (personas)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: zonaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Zona',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: zonasItems.map((String zona) {
                          return DropdownMenuItem<String>(
                            value: zona,
                            child: Text(zona),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              zonaSeleccionada = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final nombre = nombreController.text.trim();
                        final capacidadStr = capacidadController.text.trim();
    
                        if (nombre.isEmpty || capacidadStr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor completa todos los campos'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
    
                        final capacidad = int.tryParse(capacidadStr);
                        if (capacidad == null || capacidad < 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La capacidad debe ser un número válido mayor a 0',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
    
                        final mesaActualizada = mesa.copyWith(
                          nombre: nombre,
                          capacidad: capacidad,
                          zona: zonaSeleccionada,
                        );
    
                        // Cerrar el diálogo
                        Navigator.pop(dialogContext);
    
                        // Ejecutar la acción (usando el cubit capturado arriba)
                        final exito = await cubit.actualizarMesa(mesaActualizada);
    
                        if (exito && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Mesa actualizada correctamente'),
                              backgroundColor: Color(0xFF27AE60),
                            ),
                          );
                          // Reabrir el diálogo de gestión de mesas
                          _mostrarGestionMesas(context, negocio);
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ Error al actualizar mesa'),
                              backgroundColor: Color(0xFFE74C3C),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ],
                );
            }
        );
      },
    );
  }

  // Método para mostrar métricas y análisis
  void _mostrarMetricas(BuildContext context, negocio) async {
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Text('Cargando métricas...'),
            ],
          ),
        );
      },
    );

    final metricas = await cubit.obtenerMetricasReservas(negocio.id);
    Navigator.pop(context); // Cerrar diálogo de carga

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(dialogContext).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado
                    Row(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          color: Color(0xFF9B59B6),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Métricas y Análisis',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              Text(
                                negocio.nombre,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Resumen general
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricaCard(
                            'Total Reservas',
                            '${metricas['totalReservas'] ?? 0}',
                            Icons.event,
                            const Color(0xFF3498DB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricaCard(
                            'Reservas Hoy',
                            '${metricas['reservasHoy'] ?? 0}',
                            Icons.today,
                            const Color(0xFF27AE60),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricaCard(
                            'Este Mes',
                            '${metricas['reservasMesActual'] ?? 0}',
                            Icons.calendar_month,
                            const Color(0xFFE67E22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Reservas por día (últimos 7 días)
                    const Text(
                      'Reservas por Día (Últimos 7 días)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGraficaBarras(metricas['reservasPorDia'] ?? {}),
                    const SizedBox(height: 24),

                    // Reservas por mes
                    const Text(
                      'Reservas por Mes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGraficaBarras(metricas['reservasPorMes'] ?? {}),
                    const SizedBox(height: 24),

                    // Horarios pico y poco movimiento
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🔥 Horarios Pico',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE74C3C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._buildListaHorarios(
                                metricas['horariosPico'] ?? [],
                                const Color(0xFFE74C3C),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📉 Poco Movimiento',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF95A5A6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._buildListaHorarios(
                                metricas['horariosPocoMovimiento'] ?? [],
                                const Color(0xFF95A5A6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botón cerrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B59B6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricaCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icono, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficaBarras(Map<String, int> datos) {
    if (datos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final maxValor = datos.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              datos.entries.map((entry) {
                final porcentaje =
                    maxValor > 0 ? (entry.value / maxValor) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: porcentaje,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3498DB),
                                      Color(0xFF2980B9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildListaHorarios(List<dynamic> horarios, Color color) {
    if (horarios.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Sin datos',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ];
    }

    return horarios.map((h) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          dense: true,
          leading: Icon(Icons.access_time, color: color, size: 20),
          title: Text(
            h['hora'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${h['reservas']}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // Método para mostrar configuración de reglas de negocio
  void _mostrarConfiguracionReglas(BuildContext context, negocio) {
    final cubit = context.read<PantallaDuenoCubit>();

    // Controladores con valores actuales
    final duracionController = TextEditingController(
      text: negocio.duracionPromedioMinutos.toString(),
    );
    final cancelacionController = TextEditingController(
      text: negocio.minHorasParaCancelar.toString(),
    );
    final anticipacionController = TextEditingController(
      text: negocio.maxDiasAnticipacionReserva.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(dialogContext).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F8C8D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings_suggest,
                            color: Color(0xFF2C3E50),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reglas de Negocio',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              Text(
                                'Configuración de tiempos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Campo: Duración promedio de reserva
                    _buildReglaField(
                      icon: Icons.timer,
                      label: 'Duración de reserva',
                      hint: 'Minutos por reserva',
                      controller: duracionController,
                      suffix: 'min',
                      helperText:
                          'Tiempo que dura cada reserva (ej: 60, 90, 120)',
                    ),

                    const SizedBox(height: 20),

                    // Campo: Horas mínimas para cancelar
                    _buildReglaField(
                      icon: Icons.cancel_schedule_send,
                      label: 'Anticipación para cancelar',
                      hint: 'Horas mínimas',
                      controller: cancelacionController,
                      suffix: 'hrs',
                      helperText:
                          'Horas de anticipación mínima para cancelar una reserva',
                    ),

                    const SizedBox(height: 20),

                    // Campo: Días máximos de anticipación
                    _buildReglaField(
                      icon: Icons.date_range,
                      label: 'Anticipación máxima',
                      hint: 'Días máximos',
                      controller: anticipacionController,
                      suffix: 'días',
                      helperText: 'Cuántos días en el futuro se puede reservar',
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final duracion =
                                int.tryParse(duracionController.text) ?? 60;
                            final cancelacion =
                                int.tryParse(cancelacionController.text) ?? 24;
                            final anticipacion =
                                int.tryParse(anticipacionController.text) ?? 14;

                            // Validaciones básicas
                            if (duracion < 15 || duracion > 480) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'La duración debe estar entre 15 y 480 minutos',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            if (cancelacion < 1 || cancelacion > 168) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Las horas para cancelar deben estar entre 1 y 168',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            if (anticipacion < 1 || anticipacion > 90) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Los días de anticipación deben estar entre 1 y 90',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            final exito = await cubit
                                .actualizarConfiguracionReglas(
                                  negocio,
                                  duracionPromedioMinutos: duracion,
                                  minHorasParaCancelar: cancelacion,
                                  maxDiasAnticipacionReserva: anticipacion,
                                );

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  exito
                                      ? '✅ Configuración actualizada correctamente'
                                      : '❌ Error al actualizar la configuración',
                                ),
                                backgroundColor:
                                    exito ? Colors.green : Colors.red,
                              ),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget helper para los campos de reglas
  Widget _buildReglaField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required String suffix,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF7F8C8D)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            helperText: helperText,
            helperMaxLines: 2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarEditorHistoria(BuildContext context) async {
    final cubit = context.read<PantallaDuenoCubit>();
    final state = cubit.state;

    if (state is! PantallaDuenoAutenticado) return;
    final negocioId = state.negocio.id;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final historia = await cubit.obtenerHistoria(negocioId);

    if (context.mounted) {
      Navigator.pop(context); // Cerrar loading
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => BlocProvider.value(
                value: cubit,
                child: EditorHistoriaScreen(
                  negocioId: negocioId,
                  historiaInicial: historia,
                ),
              ),
        ),
      );
    }
  }
}

// --- CLASES DEL EDITOR DE HISTORIA ---

class EditorHistoriaScreen extends StatefulWidget {
  final String negocioId;
  final HistoriaRestaurante? historiaInicial;

  const EditorHistoriaScreen({
    super.key,
    required this.negocioId,
    this.historiaInicial,
  });

  @override
  State<EditorHistoriaScreen> createState() => _EditorHistoriaScreenState();
}

class _EditorHistoriaScreenState extends State<EditorHistoriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _tituloController;
  late TextEditingController _subtituloController;
  late TextEditingController _parrafosController;
  late List<EspecialidadItemEditable> _platosEditables;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    if (widget.historiaInicial != null) {
      final datos = widget.historiaInicial!;
      _tituloController = TextEditingController(text: datos.titulo);
      _subtituloController = TextEditingController(text: datos.subtitulo);
      _parrafosController = TextEditingController(
        text: datos.parrafosHistoria.join('\n\n'),
      );
      _platosEditables =
          datos.especialidades
              .map((e) => EspecialidadItemEditable.fromItem(e))
              .toList();
    } else {
      _tituloController = TextEditingController();
      _subtituloController = TextEditingController();
      _parrafosController = TextEditingController();
      _platosEditables = [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _subtituloController.dispose();
    _parrafosController.dispose();
    for (var p in _platosEditables) {
      p.dispose();
    }
    super.dispose();
  }

  void _guardarCambios() async {
    final nuevosParrafos =
        _parrafosController.text
            .split('\n\n')
            .where((p) => p.trim().isNotEmpty)
            .toList();
    final nuevosPlatos = _platosEditables.map((e) => e.toItem()).toList();

    final nuevaHistoria = HistoriaRestaurante(
      titulo: _tituloController.text.trim(),
      subtitulo: _subtituloController.text.trim(),
      parrafosHistoria: nuevosParrafos.isEmpty ? ['...'] : nuevosParrafos,
      especialidades: nuevosPlatos,
    );

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final cubit = context.read<PantallaDuenoCubit>();
    final exito = await cubit.guardarHistoria(
      widget.negocioId,
      nuevaHistoria,
    );

    if (context.mounted) {
      Navigator.pop(context); // Cerrar loading

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Historia actualizada correctamente'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
        Navigator.pop(context); // Cerrar pantalla
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al guardar historia'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Contenido'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Textos'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Platos'),
          ],
        ),
        actions: [
          IconButton(onPressed: _guardarCambios, icon: const Icon(Icons.save)),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTabHistoria(), _buildTabPlatos()],
      ),
      floatingActionButton:
          _tabController.index == 1
              ? FloatingActionButton.extended(
                onPressed:
                    () => setState(
                      () => _platosEditables.add(EspecialidadItemEditable()),
                    ),
                label: const Text('Nuevo Plato'),
                icon: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildTabHistoria() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _subtituloController,
            decoration: const InputDecoration(
              labelText: 'Subtítulo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _parrafosController,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Historia (doble enter para párrafos)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPlatos() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _platosEditables.length,
      itemBuilder: (ctx, i) {
        final p = _platosEditables[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de Ícono
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        p.iconoSeleccionado,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Campo Nombre
                    Expanded(
                      child: TextField(
                        controller: p.nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Plato',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFFFAFAFA),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    // Botón Borrar
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed:
                          () => setState(() => _platosEditables.removeAt(i)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Campo Descripción
                TextField(
                  controller: p.descripcionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción corta',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFFAFAFA),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecciona un ícono:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                // Lista de íconos
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        [
                              Icons.restaurant,
                              Icons.local_pizza,
                              Icons.lunch_dining,
                              Icons.icecream,
                              Icons.cake,
                              Icons.coffee,
                              Icons.wine_bar,
                              Icons.set_meal,
                            ]
                            .map(
                              (ic) => InkWell(
                                onTap:
                                    () => setState(
                                      () => p.iconoSeleccionado = ic,
                                    ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        p.iconoSeleccionado == ic
                                            ? Colors.blue
                                            : Colors.transparent,
                                    border: Border.all(
                                      color:
                                          p.iconoSeleccionado == ic
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    ic,
                                    color:
                                        p.iconoSeleccionado == ic
                                            ? Colors.white
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EspecialidadItemEditable {
  final TextEditingController nombreCtrl;
  final TextEditingController descripcionCtrl;
  IconData iconoSeleccionado;

  EspecialidadItemEditable({
    String nombre = '',
    String descripcion = '',
    this.iconoSeleccionado = Icons.restaurant,
  }) : nombreCtrl = TextEditingController(text: nombre),
       descripcionCtrl = TextEditingController(text: descripcion);

  factory EspecialidadItemEditable.fromItem(EspecialidadItem item) =>
      EspecialidadItemEditable(
        nombre: item.nombre,
        descripcion: item.descripcion,
        iconoSeleccionado: item.icono,
      );

  EspecialidadItem toItem() => EspecialidadItem(
    nombre: nombreCtrl.text.trim().isEmpty ? 'Plato' : nombreCtrl.text.trim(),
    descripcion: descripcionCtrl.text.trim(),
    icono: iconoSeleccionado,
  );

  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
  }
}
