import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../adaptadores/servicio_verificacion_cliente.dart';
import '../../dominio/entidades/reserva.dart';
import '../../service_locator.dart';
import 'mis_reservas_cubit.dart';
import 'mis_reservas_estados_de_cubit.dart';

class MisReservasScreen extends StatelessWidget {
  const MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MisReservasCubit()..cargarReservas(),
      child: const _MisReservasView(),
    );
  }
}

class _MisReservasView extends StatefulWidget {
  const _MisReservasView();

  @override
  State<_MisReservasView> createState() => _MisReservasViewState();
}

class _MisReservasViewState extends State<_MisReservasView> {
  List<Map<String, dynamic>> _reservasCliente = [];
  bool _mostrandoReservasCliente = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/restaurante'),
        ),
      ),
      body: BlocConsumer<MisReservasCubit, MisReservasState>(
        listener: (context, state) {
          if (state is ReservaCancelada) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MisReservasCargando) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is MisReservasConError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE74C3C),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MisReservasCubit>().cargarReservas();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MisReservasExitoso) {
            if (state.reservas.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: const Color(0xFF27AE60).withOpacity(0.5),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No tienes reservas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Realiza tu primera reserva para verla aquí',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F8C8D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => context.go('/disponibilidad'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Hacer una Reserva',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => _mostrarBuscarReservasDialog(context),
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF3498DB),
                        ),
                        label: const Text(
                          '¿Desea ver sus reservas anteriores?',
                          style: TextStyle(
                            color: Color(0xFF3498DB),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Mostrar reservas del cliente si están cargadas
            if (_mostrandoReservasCliente && _reservasCliente.isNotEmpty) {
              return _buildReservasClienteView(context, state.reservas);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.reservas.length,
              itemBuilder: (context, index) {
                final reserva = state.reservas[index];
                return _buildReservaCard(context, reserva);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReservaCard(BuildContext context, Reserva reserva) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

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

    String getEstadoTexto(EstadoReserva estado) {
      switch (estado) {
        case EstadoReserva.confirmada:
          return 'Confirmada';
        case EstadoReserva.pendiente:
          return 'Pendiente';
        case EstadoReserva.cancelada:
          return 'Cancelada';
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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reserva #${reserva.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
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
                  child: Row(
                    children: [
                      Icon(
                        getEstadoIcono(reserva.estado),
                        size: 16,
                        color: getEstadoColor(reserva.estado),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        getEstadoTexto(reserva.estado),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: getEstadoColor(reserva.estado),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Información de la reserva
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              dateFormat.format(reserva.fechaHora),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Hora',
              timeFormat.format(reserva.fechaHora),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.table_restaurant,
              'Mesa',
              'Mesa ${reserva.mesaId}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people,
              'Personas',
              '${reserva.numeroPersonas}',
            ),

            // Botones de acción
            if (reserva.estado != EstadoReserva.cancelada) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDetalleDialog(context, reserva);
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Detalles'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCancelarDialog(context, reserva.id);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 15, color: Color(0xFF7F8C8D)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  void _showDetalleDialog(BuildContext context, Reserva reserva) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Detalles de la Reserva'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${reserva.id}'),
                const SizedBox(height: 8),
                Text('Fecha y Hora: ${dateFormat.format(reserva.fechaHora)}'),
                const SizedBox(height: 8),
                Text('Mesa: ${reserva.mesaId}'),
                const SizedBox(height: 8),
                Text('Número de Personas: ${reserva.numeroPersonas}'),
                const SizedBox(height: 8),
                Text('Cliente ID: ${reserva.clienteId}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  void _showCancelarDialog(BuildContext context, String reservaId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cancelar Reserva'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar esta reserva?\n\n'
              'Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('No, mantener'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<MisReservasCubit>().cancelarReserva(reservaId);
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

  // ============== NUEVO: Buscar reservas anteriores con SMS ==============

  void _mostrarBuscarReservasDialog(BuildContext context) {
    final telefonoController = TextEditingController();
    String? errorTelefono;

    final servicioVerificacion = getIt<ServicioVerificacionCliente>();

    // Verificar si ya hay una sesión activa
    final sesion = servicioVerificacion.obtenerSesionCliente();
    if (sesion != null) {
      // Ya tiene sesión, cargar reservas directamente
      _cargarReservasCliente(context, sesion['telefono']);
      return;
    }

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.search, color: const Color(0xFF3498DB)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Buscar Mis Reservas',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingresa tu número de teléfono para verificar y ver tus reservas anteriores.',
                        style: TextStyle(color: Color(0xFF7F8C8D)),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          hintText: 'Ej: 2614567890',
                          prefixIcon: const Icon(Icons.phone),
                          prefixText: '+54 ',
                          border: const OutlineInputBorder(),
                          errorText: errorTelefono,
                        ),
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
                        final telefono = telefonoController.text.trim();
                        final validacion = servicioVerificacion.validarTelefono(
                          telefono,
                        );

                        if (!validacion['valido']) {
                          setDialogState(() {
                            errorTelefono = validacion['error'];
                          });
                          return;
                        }

                        Navigator.of(dialogContext).pop();
                        _mostrarVerificacionSMSBusqueda(
                          context,
                          validacion['formateado'],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Verificar con SMS'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _mostrarVerificacionSMSBusqueda(BuildContext context, String telefono) {
    final codigoController = TextEditingController();
    bool enviando = true;
    bool verificando = false;
    String? errorCodigo;
    int segundosRestantes = 60;

    final servicioVerificacion = getIt<ServicioVerificacionCliente>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              // Enviar código al abrir el diálogo
              if (enviando) {
                servicioVerificacion.enviarCodigoSMS(
                  telefono: telefono,
                  onCodigoEnviado: (verificationId) {
                    setDialogState(() {
                      enviando = false;
                    });
                    // Iniciar timer para reenvío
                    _iniciarTimerReenvio(
                      setDialogState,
                      () => segundosRestantes,
                      (v) => segundosRestantes = v,
                    );
                  },
                  onError: (error) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al enviar SMS: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onVerificacionAutomatica: (credential) async {
                    Navigator.of(dialogContext).pop();
                    _cargarReservasCliente(context, telefono);
                  },
                );
              }

              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.sms, color: const Color(0xFF3498DB)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Verificación SMS',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (enviando) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Enviando código SMS...'),
                    ] else ...[
                      Text(
                        'Ingresa el código de 6 dígitos enviado a:',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        telefono,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: codigoController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '000000',
                          counterText: '',
                          border: const OutlineInputBorder(),
                          errorText: errorCodigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (segundosRestantes > 0)
                        Text(
                          'Puedes reenviar en $segundosRestantes segundos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              enviando = true;
                              segundosRestantes = 60;
                            });
                          },
                          child: const Text('Reenviar código'),
                        ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                  if (!enviando)
                    ElevatedButton(
                      onPressed:
                          verificando
                              ? null
                              : () async {
                                final codigo = codigoController.text.trim();
                                if (codigo.length != 6) {
                                  setDialogState(() {
                                    errorCodigo =
                                        'Ingresa el código de 6 dígitos';
                                  });
                                  return;
                                }

                                setDialogState(() {
                                  verificando = true;
                                  errorCodigo = null;
                                });

                                try {
                                  final telefonoVerificado =
                                      await servicioVerificacion
                                          .verificarCodigoSMS(codigo: codigo);

                                  Navigator.of(dialogContext).pop();

                                  // Guardar sesión del cliente
                                  servicioVerificacion.guardarSesionCliente(
                                    telefonoVerificado,
                                    '',
                                  );

                                  _cargarReservasCliente(
                                    context,
                                    telefonoVerificado,
                                  );
                                } catch (e) {
                                  setDialogState(() {
                                    verificando = false;
                                    errorCodigo =
                                        'Código incorrecto. Intenta de nuevo.';
                                  });
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                      ),
                      child:
                          verificando
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Verificar'),
                    ),
                ],
              );
            },
          ),
    );
  }

  void _iniciarTimerReenvio(
    void Function(void Function()) setDialogState,
    int Function() getSegundos,
    void Function(int) setSegundos,
  ) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      final actual = getSegundos();
      if (actual > 0) {
        setDialogState(() {
          setSegundos(actual - 1);
        });
        return true;
      }
      return false;
    });
  }

  void _cargarReservasCliente(BuildContext context, String telefono) {
    final servicioVerificacion = getIt<ServicioVerificacionCliente>();
    final reservas = servicioVerificacion.obtenerReservasPorTelefono(telefono);

    setState(() {
      _reservasCliente = reservas;
      _mostrandoReservasCliente = true;
    });

    if (reservas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron reservas asociadas a este teléfono'),
          backgroundColor: Color(0xFFF39C12),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se encontraron ${reservas.length} reserva(s)'),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );
    }
  }

  Widget _buildReservasClienteView(
    BuildContext context,
    List<Reserva> reservasSistema,
  ) {
    return Column(
      children: [
        // Banner indicando que se muestran reservas del cliente
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF3498DB).withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF3498DB)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mostrando tus reservas anteriores',
                  style: TextStyle(
                    color: Color(0xFF3498DB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _mostrandoReservasCliente = false;
                    _reservasCliente = [];
                  });
                },
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
        // Lista de reservas del cliente desde localStorage
        Expanded(
          child:
              _reservasCliente.isEmpty
                  ? const Center(
                    child: Text(
                      'No tienes reservas anteriores',
                      style: TextStyle(fontSize: 18, color: Color(0xFF7F8C8D)),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservasCliente.length,
                    itemBuilder: (context, index) {
                      final reservaMap = _reservasCliente[index];
                      return _buildReservaClienteCard(reservaMap);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildReservaClienteCard(Map<String, dynamic> reserva) {
    final fechaHora =
        DateTime.tryParse(reserva['fechaHora'] ?? '') ?? DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final estado = reserva['estado'] ?? 'pendiente';

    Color getEstadoColor() {
      switch (estado) {
        case 'confirmada':
          return const Color(0xFF27AE60);
        case 'pendiente':
          return const Color(0xFFF39C12);
        case 'cancelada':
          return const Color(0xFFE74C3C);
        default:
          return const Color(0xFF7F8C8D);
      }
    }

    IconData getEstadoIcono() {
      switch (estado) {
        case 'confirmada':
          return Icons.check_circle;
        case 'pendiente':
          return Icons.schedule;
        case 'cancelada':
          return Icons.cancel;
        default:
          return Icons.help;
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reserva #${(reserva['id'] ?? '').toString().substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getEstadoColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(getEstadoIcono(), size: 16, color: getEstadoColor()),
                      const SizedBox(width: 6),
                      Text(
                        estado.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getEstadoColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Info
            _buildInfoRow(
              Icons.person,
              'Nombre',
              reserva['nombreCliente'] ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha',
              dateFormat.format(fechaHora),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Hora',
              timeFormat.format(fechaHora),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.table_restaurant,
              'Mesa',
              'Mesa ${reserva['mesaId'] ?? 'N/A'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.people,
              'Personas',
              '${reserva['numeroPersonas'] ?? 'N/A'}',
            ),
            if (reserva['email'] != null &&
                reserva['email'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email, 'Email', reserva['email']),
            ],
          ],
        ),
      ),
    );
  }
}
