import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/entidades/historia_restaurante.dart';
import '../../dominio/repositorios/historia_repositorio.dart';
import '../../service_locator.dart';
import '../widgets_comunes/icono_circular.dart';
import '../widgets_comunes/seccion_titulo.dart';

class HistoriaScreen extends StatefulWidget {
  final String? negocioId;
  const HistoriaScreen({super.key, this.negocioId});

  @override
  State<HistoriaScreen> createState() => _HistoriaScreenState();
}

class _HistoriaScreenState extends State<HistoriaScreen> {
  late Future<HistoriaRestaurante?> _historiaFuture;

  @override
  void initState() {
    super.initState();
    _historiaFuture = _buscarHistoria();
  }

  Future<HistoriaRestaurante?> _buscarHistoria() async {
    if (widget.negocioId == null) return null;
    // Intentar buscar en BD
    try {
      final repo = getIt<HistoriaRepositorio>();
      return await repo.obtenerHistoria(widget.negocioId!);
    } catch (e) {
      print('Error cargando historia: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<HistoriaRestaurante?>(
        future: _historiaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final historia = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- ENCABEZADO TIPO BANNER ---
                if (historia == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Historia no disponible',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'El restaurante aún no ha cargado su historia.',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Volver'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Botón volver sutil
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () => context.pop(),
                          child: IconoCircular.circulo(
                            icon: Icons.arrow_back,
                            color: Colors.white,
                            padding: 8,
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                      const Icon(Icons.storefront, size: 50, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        historia.titulo,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        historia.subtitulo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // --- CONTENIDO ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Historia
                      if (historia.parrafosHistoria.isEmpty)
                         const Text('No hay historia disponible.'),

                      ...historia.parrafosHistoria.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          )),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 24),

                      // Título Platos
                      SeccionTitulo(
                        icon: Icons.restaurant_menu,
                        titulo: 'Nuestras Especialidades',
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),

                      // Lista de Platos
                      if (historia.especialidades.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No hay especialidades registradas.'),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: historia.especialidades.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final e = historia.especialidades[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: IconoCircular(
                                  icon: e.icono,
                                  color: Colors.white,
                                  size: 24,
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                                title: Text(
                                  e.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    e.descripcion,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Gracias por su visita',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ],
          ),
          );
        },
      ),
    );
  }
}
