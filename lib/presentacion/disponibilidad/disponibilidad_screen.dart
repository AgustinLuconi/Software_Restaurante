import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../adaptadores/servicio_verificacion_cliente.dart';
import '../../dominio/entidades/mesa.dart';
import '../../service_locator.dart';
import '../widgets_comunes/constantes_diseno.dart';
import '../widgets_comunes/icono_circular.dart';
import '../widgets_comunes/panel_informativo.dart';
import 'disponibilidad_cubit.dart';
import 'disponibilidad_estados_de_cubit.dart';

class DisponibilidadScreen extends StatelessWidget {
  final String? negocioId;

  const DisponibilidadScreen({super.key, this.negocioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DisponibilidadCubit()..cargarTodasLasMesas(negocioId),
      child: _DisponibilidadView(negocioId: negocioId),
    );
  }
}

class _DisponibilidadView extends StatefulWidget {
  final String? negocioId;
  const _DisponibilidadView({this.negocioId});

  @override
  State<_DisponibilidadView> createState() => _DisponibilidadViewState();
}

class _DisponibilidadViewState extends State<_DisponibilidadView> {
  DateTime? _fechaSeleccionada;
  String?
  _intervaloSeleccionado; // Cambio: ahora guardamos el intervalo como String
  int _numeroPersonas = 2;
  String? _zonaSeleccionada; // Nueva variable para la zona (String)
  Future<List<String>>? _intervalosFuture; // Cache del Future de intervalos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Disponibilidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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

            // Info sobre intervalos de reserva (dinámico)
            BlocBuilder<DisponibilidadCubit, DisponibilidadState>(
              builder: (context, state) {
                int duracion = 60;
                if (state is DisponibilidadExitosa) {
                  duracion = state.duracionPromedioMinutos;
                } else if (state is MesaEncontrada) {
                  duracion = state.duracionPromedioMinutos;
                }
                return _buildInfoIntervalosCard(duracion);
              },
            ),
            const SizedBox(height: 24),

            // Título sección de búsqueda
            Text(
              'Buscar Mesa Disponible',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                          context.push('/mis-reservas', extra: widget.negocioId);
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

                if (state is ProcesandoReserva) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Procesando reserva...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
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
    return BlocBuilder<DisponibilidadCubit, DisponibilidadState>(
      builder: (context, state) {
        final horarios =
            state is DisponibilidadExitosa ? state.horariosServicio : null;

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF3498DB), width: 2),
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
                  // Horarios dinámicos
                  ..._buildHorariosItems(horarios),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye la lista de items de horario a partir del mapa
  List<Widget> _buildHorariosItems(Map<String, String>? horarios) {
    if (horarios == null || horarios.isEmpty) {
      return [
        const Text(
          'Horarios no disponibles',
          style: TextStyle(color: Colors.grey),
        ),
      ];
    }

    final List<Widget> items = [];
    final diasCerrados = <String>[];

    horarios.forEach((dia, horario) {
      if (horario.toLowerCase() == 'cerrado') {
        diasCerrados.add(dia);
      } else {
        if (items.isNotEmpty) {
          items.add(const SizedBox(height: 14));
        }
        items.add(_buildHorarioItem(dia, horario));
      }
    });

    // Mostrar días cerrados al final
    if (diasCerrados.isNotEmpty) {
      items.add(const SizedBox(height: 16));
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[400]!, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, color: Colors.grey[700], size: 18),
              const SizedBox(width: 8),
              Text(
                'Cerrado: ${diasCerrados.join(', ')}',
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
      );
    }

    return items;
  }

