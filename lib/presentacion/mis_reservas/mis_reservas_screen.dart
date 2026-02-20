import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../adaptadores/servicio_verificacion_cliente.dart';
import '../../dominio/entidades/reserva.dart';
import '../../dominio/repositorios/mesa_repositorio.dart';
import '../../service_locator.dart';
import '../widgets_comunes/badge_estado.dart';
import 'mis_reservas_cubit.dart';
import 'mis_reservas_estados_de_cubit.dart';

class MisReservasScreen extends StatelessWidget {
  final String? negocioId;

  const MisReservasScreen({super.key, this.negocioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MisReservasCubit(),
      child: _MisReservasView(negocioId: negocioId),
    );
  }
}

class _MisReservasView extends StatefulWidget {
  final String? negocioId;
  const _MisReservasView({this.negocioId});

  @override
  State<_MisReservasView> createState() => _MisReservasViewState();
}

class _MisReservasViewState extends State<_MisReservasView> {
  bool _verificado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _verificado
          ? _buildReservasView()
          : _buildVerificacionInicial(),
    );
  }

  // ============================================================
  // PANTALLA INICIAL: Verificación con SMS
  // ============================================================

  Widget _buildVerificacionInicial() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note,
                size: 50,
                color: Color(0xFF27AE60),
              ),
            ),
            const SizedBox(height: 32),

            // Título
            const Text(
              '¿Querés ver tus reservas?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtítulo
            const Text(
              'Verificá tu identidad con SMS para ver las reservas asociadas a tu número de teléfono.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _mostrarDialogoTelefono(context),
                icon: const Icon(Icons.search, size: 22),
                label: const Text(
                  'Buscar Mis Reservas',
                  style: TextStyle(fontSize: 18),
                ),
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
            const SizedBox(height: 24),

            // Link a reservar
            TextButton.icon(
              onPressed: () => context.push('/disponibilidad', extra: widget.negocioId),
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3498DB)),
              label: const Text(
                'Hacer una nueva reserva',
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

  // ============================================================
  // DIÁLOGO: Pedir teléfono
  // ============================================================

  void _mostrarDialogoTelefono(BuildContext context) {
    final telefonoController = TextEditingController();
    String? errorTelefono;

    final servicioVerificacion = getIt<ServicioVerificacionCliente>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.phone_android, color: Color(0xFF27AE60)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Verificar tu teléfono',
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
                'Ingresá tu número de teléfono para verificar tu identidad y ver tus reservas.',
                style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 14),
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
                final validacion = servicioVerificacion.validarTelefono(telefono);

                if (!validacion['valido']) {
                  setDialogState(() {
                    errorTelefono = validacion['error'];
                  });
                  return;
                }

                Navigator.of(dialogContext).pop();
                _mostrarVerificacionSMS(context, validacion['formateado']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar SMS'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIÁLOGO: Verificación SMS
  // ============================================================

  void _mostrarVerificacionSMS(BuildContext context, String telefono) {
    final codigoController = TextEditingController();
    bool enviando = true;
    bool verificando = false;
    String? errorCodigo;
    int segundosRestantes = 60;

    final servicioVerificacion = getIt<ServicioVerificacionCliente>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Enviar código al abrir el diálogo
          if (enviando) {
            servicioVerificacion.enviarCodigoSMS(
              telefono: telefono,
              onCodigoEnviado: (verificationId) {
                setDialogState(() {
                  enviando = false;
                });
                _iniciarTimerReenvio(
                  setDialogState,
                  () => segundosRestantes,
                  (v) => segundosRestantes = v,
                );
              },
              onError: (error) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Error al enviar SMS: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              onVerificacionAutomatica: (credential) async {
                Navigator.of(dialogContext).pop();
                _onVerificacionExitosa(telefono);
              },
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.sms, color: Color(0xFF27AE60)),
                SizedBox(width: 8),
                Expanded(
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
                    'Ingresá el código de 6 dígitos enviado a:',
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                  onPressed: verificando
                      ? null
                      : () async {
                          final codigo = codigoController.text.trim();
                          if (codigo.length != 6) {
                            setDialogState(() {
                              errorCodigo = 'Ingresá el código de 6 dígitos';
                            });
                            return;
                          }

                          setDialogState(() {
                            verificando = true;
                            errorCodigo = null;
                          });

                          try {
                            final telefonoVerificado =
                                await servicioVerificacion.verificarCodigoSMS(
                                    codigo: codigo);

                            Navigator.of(dialogContext).pop();
                            _onVerificacionExitosa(telefonoVerificado);
                          } catch (e) {
                            setDialogState(() {
                              verificando = false;
                              errorCodigo = 'Código incorrecto. Intentá de nuevo.';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                  ),
                  child: verificando
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

  // ============================================================
  // POST-VERIFICACIÓN: Cargar reservas filtradas
  // ============================================================

  void _onVerificacionExitosa(String telefono) {
    final negocioId = widget.negocioId ?? 'default';

    setState(() {
      _verificado = true;
    });

    // Cargar reservas filtradas por teléfono y restaurante
    context.read<MisReservasCubit>().cargarReservasFiltradas(
          telefono: telefono,
          negocioId: negocioId,
        );
  }

  // ============================================================
  // VISTA DE RESERVAS (post-verificación)
  // ============================================================

  Widget _buildReservasView() {
    return BlocConsumer<MisReservasCubit, MisReservasState>(
      listener: (context, state) {
        if (state is ReservaCancelada) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReservaCancelacionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: const Color(0xFFE74C3C),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MisReservasCargando) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MisReservasConError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<MisReservasCubit>().recargarReservas(),
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
                      color: const Color(0xFF27AE60).withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No tenés reservas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se encontraron reservas asociadas a tu número de teléfono en este restaurante.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.push('/disponibilidad', extra: widget.negocioId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Hacer una Reserva', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.reservas.length,
            itemBuilder: (context, index) {
              return _buildReservaCard(context, state.reservas[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ============================================================
  // TARJETA DE RESERVA
  // ============================================================

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
                BadgeEstado(
                  texto: getEstadoTexto(reserva.estado),
                  color: getEstadoColor(reserva.estado),
                  icon: getEstadoIcono(reserva.estado),
                ),
              ],
            ),
            const Divider(height: 24),

            _buildInfoRow(Icons.calendar_today, 'Fecha', dateFormat.format(reserva.fechaHora)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, 'Hora', timeFormat.format(reserva.fechaHora)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.table_restaurant, 'Mesa', _NombreMesa(mesaId: reserva.mesaId)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.people, 'Personas', '${reserva.numeroPersonas}'),

            // Reserva finalizada
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDetalleDialog(context, reserva),
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
                      onPressed: () => _showCancelarDialog(context, reserva.id),
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

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7F8C8D)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 15, color: Color(0xFF7F8C8D)),
        ),
        if (value is Widget)
          value
        else
          Text(
            value.toString(),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detalles de la Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${reserva.id}'),
            const SizedBox(height: 8),
            Text('Fecha y Hora: ${dateFormat.format(reserva.fechaHora)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Mesa: '),
                _NombreMesa(mesaId: reserva.mesaId),
              ],
            ),
            const SizedBox(height: 8),
            Text('Número de Personas: ${reserva.numeroPersonas}'),
            const SizedBox(height: 8),
            Text('Cliente: ${reserva.nombreCliente ?? reserva.contactoCliente ?? 'Sin datos'}'),
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
      builder: (dialogContext) => AlertDialog(
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
}

// ============================================================
// Widget auxiliar para mostrar nombre de mesa
// ============================================================

class _NombreMesa extends StatelessWidget {
  final String mesaId;

  const _NombreMesa({required this.mesaId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<MesaRepositorio>().obtenerMesaPorId(mesaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text(
            mesaId,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          );
        }

        final mesa = snapshot.data!;
        return Text(
          mesa.nombre.isNotEmpty ? mesa.nombre : mesaId,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        );
      },
    );
  }
}
