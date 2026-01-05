import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/entidades/historia_restaurante.dart';

class HistoriaScreen extends StatelessWidget {
  const HistoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar con imagen de fondo y efecto parallax
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => context.go('/restaurante'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                historiaMock.titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo
                  Image.asset(
                    'assets/images/restaurant_header.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si la imagen no existe
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 100,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                  // Overlay con degradado
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado del restaurante
                _buildEncabezado(context, textTheme, colorScheme),

                // Párrafos de la historia
                _buildSeccionHistoria(context, textTheme, colorScheme),

                // Separador decorativo
                _buildSeparadorDecorativo(colorScheme),

                // Sección de especialidades
                _buildSeccionEspecialidades(context, textTheme, colorScheme),

                // Pie de página
                _buildPieDePagina(context, textTheme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Encabezado con nombre del restaurante y subtítulo
  Widget _buildEncabezado(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre del restaurante
          Text(
            'Chiringuito',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtítulo en cursiva
          Text(
            historiaMock.subtitulo,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Línea decorativa
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de párrafos narrativos de la historia
  Widget _buildSeccionHistoria(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: historiaMock.parrafosHistoria.asMap().entries.map((entry) {
          final index = entry.key;
          final parrafo = entry.value;
          
          // Primer párrafo con letra capital
          if (index == 0) {
            return _buildParrafoConLetraCapital(parrafo, textTheme, colorScheme);
          }
          
          // Párrafos siguientes
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              parrafo,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.justify,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Párrafo con letra capital decorativa (Drop Cap)
  Widget _buildParrafoConLetraCapital(
    String parrafo,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final primeraLetra = parrafo.isNotEmpty ? parrafo[0] : '';
    final restoTexto = parrafo.length > 1 ? parrafo.substring(1) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Letra capital
          Container(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: Text(
              primeraLetra,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                height: 0.8,
                fontFamily: 'serif',
              ),
            ),
          ),
          // Resto del texto
          Expanded(
            child: Text(
              restoTexto,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  /// Separador decorativo entre secciones
  Widget _buildSeparadorDecorativo(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 1,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.restaurant_menu,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 1,
            color: colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }

  /// Sección de especialidades con carrusel horizontal
  Widget _buildSeccionEspecialidades(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Platos Estrella',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Descubre nuestras especialidades más aclamadas',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Carrusel horizontal
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: historiaMock.especialidades.length,
            itemBuilder: (context, index) {
              final especialidad = historiaMock.especialidades[index];
              return _buildTarjetaEspecialidad(
                context,
                especialidad,
                textTheme,
                colorScheme,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tarjeta individual de especialidad
  Widget _buildTarjetaEspecialidad(
    BuildContext context,
    EspecialidadItem especialidad,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _mostrarDetalleEspecialidad(context, especialidad, colorScheme),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    especialidad.icono,
                    size: 36,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // Nombre
                Text(
                  especialidad.nombre,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Descripción corta
                Expanded(
                  child: Text(
                    especialidad.descripcion,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostrar detalle completo de especialidad en BottomSheet
  void _mostrarDetalleEspecialidad(
    BuildContext context,
    EspecialidadItem especialidad,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Icono grande
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  especialidad.icono,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Nombre
              Text(
                especialidad.nombre,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Descripción completa
              Text(
                especialidad.descripcion,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Pie de página con información adicional
  Widget _buildPieDePagina(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Gracias por ser parte de nuestra familia',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cada plato que servimos lleva nuestro amor y dedicación.\nTe esperamos pronto.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Badge de años
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+ 25 años de tradición',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