  /// Widget para la tarjeta de info de intervalos (dinámico)
  Widget _buildInfoIntervalosCard(int duracionMinutos) {
    return PanelInformativo(
      icon: Icons.schedule,
      titulo: 'Reservas por intervalos de $duracionMinutos minutos',
      descripcion:
          'Cada mesa se reserva por $duracionMinutos minutos. Si una mesa está reservada, no estará disponible en ese horario.',
      color: AppColores.info,
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
    return BlocBuilder<DisponibilidadCubit, DisponibilidadState>(
      builder: (context, state) {
        // Obtener zonas
        Set<String> zonas = {};
        if (state is DisponibilidadExitosa) {
           // Obtener TODAS las zonas registradas en el negocio para que aparezcan incluso
           // si aún no tienen mesas asignadas.
           if (state.negocio != null && state.negocio!.zonas.isNotEmpty) {
             zonas = state.negocio!.zonas.toSet();
           } else {
             // Fallback si por alguna razón no tenemos el negocio
             zonas = state.mesasDisponibles.map((m) => m.zona).toSet();
           }
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const IconoCircular(
                  icon: Icons.location_on,
                  color: Color(0xFF9B59B6),
                  size: 24,
                  padding: 8,
                  borderRadius: 8,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zona',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      zonas.isEmpty
                          ? const Text(
                              'Cargando zonas...',
                              style: TextStyle(color: Colors.grey),
                            )
                          : DropdownButton<String>(
                              value: _zonaSeleccionada,
                              hint: const Text('Seleccionar zona'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              dropdownColor: Colors.white,
                              focusColor: Colors.transparent,
                              items: zonas.map((zona) {
                                return DropdownMenuItem<String>(
                                  value: zona,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _obtenerIconoZona(zona),
                                        size: 20,
                                        color: _obtenerColorZona(zona),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(zona),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (zona) {
                                setState(() {
                                  _zonaSeleccionada = zona;
                                });
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _obtenerIconoZona(String zona) {
    final z = zona.toLowerCase();
    if (z.contains('terraza')) return Icons.deck;
    if (z.contains('salon') || z.contains('salón')) return Icons.chair;
    if (z.contains('jardin') || z.contains('jardín')) return Icons.grass;
    if (z.contains('bar')) return Icons.local_bar;
    if (z.contains('vip')) return Icons.star;
    return Icons.table_restaurant;
  }

  Color _obtenerColorZona(String zona) {
    final z = zona.toLowerCase();
    if (z.contains('terraza')) return const Color(0xFFE67E22);
    if (z.contains('salon') || z.contains('salón')) return const Color(0xFF3498DB);
    if (z.contains('jardin') || z.contains('jardín')) return const Color(0xFF27AE60);
    if (z.contains('bar')) return const Color(0xFF9B59B6);
    if (z.contains('vip')) return const Color(0xFFF1C40F);
    return Colors.grey;
  }


  Widget _buildSelectorFecha() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
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
              // Actualizar el cache del Future de intervalos
              _intervalosFuture = context
                  .read<DisponibilidadCubit>()
                  .obtenerIntervalosHorarioNegocio(fecha);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            BlocBuilder<DisponibilidadCubit, DisponibilidadState>(
              builder: (context, state) {
                int duracion = 60;
                if (state is DisponibilidadExitosa) {
                  duracion = state.duracionPromedioMinutos;
                } else if (state is MesaEncontrada) {
                  duracion = state.duracionPromedioMinutos;
                }

                return Text(
                  'Selecciona un horario (intervalos de $duracion minutos)',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                );
              },
            ),
            const SizedBox(height: 16),
            // Mostrar lista de horarios (usando Future cacheado para evitar animaciones)
            FutureBuilder<List<String>>(
              future: _intervalosFuture,
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  );
                }

                final intervalos = snapshot.data!;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      intervalos.map((intervalo) {
                        final seleccionado =
                            _intervaloSeleccionado == intervalo;

                        return ChoiceChip(
                          label: Text(intervalo),
                          selected: seleccionado,
                          onSelected: (selected) {
                            setState(() {
                              _intervaloSeleccionado =
                                  selected ? intervalo : null;
                            });
                          },
                          selectedColor: const Color(0xFF27AE60),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: seleccionado ? Colors.white : Colors.black87,
                            fontWeight:
                                seleccionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.people, color: Color(0xFF3498DB)),
            const SizedBox(width: 16),
            const Text(
              'Número de Personas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    String zona,
    DateTime? fecha,
    String? intervaloSeleccionado,
    int numeroPersonas,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _obtenerColorZona(zona), width: 2),
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
                        'Zona: $zona',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                      _buildItemResumen(
                        Icons.calendar_today,
                        'Fecha',
                        fecha != null
                            ? '${fecha.day}/${fecha.month}/${fecha.year}'
                            : '-',
                      ),
                      const SizedBox(height: 8),
                      _buildItemResumen(
                        Icons.access_time,
                        'Horario',
                        intervaloSeleccionado ?? '-',
                      ),
                      const SizedBox(height: 8),
                      _buildItemResumen(
                        Icons.people,
                        'Personas',
                        '$numeroPersonas',
                      ),
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
          style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
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
    final esErrorHorario =
        message.toLowerCase().contains('horario') ||
        message.toLowerCase().contains('cerrado');

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
                color:
                    esErrorHorario
                        ? Colors.orange.shade100
                        : Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                esErrorHorario ? Icons.access_time_filled : Icons.error_outline,
                color:
                    esErrorHorario
                        ? Colors.orange.shade700
                        : Colors.red.shade700,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              esErrorHorario ? 'Horario No Disponible' : 'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    esErrorHorario
                        ? Colors.orange.shade900
                        : Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color:
                    esErrorHorario
                        ? Colors.orange.shade900
                        : Colors.red.shade900,
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
    String? intervaloSeleccionado,
    int numeroPersonas,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mesas del Restaurante',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        ...mesas.map(
          (mesa) => _buildMesaCard(
            mesa,
            fecha,
            intervaloSeleccionado,
            numeroPersonas,
          ),
        ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      content: Text(
                        'Por favor selecciona fecha y horario para reservar',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Validar capacidad
                if (!mesa.puedeAcomodar(numeroPersonas)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Esta mesa no es adecuada para $numeroPersonas personas',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Mostrar diálogo de confirmación
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
    // Controladores para los campos
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final servicioVerificacion = getIt<ServicioVerificacionCliente>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Fecha',
                      '${fecha.day}/${fecha.month}/${fecha.year}',
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Horario',
                      intervaloSeleccionado,
                    ),
                    _buildInfoRow(Icons.people, 'Personas', '$numeroPersonas'),
                    const Divider(height: 24),
                    const Text(
                      'Para confirmar tu reserva, necesitamos:',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
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

                    // Campo de teléfono (para SMS)
                    TextFormField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono *',
                        prefixIcon: Icon(Icons.phone_android),
                        border: OutlineInputBorder(),
                        hintText: '+54 9 11 1234-5678',
                        helperText: 'Recibirás un código SMS para confirmar',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu teléfono';
                        }
                        final validacion = servicioVerificacion.validarTelefono(
                          value,
                        );
                        if (validacion['valido'] != true) {
                          return validacion['error'];
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de email (para detalles)
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: 'correo@ejemplo.com',
                        helperText: 'Recibirás los detalles de tu reserva',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Ingresa un email válido';
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.sms,
                                size: 20,
                                color: Color(0xFF3498DB),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: const Text(
                                  '📱 SMS con código de verificación',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                size: 20,
                                color: Color(0xFF3498DB),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: const Text(
                                  '📧 Email con detalles de la reserva',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2C3E50),
                                  ),
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
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final telefono = telefonoController.text.trim();
                    final email = emailController.text.trim();
                    final nombre = nombreController.text.trim();

                    Navigator.of(dialogContext).pop();

                    // Mostrar diálogo de verificación SMS
                    _showVerificacionSMSDialog(
                      context,
                      telefono: telefono,
                      email: email,
                      nombre: nombre,
                      mesa: mesa,
                      fecha: fecha,
                      intervaloSeleccionado: intervaloSeleccionado,
                      numeroPersonas: numeroPersonas,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Enviar Código SMS'),
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
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

  void _showVerificacionSMSDialog(
    BuildContext context, {
    required String telefono,
    required String email,
    required String nombre,
    required Mesa mesa,
    required DateTime fecha,
    required String intervaloSeleccionado,
    required int numeroPersonas,
  }) {
    final servicioVerificacion = getIt<ServicioVerificacionCliente>();
    final codigoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Extraer la hora del intervalo (ej: "08:00 - 09:00" -> 8)
    final partes = intervaloSeleccionado.split(' - ');
    final horaInicio = int.parse(partes[0].split(':')[0]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;
        bool codigoEnviado = false;
        String? errorMessage;
        int tiempoRestante = 0;

        return StatefulBuilder(
          builder: (dialogBuildContext, setState) {
            // Timer de reenvío
            void iniciarTimer() {
              tiempoRestante = 60;
              Future.doWhile(() async {
                await Future.delayed(const Duration(seconds: 1));
                if (tiempoRestante > 0 && dialogBuildContext.mounted) {
                  setState(() => tiempoRestante--);
                  return true;
                }
                return false;
              });
            }

            Future<void> enviarCodigo() async {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              await servicioVerificacion.enviarCodigoSMS(
                telefono: telefono,
                onCodigoEnviado: (mensaje) {
                  setState(() {
                    isLoading = false;
                    codigoEnviado = true;
                  });
                  iniciarTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📱 $mensaje a $telefono'),
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
                onVerificacionAutomatica: (telefonoVerificado) async {
                  // Verificación automática en Android
                  Navigator.of(dialogContext).pop();
                  await _crearReservaVerificada(
                    context, // usar el context externo (del widget)
                    telefono: telefonoVerificado,
                    email: email,
                    nombre: nombre,
                    mesa: mesa,
                    fecha: fecha,
                    horaInicio: horaInicio,
                    numeroPersonas: numeroPersonas,
                    intervaloSeleccionado: intervaloSeleccionado,
                  );
                },
              );
            }

            Future<void> verificarCodigo() async {
              if (!formKey.currentState!.validate()) return;

              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                final telefonoVerificado = await servicioVerificacion
                    .verificarCodigoSMS(codigo: codigoController.text.trim());

                Navigator.of(dialogContext).pop();

                // Usar el context externo (del widget, no del diálogo)
                if (context.mounted) {
                  await _crearReservaVerificada(
                    context,
                    telefono: telefonoVerificado,
                    email: email,
                    nombre: nombre,
                    mesa: mesa,
                    fecha: fecha,
                    horaInicio: horaInicio,
                    numeroPersonas: numeroPersonas,
                    intervaloSeleccionado: intervaloSeleccionado,
                  );
                }
              } catch (e) {
                if (dialogBuildContext.mounted) {
                  setState(() {
                    isLoading = false;
                    errorMessage = e.toString().replaceAll('Exception: ', '');
                  });
                }
              }
            }

            // Si no se ha enviado el código aún, enviarlo automáticamente
            if (!codigoEnviado && !isLoading && errorMessage == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                enviarCodigo();
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    codigoEnviado ? Icons.sms : Icons.phone_android,
                    color: const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 12),
                  Text(codigoEnviado ? 'Verificar Código' : 'Enviando SMS...'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            Icon(
                              codigoEnviado ? Icons.sms : Icons.send_to_mobile,
                              size: 48,
                              color: const Color(0xFF27AE60),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              codigoEnviado
                                  ? 'Código SMS enviado a:'
                                  : 'Enviando código a:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              telefono,
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
                      if (isLoading && !codigoEnviado) ...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        const Text('Enviando código SMS...'),
                      ],
                      if (codigoEnviado) ...[
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
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Limpiar reCAPTCHA al cancelar
                    servicioVerificacion.limpiarRecaptcha();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                if (codigoEnviado)
                  ElevatedButton(
                    onPressed: isLoading ? null : verificarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                            : const Text('Verificar y Confirmar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _crearReservaVerificada(
    BuildContext context, {
    required String telefono,
    required String email,
    required String nombre,
    required Mesa mesa,
    required DateTime fecha,
    required int horaInicio,
    required int numeroPersonas,
    required String intervaloSeleccionado,
  }) async {
    final servicioVerificacion = getIt<ServicioVerificacionCliente>();

    // Crear fecha y hora combinadas
    final fechaHora = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      horaInicio,
      0,
    );

    // Normalizar teléfono
    final telefonoNormalizado = servicioVerificacion.normalizarTelefono(
      telefono,
    );

    // Crear reserva usando el método correcto que NO requiere verificación adicional
    // ya que Firebase SMS ya verificó el teléfono
    await context.read<DisponibilidadCubit>().crearReservaVerificadaPorSMS(
      emailCliente: email,
      telefonoVerificado: telefonoNormalizado,
      nombreCliente: nombre,
      mesaId: mesa.id,
      fecha: fecha,
      hora: fechaHora,
      numeroPersonas: numeroPersonas,
    );

    // Guardar reserva en localStorage con teléfono y email
    final reservaLocal = {
      'id': 'reserva_${DateTime.now().millisecondsSinceEpoch}',
      'negocioId': mesa.negocioId,
      'mesaId': mesa.id,
      'nombreMesa': mesa.nombre,
      'zona': mesa.zona.toString(),
      'fecha': fecha.toIso8601String(),
      'horario': intervaloSeleccionado,
      'personas': numeroPersonas,
      'clienteNombre': nombre,
      'clienteEmail': email,
      'clienteTelefono': telefonoNormalizado,
      'estado': 'confirmada',
      'verificada': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    servicioVerificacion.guardarReserva(reservaLocal);

    // Guardar sesión del cliente
    servicioVerificacion.guardarSesionCliente(telefono, email);

    print('📋 Reserva guardada localmente: ${mesa.nombre} - $intervaloSeleccionado - $numeroPersonas personas');
  }
}
