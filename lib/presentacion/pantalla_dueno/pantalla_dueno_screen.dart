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
        if (state is PantallaDuenoError) {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<PantallaDuenoCubit>().cerrarSesion();
            context.go('/');
          },
        ),
        title: Text('Panel de ${negocio.nombre}'),
        backgroundColor: const Color(0xFF27AE60),
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
        child: Column(
          children: [
            // Header con información del negocio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF27AE60),
                    const Color(0xFF229954),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      negocio.nombre,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      negocio.nombreResponsable,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Información del negocio
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Negocio',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    icon: Icons.email,
                    titulo: 'Correo Electrónico',
                    valor: negocio.email,
                    color: const Color(0xFF3498DB),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard(
                    icon: Icons.phone,
                    titulo: 'Teléfono',
                    valor: negocio.telefono,
                    color: const Color(0xFF27AE60),
                    editable: true,
                    onEdit: () => _mostrarEditarTelefono(context, negocio),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard(
                    icon: Icons.location_on,
                    titulo: 'Dirección',
                    valor: negocio.direccion,
                    color: const Color(0xFFE67E22),
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
                  
                  const SizedBox(height: 32),
                  
                  // Opciones de gestión
                  const Text(
                    'Gestión del Negocio',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildOpcionCard(
                    context,
                    icono: Icons.event_note,
                    titulo: 'Ver Reservas',
                    descripcion: 'Gestiona las reservas de tu negocio',
                    color: const Color(0xFF3498DB),
                    onTap: () {
                      _mostrarReservas(context, negocio);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _buildOpcionCard(
                    context,
                    icono: Icons.table_bar,
                    titulo: 'Gestionar Mesas',
                    descripcion: 'Configura las mesas disponibles',
                    color: const Color(0xFF27AE60),
                    onTap: () {
                      _mostrarGestionMesas(context, negocio);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _buildOpcionCard(
                    context,
                    icono: Icons.schedule,
                    titulo: 'Horarios',
                    descripcion: 'Define tus horarios de atención',
                    color: const Color(0xFFE67E22),
                    onTap: () {
                      _mostrarGestionHorarios(context, negocio);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  _buildOpcionCard(
                    context,
                    icono: Icons.settings,
                    titulo: 'Configuración',
                    descripcion: 'Ajusta los datos de tu negocio',
                    color: const Color(0xFF95A5A6),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🚧 Función próximamente disponible'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildOpcionCard(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                child: Icon(icono, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
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
    final reservas = await cubit.obtenerReservasDelNegocio(negocio.id);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.event_note, color: Color(0xFF3498DB)),
              const SizedBox(width: 12),
              Text('Reservas de ${negocio.nombre}'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
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
                    itemCount: reservas.length,
                    itemBuilder: (context, index) {
                      final reserva = reservas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
                            child: const Icon(Icons.person, color: Color(0xFF3498DB)),
                          ),
                          title: Text(
                            'Cliente ID: ${reserva.clienteId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('📅 ${reserva.fechaHora.day}/${reserva.fechaHora.month}/${reserva.fechaHora.year}'),
                              Text('🕐 ${reserva.fechaHora.hour}:${reserva.fechaHora.minute.toString().padLeft(2, '0')}'),
                              Text('👥 ${reserva.numeroPersonas} personas'),
                              Text('🪑 Mesa ${reserva.mesaId}'),
                              Text(
                                '📊 Estado: ${reserva.estado.name}',
                                style: TextStyle(
                                  color: reserva.estado == EstadoReserva.confirmada
                                      ? Colors.green
                                      : reserva.estado == EstadoReserva.cancelada
                                          ? Colors.red
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: reserva.estado != EstadoReserva.cancelada
                              ? IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    // Aquí podrías agregar funcionalidad para cancelar reserva
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Función de cancelación próximamente'),
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
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
          builder: (context, setState) {
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
                  builder: (context, snapshot) {
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
                      itemBuilder: (context, index) {
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
                                      context: context,
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

                final cubit = context.read<PantallaDuenoCubit>();
                final nuevaMesa = await cubit.agregarMesa(negocio.id, nombre, capacidad);

                Navigator.pop(dialogContext);

                if (nuevaMesa != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${nuevaMesa.nombre} agregada correctamente'),
                      backgroundColor: const Color(0xFF27AE60),
                    ),
                  );
                  _mostrarGestionMesas(context, negocio);
                } else {
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

                final cubit = context.read<PantallaDuenoCubit>();
                final exito = await cubit.actualizarMesa(mesaActualizada);

                Navigator.pop(dialogContext);

                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Mesa actualizada correctamente'),
                      backgroundColor: Color(0xFF27AE60),
                    ),
                  );
                  _mostrarGestionMesas(context, negocio);
                } else {
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
}
