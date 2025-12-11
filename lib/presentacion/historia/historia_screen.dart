import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoriaScreen extends StatelessWidget {
  const HistoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuestra Historia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/restaurante'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal
              Center(
                child: Text(
                  'Chiringuito',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Tradición y Sabor del Mar',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Historia (aquí irá el texto que proporciones)
              const Text(
                'Nuestra Historia',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aquí irá la historia del restaurante que proporcionarás más adelante...',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 40),
              
              // Nuestras Comidas
              const Text(
                'Nuestras Especialidades',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE67E22),
                ),
              ),
              const SizedBox(height: 20),
              
              // Lista de comidas (ejemplo, puedes personalizarla)
              _buildComidaItem(
                Icons.set_meal,
                'Paella Marinera',
                'Arroz con frutos del mar frescos',
              ),
              _buildComidaItem(
                Icons.dinner_dining,
                'Pescado a la Plancha',
                'Pescado fresco del día con guarnición',
              ),
              _buildComidaItem(
                Icons.restaurant,
                'Mariscos Frescos',
                'Selección de mariscos de la región',
              ),
              _buildComidaItem(
                Icons.local_dining,
                'Tapas Variadas',
                'Auténticas tapas españolas',
              ),
              
              const SizedBox(height: 40),
              
              // Botón volver
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go('/restaurante'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Volver al Restaurante',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }

  Widget _buildComidaItem(IconData icon, String nombre, String descripcion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFFE67E22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
