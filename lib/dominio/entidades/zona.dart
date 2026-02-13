/// Representa una zona del restaurante (terraza, salón, VIP, etc.)
/// Cada restaurante puede definir sus propias zonas personalizadas
class Zona {
  final String id;
  final String nombre;
  final String descripcion;
  final String negocioId;
  final String?
  colorHex; // Color opcional para identificación visual (ej: '#FF5733')

  Zona({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.negocioId,
    this.colorHex,
  });

  Zona copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? negocioId,
    String? colorHex,
  }) {
    return Zona(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      negocioId: negocioId ?? this.negocioId,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  // Zonas predeterminadas que se crean al registrar un nuevo negocio
  static List<Zona> zonasIniciales(String negocioId) {
    return [
      Zona(
        id: '', // Se generará en Firestore
        nombre: 'Salón',
        descripcion: 'Interior climatizado',
        negocioId: negocioId,
        colorHex: '#3498DB',
      ),
      Zona(
        id: '',
        nombre: 'Terraza',
        descripcion: 'Área al aire libre',
        negocioId: negocioId,
        colorHex: '#27AE60',
      ),
      Zona(
        id: '',
        nombre: 'Barra',
        descripcion: 'Junto a la barra',
        negocioId: negocioId,
        colorHex: '#E74C3C',
      ),
    ];
  }
}
