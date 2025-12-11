import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../dominio/entidades/notificacion.dart';
import '../../service_locator.dart';
import 'notificaciones_cubit.dart';
import 'notificaciones_estados_de_cubit.dart';

class NotificacionesScreen extends StatelessWidget {
  final String usuarioId;

  const NotificacionesScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificacionesCubit>()..cargarNotificaciones(usuarioId),
      child: _NotificacionesView(usuarioId: usuarioId),
    );
  }
}

class _NotificacionesView extends StatelessWidget {
  final String usuarioId;

  const _NotificacionesView({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/restaurante'),
        ),
        actions: [
          BlocBuilder<NotificacionesCubit, NotificacionesState>(
            builder: (context, state) {
              if (state is NotificacionesCargadas && state.noLeidas > 0) {
                return TextButton.icon(
                  onPressed: () {
                    context.read<NotificacionesCubit>().marcarTodasComoLeidas(usuarioId);
                  },
                  icon: Icon(Icons.done_all, color: colorScheme.onSurface),
                  label: Text(
                    'Marcar todas',
                    style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificacionesCubit, NotificacionesState>(
        listener: (context, state) {
          if (state is NotificacionesConError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificacionesCargando) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificacionesCargadas) {
            if (state.notificaciones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 100,
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes notificaciones',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aquí aparecerán las actualizaciones importantes',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Separar notificaciones no leídas y leídas
            final noLeidas = state.notificaciones.where((n) => !n.leida).toList();
            final leidas = state.notificaciones.where((n) => n.leida).toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Mostrar contador de no leídas
                if (state.noLeidas > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3498DB),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.noLeidas}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.noLeidas == 1
                              ? 'Tienes 1 notificación nueva'
                              : 'Tienes ${state.noLeidas} notificaciones nuevas',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Notificaciones no leídas
                if (noLeidas.isNotEmpty) ...[
                  const Text(
                    'Nuevas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...noLeidas.map((notif) => _buildNotificacionCard(
                        context,
                        notif,
                        usuarioId,
                      )),
                  const SizedBox(height: 24),
                ],

                // Notificaciones leídas
                if (leidas.isNotEmpty) ...[
                  const Text(
                    'Anteriores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...leidas.map((notif) => _buildNotificacionCard(
                        context,
                        notif,
                        usuarioId,
                      )),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificacionCard(
    BuildContext context,
    Notificacion notificacion,
    String usuarioId,
  ) {
    final color = _getColorPorTipo(notificacion.tipo);
    final icono = _getIconoPorTipo(notificacion.tipo);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Eliminar notificación'),
              content: const Text('¿Estás seguro de que deseas eliminar esta notificación?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<NotificacionesCubit>().eliminarNotificacion(
              notificacion.id,
              usuarioId,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notificacion.leida ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notificacion.leida
                ? Colors.grey.withOpacity(0.2)
                : color.withOpacity(0.5),
            width: notificacion.leida ? 1 : 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!notificacion.leida) {
              context.read<NotificacionesCubit>().marcarComoLeida(
                    notificacion.id,
                    usuarioId,
                  );
            }
            // Aquí podrías navegar a la pantalla relacionada si hay reservaId
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: notificacion.leida
                  ? Colors.white
                  : color.withOpacity(0.05),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icono,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Contenido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notificacion.titulo,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notificacion.leida
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            if (!notificacion.leida)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notificacion.mensaje,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(notificacion.fechaCreacion),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
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
        ),
      ),
    );
  }

  Color _getColorPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.reservaConfirmada:
        return const Color(0xFF27AE60);
      case TipoNotificacion.reservaCancelada:
        return const Color(0xFFE74C3C);
      case TipoNotificacion.reservaPendiente:
        return const Color(0xFFF39C12);
      case TipoNotificacion.mesaDisponible:
        return const Color(0xFF3498DB);
      case TipoNotificacion.recordatorioReserva:
        return const Color(0xFF9B59B6);
      case TipoNotificacion.cambioHorario:
        return const Color(0xFFE67E22);
      case TipoNotificacion.general:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getIconoPorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.reservaConfirmada:
        return Icons.check_circle;
      case TipoNotificacion.reservaCancelada:
        return Icons.cancel;
      case TipoNotificacion.reservaPendiente:
        return Icons.pending;
      case TipoNotificacion.mesaDisponible:
        return Icons.event_available;
      case TipoNotificacion.recordatorioReserva:
        return Icons.notifications_active;
      case TipoNotificacion.cambioHorario:
        return Icons.schedule;
      case TipoNotificacion.general:
        return Icons.info;
    }
  }
}
