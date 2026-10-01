class RewardItem {
  final int id;
  final String titulo;
  final int costo;
  final String descripcion;
  final String emoji;
  final bool disponible;
  final bool esFamiliar;
  final DateTime? createdAt;
  final DateTime? lastRedeemedAt;
  final String? lastRedeemedByNombre;
  final Map<String, dynamic> metadata;

  const RewardItem({
    required this.id,
    required this.titulo,
    required this.costo,
    required this.descripcion,
    this.emoji = '🎁',
    this.disponible = true,
    this.esFamiliar = true,
    this.createdAt,
    this.lastRedeemedAt,
    this.lastRedeemedByNombre,
    this.metadata = const {},
  });

  bool get isCooldownActive {
    // Si el backend marca explícitamente como no disponible → cooldown activo
    if (!disponible) return true;

    // Verificación local basada en tiempo de enfriamiento según frecuencia
    if (lastRedeemedAt == null) return false;
    final String frecuencia = metadata['frecuencia']?.toString() ?? '';
    final now = DateTime.now();
    if (frecuencia == 'diario') {
      return now.difference(lastRedeemedAt!).inHours < 24;
    } else if (frecuencia == 'semanal') {
      return now.difference(lastRedeemedAt!).inDays < 7;
    } else if (frecuencia == 'mensual') {
      return now.difference(lastRedeemedAt!).inDays < 30;
    }
    return false;
  }

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse('${json['id']}') ?? 0,
      titulo: json['titulo']?.toString() ?? '',
      costo: json['costo'] is num ? (json['costo'] as num).toInt() : int.tryParse('${json['costo']}') ?? 0,
      descripcion: json['descripcion']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🎁',
      disponible: json['disponible'] != false,
      esFamiliar: json['es_familiar'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      lastRedeemedAt: json['last_redeemed_at'] != null ? DateTime.tryParse(json['last_redeemed_at'].toString()) : null,
      lastRedeemedByNombre: json['last_redeemed_by_nombre']?.toString(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
    );
  }

  static List<RewardItem> get mockList => [
    const RewardItem(
      id: 1,
      titulo: 'Pizza Familiar',
      costo: 50,
      descripcion: 'Una pizza para toda la familia el fin de semana',
      emoji: '🍕',
      disponible: true,
      esFamiliar: true,
      metadata: {'frecuencia': 'semanal'},
    ),
    const RewardItem(
      id: 2,
      titulo: 'Noche de Cine',
      costo: 30,
      descripcion: 'Elige la película del viernes',
      emoji: '🎬',
      disponible: true,
      esFamiliar: true,
      metadata: {'frecuencia': 'semanal'},
    ),
    const RewardItem(
      id: 3,
      titulo: 'Sin Tareas',
      costo: 20,
      descripcion: 'Un día libre sin tareas del hogar',
      emoji: '🛌',
      disponible: false,
      esFamiliar: false,
      metadata: {'frecuencia': 'mensual'},
    ),
    const RewardItem(
      id: 4,
      titulo: 'Helado',
      costo: 10,
      descripcion: 'Un helado de tu sabor favorito',
      emoji: '🍦',
      disponible: true,
      esFamiliar: false,
      metadata: {'frecuencia': 'diario'},
    ),
    const RewardItem(
      id: 5,
      titulo: 'Videojuegos',
      costo: 15,
      descripcion: '2 horas extra de videojuegos',
      emoji: '🎮',
      disponible: true,
      esFamiliar: false,
    ),
    const RewardItem(
      id: 6,
      titulo: 'Paseo al Parque',
      costo: 25,
      descripcion: 'Paseo familiar al parque',
      emoji: '🏖️',
      disponible: true,
      esFamiliar: true,
    ),
  ];
}
