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
