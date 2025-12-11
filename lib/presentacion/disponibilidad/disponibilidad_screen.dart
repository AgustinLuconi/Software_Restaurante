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
  String? _intervaloSeleccionado; // Cambio: ahora guardamos el intervalo como String
  int _numeroPersonas = 2;
  ZonaMesa? _zonaSeleccionada; // Nueva variable para la zona

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Disponibilidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/restaurante'),
        ),
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Horarios del restaurante
            _buildHorariosCard(),
            const SizedBox(height: 16),
            
            // Info sobre intervalos de reserva
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Color(0xFF3498DB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reservas por intervalos de 1 hora',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cada mesa se reserva por 1 hora. Si una mesa está reservada, no estará disponible en ese horario.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título sección de búsqueda
            Text(
              'Buscar Mesa Disponible',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Selector de zona (NUEVO)
            _buildSelectorZona(),
            const SizedBox(height: 16),

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
                      content: Text(state.mensaje),
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
                if (state is DisponibilidadCargando) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is DisponibilidadConError) {
                  return _buildErrorCard(state.mensaje);
                }

                // Nuevo estado: Mesa encontrada automáticamente en zona
                if (state is MesaEncontrada) {
                  return _buildTarjetaMesaEncontrada(
                    state.mesa,
                    state.zona,
                    _fechaSeleccionada,
                    _intervaloSeleccionado,
                    _numeroPersonas,
                  );
                }

                if (state is DisponibilidadExitosa) {
                  return _buildListadoMesas(
                    state.mesasDisponibles,
                    _fechaSeleccionada,
                    _intervaloSeleccionado,
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
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy,
                      color: Colors.grey[700],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cerrado: Lunes y Martes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
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

  Widget _buildSelectorZona() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF9B59B6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zona',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<List<ZonaMesa>>(
                    future: context.read<DisponibilidadCubit>().obtenerZonasDisponibles(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'Cargando zonas...',
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      final zonas = snapshot.data!;

                      return DropdownButton<ZonaMesa>(
                        value: _zonaSeleccionada,
                        hint: const Text('Seleccionar zona'),
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        dropdownColor: Colors.white,
                        focusColor: Colors.transparent,
                        items: zonas.map((zona) {
                          return DropdownMenuItem<ZonaMesa>(
                            value: zona,
                            child: Row(
                              children: [
                                Icon(
                                  _obtenerIconoZona(zona),
                                  size: 20,
                                  color: _obtenerColorZona(zona),
                                ),
                                const SizedBox(width: 8),
                                Text(zona.nombre),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (zona) {
                          setState(() {
                            _zonaSeleccionada = zona;
                          });
                        },
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

  IconData _obtenerIconoZona(ZonaMesa zona) {
    switch (zona) {
      case ZonaMesa.terraza:
        return Icons.deck;
      case ZonaMesa.salon:
        return Icons.chair;
      case ZonaMesa.jardin:
        return Icons.grass;
      case ZonaMesa.barraBar:
        return Icons.local_bar;
      case ZonaMesa.vip:
        return Icons.star;
    }
  }

  Color _obtenerColorZona(ZonaMesa zona) {
    switch (zona) {
      case ZonaMesa.terraza:
        return const Color(0xFFE67E22);
      case ZonaMesa.salon:
        return const Color(0xFF3498DB);
      case ZonaMesa.jardin:
        return const Color(0xFF27AE60);
      case ZonaMesa.barraBar:
        return const Color(0xFF9B59B6);
      case ZonaMesa.vip:
        return const Color(0xFFF1C40F);
    }
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
            lastDate: DateTime.now().add(const Duration(days: 14)),
          );
          if (fecha != null) {
            setState(() {
              _fechaSeleccionada = fecha;
              // Limpiar intervalo seleccionado al cambiar de fecha
              _intervaloSeleccionado = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildSelectorHora() {
    // Si no hay fecha seleccionada, mostrar mensaje
    if (_fechaSeleccionada == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.access_time, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Selecciona primero una fecha',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF3498DB)),
                const SizedBox(width: 12),
                const Text(
                  'Horarios Disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona un horario (intervalos de 1 hora)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            // Mostrar lista de horarios
            FutureBuilder<List<String>>(
              future: context.read<DisponibilidadCubit>().obtenerIntervalosHorarioNegocio(_fechaSeleccionada!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No hay horarios disponibles para esta fecha',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                final intervalos = snapshot.data!;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: intervalos.map((intervalo) {
                    final seleccionado = _intervaloSeleccionado == intervalo;
                    
                    return ChoiceChip(
                      label: Text(intervalo),
                      selected: seleccionado,
                      onSelected: (selected) {
                        setState(() {
                          _intervaloSeleccionado = selected ? intervalo : null;
                        });
                      },
                      selectedColor: const Color(0xFF27AE60),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: seleccionado ? Colors.white : Colors.black87,
                        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
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
          // Validar que todos los campos estén completos
          if (_zonaSeleccionada == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor selecciona una zona'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (_fechaSeleccionada == null || _intervaloSeleccionado == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor selecciona fecha y horario'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Extraer la hora del intervalo seleccionado (ej: "08:00 - 09:00" -> 8)
          final partes = _intervaloSeleccionado!.split(' - ');
          final horaInicio = int.parse(partes[0].split(':')[0]);

          final fechaHora = DateTime(
            _fechaSeleccionada!.year,
            _fechaSeleccionada!.month,
            _fechaSeleccionada!.day,
            horaInicio,
            0,
          );

          // Buscar mesa automáticamente en la zona seleccionada
          context.read<DisponibilidadCubit>().buscarMesaEnZona(
            zona: _zonaSeleccionada!,
            fecha: _fechaSeleccionada!,
            hora: fechaHora,
            numeroPersonas: _numeroPersonas,
          );
        },
        icon: const Icon(Icons.search, size: 24),
        label: const Text(
          'Buscar Mesa Disponible',
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

  /// Widget que muestra la mesa encontrada automáticamente en la zona
  Widget _buildTarjetaMesaEncontrada(
    Mesa mesa,
    ZonaMesa zona,
    DateTime? fecha,
    String? intervaloSeleccionado,
    int numeroPersonas,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _obtenerColorZona(zona),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header con información de la zona
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _obtenerColorZona(zona).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _obtenerColorZona(zona).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _obtenerIconoZona(zona),
                    color: _obtenerColorZona(zona),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Mesa encontrada!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                      Text(
                        'Zona: ${zona.nombre}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF27AE60),
                  size: 32,
                ),
              ],
            ),
          ),
          // Información de la mesa
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 16, color: Color(0xFF7F8C8D)),
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
                  ],
                ),
                const SizedBox(height: 20),
                // Resumen de la reserva
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildItemResumen(Icons.calendar_today, 'Fecha', 
                        fecha != null ? '${fecha.day}/${fecha.month}/${fecha.year}' : '-'),
                      const SizedBox(height: 8),
                      _buildItemResumen(Icons.access_time, 'Horario', 
                        intervaloSeleccionado ?? '-'),
                      const SizedBox(height: 8),
                      _buildItemResumen(Icons.people, 'Personas', 
                        '$numeroPersonas'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Botón para reservar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (fecha != null && intervaloSeleccionado != null) {
                        _showConfirmarReservaDialog(
                          context,
                          mesa,
                          fecha,
                          intervaloSeleccionado,
                          numeroPersonas,
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text(
                      'Reservar Esta Mesa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemResumen(IconData icono, String etiqueta, String valor) {
    return Row(
      children: [
        Icon(icono, size: 18, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 8),
        Text(
          '$etiqueta: ',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    // Determinar si es un error de horario cerrado
    final esErrorHorario = message.contains('horario') || 
                           message.contains('cerrado') || 
                           message.contains('Lunes') ||
                           message.contains('Martes') ||
                           message.contains('Miércoles') ||
                           message.contains('Jueves') ||
                           message.contains('Viernes') ||
                           message.contains('Sábado') ||
                           message.contains('Domingo');
    
    return Card(
      elevation: 3,
      color: esErrorHorario ? Colors.orange.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: esErrorHorario ? Colors.orange.shade300 : Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esErrorHorario 
                    ? Colors.orange.shade100 
                    : Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                esErrorHorario ? Icons.access_time_filled : Icons.error_outline,
                color: esErrorHorario ? Colors.orange.shade700 : Colors.red.shade700,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              esErrorHorario ? 'Horario No Disponible' : 'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: esErrorHorario ? Colors.orange.shade900 : Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: esErrorHorario ? Colors.orange.shade900 : Colors.red.shade900,
              ),
            ),
            if (esErrorHorario) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Por favor, selecciona un horario dentro del horario de atención del restaurante.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
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
    );
  }

  Widget _buildListadoMesas(
    List<Mesa> mesas,
    DateTime? fecha,
    String? intervaloSeleccionado,
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
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...mesas.map((mesa) => _buildMesaCard(mesa, fecha, intervaloSeleccionado, numeroPersonas)),
      ],
    );
  }

  Widget _buildMesaCard(
    Mesa mesa,
    DateTime? fecha,
    String? intervaloSeleccionado,
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
                if (fecha == null || intervaloSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona fecha y horario para reservar'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                // VALIDAR CAPACIDAD ANTES de continuar
                if (!mesa.puedeAcomodar(numeroPersonas)) {
                  // Determinar el mensaje específico
                  String mensaje;
                  if (mesa.capacidad < numeroPersonas) {
                    mensaje = '❌ Esta mesa tiene capacidad para ${mesa.capacidad} persona${mesa.capacidad > 1 ? 's' : ''}, '
                        'pero has seleccionado ${numeroPersonas} personas.\n\n'
                        'Por favor, elige una mesa con mayor capacidad.';
                  } else {
                    final diferencia = mesa.capacidad - numeroPersonas;
                    mensaje = '❌ Esta mesa tiene capacidad para ${mesa.capacidad} personas, '
                        'pero solo necesitas ${numeroPersonas}.\n\n'
                        'La diferencia es de $diferencia lugar${diferencia > 1 ? 'es' : ''}. '
                        'Por favor, selecciona una mesa más adecuada (máximo +3 lugares de diferencia).';
                  }
                  
                  // Mostrar diálogo de error
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.red.shade50,
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Capacidad No Adecuada',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mensaje,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selecciona "Buscar Mesas" nuevamente para ver opciones más adecuadas.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  );
                  return; // No continuar con la reserva
                }
                
                // Si la validación pasa, mostrar diálogo de confirmación
                _showConfirmarReservaDialog(
                  context,
                  mesa,
                  fecha,
                  intervaloSeleccionado,
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
    String intervaloSeleccionado,
    int numeroPersonas,
  ) {
    // Primer diálogo: Solicitar contacto y nombre
    final contactoController = TextEditingController();
    final nombreController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.contact_mail, color: Color(0xFF3498DB)),
            const SizedBox(width: 12),
            const Text('Datos de Contacto'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de tu reserva:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.table_restaurant, 'Mesa', mesa.nombre),
                _buildInfoRow(Icons.calendar_today, 'Fecha', '${fecha.day}/${fecha.month}/${fecha.year}'),
                _buildInfoRow(Icons.access_time, 'Horario', intervaloSeleccionado),
                _buildInfoRow(Icons.people, 'Personas', '$numeroPersonas'),
                const Divider(height: 24),
                const Text(
                  'Para confirmar tu reserva, necesitamos:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo de nombre
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre *',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Juan Pérez',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de contacto (email o teléfono)
                TextFormField(
                  controller: contactoController,
                  decoration: const InputDecoration(
                    labelText: 'Email o Teléfono *',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: correo@mail.com o +54 261 123-4567',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu email o teléfono';
                    }
                    // Validación básica
                    final esEmail = value.contains('@');
                    final esTelefono = value.replaceAll(RegExp(r'[^\d]'), '').length >= 8;
                    
                    if (!esEmail && !esTelefono) {
                      return 'Ingresa un email o teléfono válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Color(0xFF3498DB)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'Te enviaremos un código de verificación para confirmar tu reserva',
                          style: TextStyle(fontSize: 12, color: Color(0xFF2C3E50)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final contacto = contactoController.text.trim();
                final nombre = nombreController.text.trim();
                
                Navigator.of(dialogContext).pop();
                
                // Enviar código de verificación
                await context.read<DisponibilidadCubit>().enviarCodigoVerificacion(contacto);
                
                // Mostrar diálogo para ingresar el código
                _showVerificacionDialog(context, contacto, nombre, mesa, fecha, intervaloSeleccionado, numeroPersonas);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Enviar Código'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF7F8C8D)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerificacionDialog(
    BuildContext context,
    String contacto,
    String nombre,
    Mesa mesa,
    DateTime fecha,
    String intervaloSeleccionado,
    int numeroPersonas,
  ) {
    // Extraer la hora del intervalo (ej: "08:00 - 09:00" -> 8)
    final partes = intervaloSeleccionado.split(' - ');
    final horaInicio = int.parse(partes[0].split(':')[0]);
    
    final codigoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_user, color: Color(0xFF27AE60)),
            const SizedBox(width: 12),
            const Text('Verificación'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF27AE60).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.mark_email_read,
                      size: 48,
                      color: Color(0xFF27AE60),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Código enviado a:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contacto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ingresa el código de 6 dígitos:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  counterText: '',
                  hintText: '000000',
                  prefixIcon: const Icon(Icons.pin),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Ingresa los 6 dígitos';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Solo números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Color(0xFFE67E22)),
                  const SizedBox(width: 6),
                  Text(
                    'El código expira en 10 minutos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Reenviar código
              await context.read<DisponibilidadCubit>().enviarCodigoVerificacion(contacto);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✉️ Código reenviado'),
                  backgroundColor: Color(0xFF3498DB),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reenviar Código'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final codigo = codigoController.text.trim();
                
                Navigator.of(dialogContext).pop();
                
                // Crear fecha y hora combinadas
                final fechaHora = DateTime(
                  fecha.year,
                  fecha.month,
                  fecha.day,
                  horaInicio,
                  0,
                );
                
                // Crear reserva con verificación
                await context.read<DisponibilidadCubit>().crearReservaConVerificacion(
                  contacto: contacto,
                  codigo: codigo,
                  nombreCliente: nombre,
                  mesaId: mesa.id,
                  fecha: fecha,
                  hora: fechaHora,
                  numeroPersonas: numeroPersonas,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Verificar y Confirmar'),
          ),
        ],
      ),
    );
  }
}
