import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/entidades/mesa.dart';
import '../../dominio/entidades/reserva.dart';
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
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: Colors.red,
            ),
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
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.grey[400],
                  ),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
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
                      child: const Icon(
                        Icons.restaurant,
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
                      _buildDashboardCard(
                        context,
                        icon: Icons.event_note,
                        title: 'Reservas',
                        subtitle: 'Gestionar',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                        ),
                        onTap: () => _mostrarReservas(context, negocio),
                      ),
                      const SizedBox(width: 16),
                      _buildDashboardCard(
                        context,
                        icon: Icons.table_bar,
                        title: 'Mesas',
                        subtitle: 'Configurar',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF27AE60), Color(0xFF229954)],
                        ),
                        onTap: () => _mostrarGestionMesas(context, negocio),
                      ),
                      const SizedBox(width: 16),
                      _buildDashboardCard(
                        context,
                        icon: Icons.schedule,
                        title: 'Horarios',
                        subtitle: 'Definir',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                        ),
                        onTap: () => _mostrarGestionHorarios(context, negocio),
                      ),
                      const SizedBox(width: 16),
                      _buildDashboardCard(
                        context,
                        icon: Icons.bar_chart,
                        title: 'Métricas',
                        subtitle: 'Análisis',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                        ),
                        onTap: () => _mostrarMetricas(context, negocio),
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
            
            _buildInfoCard(
              icon: Icons.email,
              titulo: 'Correo Electrónico',
              valor: negocio.email,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              icon: Icons.phone,
              titulo: 'Teléfono',
              valor: negocio.telefono,
              color: colorScheme.secondary,
              editable: true,
              onEdit: () => _mostrarEditarTelefono(context, negocio),
            ),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              icon: Icons.location_on,
              titulo: 'Dirección',
              valor: negocio.direccion,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              icon: Icons.restaurant_menu,
              titulo: 'Especialidad',
              valor: negocio.especialidad,
              color: const Color(0xFF9B59B6),
              editable: true,
              onEdit: () => _mostrarEditarEspecialidad(context, negocio),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            if (editable)
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
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
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Número de Teléfono',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevoTelefono = controller.text.trim();
                if (nuevoTelefono.isNotEmpty) {
                  final cubit = context.read<PantallaDuenoCubit>();
                  final exito = await cubit.actualizarTelefono(negocio, nuevoTelefono);
                  
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
                  final exito = await cubit.actualizarEspecialidad(negocio, nuevaEspecialidad);
                  
                  Navigator.pop(dialogContext);
                  
                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Especialidad actualizada correctamente'),
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

  void _mostrarGestionHorarios(BuildContext context, negocio) async {
    final cubit = context.read<PantallaDuenoCubit>();
    final horariosActuales = await cubit.obtenerHorarios(negocio.id);
    
    final almuerzController = TextEditingController(text: horariosActuales['Almuerzo'] ?? '12:00 - 15:30');
    final cenaController = TextEditingController(text: horariosActuales['Cena'] ?? '20:00 - 23:30');
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: almuerzController,
                  decoration: const InputDecoration(
                    labelText: 'Horario de Almuerzo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lunch_dining),
                    hintText: 'Ej: 12:00 - 15:30',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cenaController,
                  decoration: const InputDecoration(
                    labelText: 'Horario de Cena',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.dinner_dining),
                    hintText: 'Ej: 20:00 - 23:30',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estos horarios se mostrarán a los clientes en la página de disponibilidad del restaurante.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
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
                final nuevosHorarios = {
                  'Almuerzo': almuerzController.text.trim(),
                  'Cena': cenaController.text.trim(),
                };
                
                final exito = await cubit.actualizarHorarios(negocio.id, nuevosHorarios);
                
                Navigator.pop(dialogContext);
                
                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Horarios actualizados correctamente'),
                      backgroundColor: Color(0xFF27AE60),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Error al actualizar horarios'),
                      backgroundColor: Color(0xFFE74C3C),
                    ),
                  );
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
            // Filtrar reservas
            final reservasPendientes = reservas.where((r) => r.estado == EstadoReserva.pendiente).toList();
            final reservasConfirmadas = reservas.where((r) => r.estado == EstadoReserva.confirmada).toList();
            final reservasCanceladas = reservas.where((r) => r.estado == EstadoReserva.cancelada).toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
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
                          const Icon(Icons.event_note, color: Colors.white, size: 28),
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
                          _buildEstadisticaChip('Pendientes', reservasPendientes.length, Colors.orange),
                          _buildEstadisticaChip('Confirmadas', reservasConfirmadas.length, Colors.green),
                          _buildEstadisticaChip('Canceladas', reservasCanceladas.length, Colors.red),
                        ],
                      ),
                    ),

                    // Lista de reservas
                    Expanded(
                      child: reservas.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay reservas registradas',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: reservas.length,
                              itemBuilder: (context, index) {
                                final reserva = reservas[index];
                                final mesa = mesas.firstWhere(
                                  (m) => m.id == reserva.mesaId,
                                  orElse: () => Mesa(id: '', nombre: 'Desconocida', capacidad: 0, negocioId: ''),
                                );
                                
                                return _buildReservaCardAdmin(
                                  context,
                                  reserva,
                                  mesa,
                                  cubit,
                                  () async {
                                    // Recargar reservas
                                    try {
                                      final nuevasReservas = await cubit.obtenerReservasDelNegocio(negocio.id);
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
        side: BorderSide(color: getEstadoColor(reserva.estado).withOpacity(0.3), width: 2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      _buildInfoRowSmall(Icons.person, 'Cliente', reserva.clienteId),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(Icons.calendar_today, 'Fecha', 
                        '${reserva.fechaHora.day}/${reserva.fechaHora.month}/${reserva.fechaHora.year}'),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(Icons.access_time, 'Hora',
                        '${reserva.fechaHora.hour.toString().padLeft(2, '0')}:${reserva.fechaHora.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRowSmall(Icons.table_restaurant, 'Mesa', mesa.nombre),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(Icons.people, 'Personas', '${reserva.numeroPersonas}'),
                      const SizedBox(height: 8),
                      _buildInfoRowSmall(Icons.chair, 'Capacidad mesa', '${mesa.capacidad}'),
                    ],
                  ),
                ),
              ],
            ),

            // Botones de acción
            if (reserva.estado != EstadoReserva.cancelada) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (reserva.estado == EstadoReserva.pendiente)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final exito = await cubit.confirmarReserva(reserva.id);
                          if (exito) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Reserva confirmada'),
                                backgroundColor: Color(0xFF27AE60),
                              ),
                            );
                            onUpdate();
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Confirmar', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  if (reserva.estado == EstadoReserva.pendiente) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _mostrarConfirmarCancelarReserva(context, reserva.id, cubit, onUpdate);
                      },
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Cancelar', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE74C3C),
                        side: const BorderSide(color: Color(0xFFE74C3C)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
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
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva?\n\n'
          'El cliente será notificado de la cancelación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              final exito = await cubit.cancelarReservaAdmin(reservaId);
              
              // Cerrar indicador de carga
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              
              if (exito && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Reserva cancelada correctamente. Cliente notificado.'),
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
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
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
                              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                              backgroundColor: const Color(0xFF27AE60).withOpacity(0.1),
                              child: const Icon(Icons.table_bar, color: Color(0xFF27AE60)),
                            ),
                            title: Text(
                              mesa.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Capacidad: ${mesa.capacidad} personas'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    _mostrarEditarMesa(context, negocio, mesa, setState);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirmar = await showDialog<bool>(
                                      context: statefulContext,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Confirmar eliminación'),
                                        content: Text('¿Eliminar ${mesa.nombre}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      final exito = await cubit.eliminarMesa(mesa.id);
                                      if (exito) {
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ Mesa eliminada correctamente'),
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

  void _mostrarAgregarMesa(BuildContext context, negocio) {
    final nombreController = TextEditingController();
    final capacidadController = TextEditingController();
    // Capturar el cubit FUERA del diálogo
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                      content: Text('La capacidad debe ser un número válido mayor a 0'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Cerrar el diálogo
                Navigator.pop(dialogContext);
                
                // Ejecutar la acción (usando el cubit capturado arriba)
                final nuevaMesa = await cubit.agregarMesa(negocio.id, nombre, capacidad);

                if (nuevaMesa != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${nuevaMesa.nombre} agregada correctamente'),
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
  }

  void _mostrarEditarMesa(BuildContext context, negocio, Mesa mesa, StateSetter setState) {
    final nombreController = TextEditingController(text: mesa.nombre);
    final capacidadController = TextEditingController(text: mesa.capacidad.toString());
    // Capturar el cubit FUERA del diálogo
    final cubit = context.read<PantallaDuenoCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                      content: Text('La capacidad debe ser un número válido mayor a 0'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final mesaActualizada = mesa.copyWith(
                  nombre: nombre,
                  capacidad: capacidad,
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
                        const Icon(Icons.bar_chart, color: Color(0xFF9B59B6), size: 32),
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

  Widget _buildMetricaCard(String titulo, String valor, IconData icono, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: datos.entries.map((entry) {
            final porcentaje = maxValor > 0 ? (entry.value / maxValor) : 0.0;
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
                                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
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
}

