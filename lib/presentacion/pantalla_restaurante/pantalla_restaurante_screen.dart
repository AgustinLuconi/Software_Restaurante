import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pantalla_restaurante_cubit.dart';
import 'pantalla_restaurante_estados_de_cubit.dart';

class PantallaRestauranteScreen extends StatelessWidget {
  final String? negocioId;
  
  const PantallaRestauranteScreen({super.key, this.negocioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantallaRestauranteCubit()..cargarDatosNegocio(negocioId: negocioId),
      child: const _PantallaRestauranteView(),
    );
  }
}

class _PantallaRestauranteView extends StatelessWidget {
  const _PantallaRestauranteView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantallaRestauranteCubit, PantallaRestauranteState>(
      builder: (context, state) {
        // Obtener datos del negocio para toda la pantalla
        String nombreNegocio = 'Restaurante';
        String especialidad = 'Gastronomía';

        if (state is PantallaRestauranteExitoso) {
          nombreNegocio = state.negocio.nombre;
          especialidad = state.negocio.especialidad;
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/');
              },
              tooltip: 'Volver a restaurantes',
            ),
            title: Text(nombreNegocio),
          ),
          body: _buildBody(context, state, nombreNegocio, especialidad),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    PantallaRestauranteState state,
    String nombreNegocio,
    String especialidad,
  ) {
    if (state is PantallaRestauranteConError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.mensaje,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<PantallaRestauranteCubit>().reiniciar();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con imagen de fondo
          _buildHeader(context, nombreNegocio, especialidad),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón principal - Reservar Mesa
                _buildPrimaryButton(context),

                const SizedBox(height: 24),

                // Sección de título
                Text(
                  'Explora',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // Grid de opciones secundarias
                _buildSecondaryOptions(context),

                const SizedBox(height: 24),

                // Información de contacto
                _buildContactInfo(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String nombreNegocio,
    String especialidad,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo circular
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // Nombre del restaurante
            Text(
              nombreNegocio,
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            // Subtítulo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                especialidad,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: () => context.go('/disponibilidad'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 28),
            const SizedBox(width: 12),
            Text(
              'Reservar Mesa',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryOptions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            context,
            icon: Icons.event_note,
            title: 'Mis Reservas',
            onTap: () => context.go('/mis-reservas'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            context,
            icon: Icons.menu_book,
            title: 'Historia',
            onTap: () => context.go('/historia'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            context,
            icon: Icons.contact_phone,
            title: 'Contacto',
            onTap: () {
              final state = context.read<PantallaRestauranteCubit>().state;
              if (state is PantallaRestauranteExitoso) {
                _showContactDialog(context, state.negocio.telefono, state.negocio.email);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return BlocBuilder<PantallaRestauranteCubit, PantallaRestauranteState>(
      builder: (context, state) {
        final horarios =
            state is PantallaRestauranteExitoso
                ? state.horarios
                : <String, String>{};

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule, color: Colors.blue.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Horario de Atención',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Horarios dinámicos
                          _buildHorariosColumn(horarios),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubicación',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            state is PantallaRestauranteExitoso 
                                ? state.negocio.direccion 
                                : 'Cargando...',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye la columna de horarios dinámicamente
  Widget _buildHorariosColumn(Map<String, String> horarios) {
    if (horarios.isEmpty) {
      return const Text(
        'Horarios no disponibles',
        style: TextStyle(fontSize: 13, color: Color(0xFF7F8C8D)),
      );
    }

    final diasAbiertos = <MapEntry<String, String>>[];
    final diasCerrados = <String>[];

    for (final entry in horarios.entries) {
      if (entry.value.toLowerCase() == 'cerrado') {
        diasCerrados.add(entry.key);
      } else {
        diasAbiertos.add(entry);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Días abiertos
        ...diasAbiertos.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '${entry.key}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Días cerrados (si hay)
        if (diasCerrados.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Cerrado: ${diasCerrados.join(', ')}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7F8C8D),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _showContactDialog(BuildContext context, String telefono, String email) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone, color: Colors.purple.shade700),
                ),
                const SizedBox(width: 12),
                const Text('Contacto'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📞 Teléfono:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(telefono.isNotEmpty ? telefono : 'No disponible'),
                const SizedBox(height: 16),
                const Text(
                  '📧 Email:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(email.isNotEmpty ? email : 'No disponible'),
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
}
