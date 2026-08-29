class EvidenceItem {
  final String id;
  final String userId;
  final String autorNombre;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;
  final String accion;
  final String descripcion;
  final int xp;
  final String emoji;
  final String? imagenUrl;
  final int likes;
  final String tiempo;

  const EvidenceItem({
    this.id = '',
    required this.userId,
    required this.autorNombre,
    required this.avatarLetra,
    required this.avatarColor,
    this.avatarUrl,
    required this.accion,
    required this.descripcion,
    required this.xp,
    required this.emoji,
    this.imagenUrl,
    this.likes = 0,
    required this.tiempo,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    String nombre = 'Usuario';
    String letra = 'U';
    String color = '#43A047';
    String? url;

    // Extraer del snapshot_usuario
    if (json['snapshot_usuario'] != null) {
      final snap = json['snapshot_usuario'];
      if (snap is Map) {
        nombre = snap['nombre']?.toString() ?? 'Usuario';
        if (snap['avatar'] is Map) {
          letra =
              snap['avatar']['letra']?.toString() ??
              (nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U');
          color = snap['avatar']['color']?.toString() ?? '#43A047';
          url = snap['avatar']['url']?.toString();
        }
      }
    } else {
      nombre = json['autor_nombre'] ?? json['nombre'] ?? 'Usuario';
      letra =
          json['avatar_letra'] ??
          (nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U');
      color = json['avatar_color'] ?? '#43A047';
      url = json['avatar_url'];
    }

    String? imagen;
    if (json['media'] != null &&
        json['media'] is List &&
        (json['media'] as List).isNotEmpty) {
      final firstMedia = (json['media'] as List).first;
      if (firstMedia is Map) {
        imagen = firstMedia['url']?.toString();
      }
    } else {
      imagen = json['imagen_url'];
    }

    return EvidenceItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      autorNombre: nombre,
      avatarLetra: letra,
      avatarColor: color,
      avatarUrl: url,
      accion: json['accion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      xp: json['xp'] is num
          ? (json['xp'] as num).toInt()
          : int.tryParse('${json['xp']}') ?? 0,
      emoji: json['emoji'] ?? '⭐',
      imagenUrl: imagen,
      likes: json['likes'] is num
          ? (json['likes'] as num).toInt()
          : int.tryParse('${json['likes']}') ?? 0,
      tiempo: json['created_at'] != null
          ? json['created_at'].toString().split('T')[0]
          : 'Hoy',
    );
  }

  static List<EvidenceItem> get mockList => [
    EvidenceItem(
      id: '1',
      userId: '1',
      autorNombre: 'Carlos Torres',
      avatarLetra: 'C',
      avatarColor: '#2E7D32',
      accion: '⚡ Speedrun de la Ducha',
      descripcion: 'Se duchó en 7 minutos',
      xp: 50,
      emoji: '🚿',
      likes: 3,
      tiempo: 'Hace 2h',
    ),
    EvidenceItem(
      id: '2',
      userId: '2',
      autorNombre: 'Sofía Torres',
      avatarLetra: 'S',
      avatarColor: '#9C27B0',
      accion: '🧠 Trivia Ecológica',
      descripcion: 'Respondió 8/10 preguntas correctamente',
      xp: 150,
      emoji: '🏆',
      likes: 5,
      tiempo: 'Hace 4h',
    ),
    EvidenceItem(
      id: '3',
      userId: '3',
      autorNombre: 'Lucía Torres',
      avatarLetra: 'L',
      avatarColor: '#E91E63',
      accion: '🔤 Eco-Wordle del Día',
      descripcion: 'Adivinó "RECICLAJE" en 4 intentos',
      xp: 50,
      emoji: '📝',
      likes: 2,
      tiempo: 'Ayer',
    ),
  ];
}
