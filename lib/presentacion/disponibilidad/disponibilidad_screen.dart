import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/entidades/mesa.dart';
import 'disponibilidad_cubit.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadScreen extends StatelessWidget {
  const DisponibilidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DisponibilidadCubit()..cargarTodasLasMesas(),
      child: const _DisponibilidadView(),
    );
  }
}

class _DisponibilidadView extends StatefulWidget {
  const _DisponibilidadView();

  @override
  State<_DisponibilidadView> createState() => _DisponibilidadViewState();
}

class _DisponibilidadViewState extends State<_DisponibilidadView> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  int _numeroPersonas = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidad'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Horarios del restaurante
            _buildHorariosCard(),
            const SizedBox(height: 24),

            // Título sección de búsqueda
            const Text(
              'Buscar Mesa Disponible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),

            // Selector de fecha
            _buildSelectorFecha(),
            const SizedBox(height: 16),

            // Selector de hora
            _buildSelectorHora(),
            const SizedBox(height: 16),

            // Selector de número de personas
            _buildSelectorPersonas(),
            const SizedBox(height: 24),

            // Botón buscar
            _buildBotonBuscar(context),
            const SizedBox(height: 24),

            // Resultados
            BlocConsumer<DisponibilidadCubit, DisponibilidadState>(
              listener: (context, state) {
                if (state is ReservaCreada) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'Ver Reservas',
                        textColor: Colors.white,
                        onPressed: () {
                          context.go('/mis-reservas');
                        },
                      ),
                    ),
                  );
                  // Recargar las mesas
                  context.read<DisponibilidadCubit>().cargarTodasLasMesas();
                }
              },
              builder: (context, state) {
                if (state is DisponibilidadLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is DisponibilidadError) {
                  return _buildErrorCard(state.message);
                }

                if (state is DisponibilidadSuccess) {
                  return _buildListadoMesas(
                    state.mesasDisponibles,
                    _fechaSeleccionada,
                    _horaSeleccionada,
                    _numeroPersonas,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF3498DB),
          width: 2,
        ),
      ),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3498DB).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Horarios de Atención',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF3498DB).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHorarioItem('Miércoles a Viernes', '12:00 - 15:30 / 20:00 - 23:30'),
              const SizedBox(height: 14),
              _buildHorarioItem('Sábados', '12:00 - 16:00 / 20:00 - 00:00'),
              const SizedBox(height: 14),
              _buildHorarioItem('Domingos', '12:00 - 16:00'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE74C3C).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block,
                      color: const Color(0xFFE74C3C),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Cerrado: Lunes y Martes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE74C3C),
                        fontStyle: FontStyle.italic,
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

  Widget _buildHorarioItem(String dia, String horario) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF3498DB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dia,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          Text(
            horario,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF34495E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorFecha() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.calendar_today,
          color: Color(0xFF3498DB),
        ),
        title: const Text(
          'Fecha',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _fechaSeleccionada == null
              ? 'Seleccionar fecha'
              : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final fecha = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 90)),
          );
          if (fecha != null) {
            setState(() {
              _fechaSeleccionada = fecha;
            });
          }
        },
      ),
    );
  }

  Widget _buildSelectorHora() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.access_time,
          color: Color(0xFF3498DB),
        ),
        title: const Text(
          'Hora',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _horaSeleccionada == null
              ? 'Seleccionar hora'
              : '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final hora = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (hora != null) {
            setState(() {
              _horaSeleccionada = hora;
            });
          }
        },
      ),
    );
  }

  Widget _buildSelectorPersonas() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.people,
              color: Color(0xFF3498DB),
            ),
            const SizedBox(width: 16),
            const Text(
              'Número de Personas:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFF3498DB),
              onPressed: () {
                if (_numeroPersonas > 1) {
                  setState(() {
                    _numeroPersonas--;
                  });
                }
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_numeroPersonas',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFF3498DB),
              onPressed: () {
                if (_numeroPersonas < 20) {
                  setState(() {
                    _numeroPersonas++;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonBuscar(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_fechaSeleccionada == null || _horaSeleccionada == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor selecciona fecha y hora'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          final fechaHora = DateTime(
            _fechaSeleccionada!.year,
            _fechaSeleccionada!.month,
            _fechaSeleccionada!.day,
            _horaSeleccionada!.hour,
            _horaSeleccionada!.minute,
          );

          context.read<DisponibilidadCubit>().buscarMesasDisponibles(
                _fechaSeleccionada!,
                fechaHora,
                _numeroPersonas,
              );
        },
        icon: const Icon(Icons.search, size: 24),
        label: const Text(
          'Buscar Mesas Disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListadoMesas(
    List<Mesa> mesas,
    DateTime? fecha,
    TimeOfDay? hora,
    int numeroPersonas,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mesas Disponibles',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        ...mesas.map((mesa) => _buildMesaCard(mesa, fecha, hora, numeroPersonas)),
      ],
    );
  }

  Widget _buildMesaCard(
    Mesa mesa,
    DateTime? fecha,
    TimeOfDay? hora,
    int numeroPersonas,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
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
                color: const Color(0xFF27AE60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.table_restaurant,
                color: Color(0xFF27AE60),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mesa.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 16,
                        color: Color(0xFF7F8C8D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Capacidad: ${mesa.capacidad} personas',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (fecha == null || hora == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona fecha y hora para reservar'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                // Mostrar diálogo de confirmación
                _showConfirmarReservaDialog(
                  context,
                  mesa,
                  fecha,
                  hora,
                  numeroPersonas,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Reservar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmarReservaDialog(
    BuildContext context,
    Mesa mesa,
    DateTime fecha,
    TimeOfDay hora,
    int numeroPersonas,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesa: ${mesa.nombre}'),
            const SizedBox(height: 8),
            Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
            const SizedBox(height: 8),
            Text('Hora: ${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            Text('Personas: $numeroPersonas'),
            const SizedBox(height: 16),
            const Text(
              '¿Deseas confirmar esta reserva?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              
              // Crear fecha y hora combinadas
              final fechaHora = DateTime(
                fecha.year,
                fecha.month,
                fecha.day,
                hora.hour,
                hora.minute,
              );
              
              // Cliente ID por defecto (en producción vendría del usuario autenticado)
              const clienteId = 'cliente_123';
              
              context.read<DisponibilidadCubit>().crearReserva(
                clienteId,
                mesa.id,
                fecha,
                fechaHora,
                numeroPersonas,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
