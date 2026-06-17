class ChallengeType {
  final String id;
  final String emoji;
  final String titulo;

  /// Short display title shown on the detail panel (can differ from titulo)
  final String displayTitle;
  final String desc;
  final int xp;
  final int monedas;
  final String colorHex;

  /// Darker shadow/border color for UI accents
  final String colorHex2;

  const ChallengeType({
    required this.id,
    required this.emoji,
    required this.titulo,
    String? displayTitle,
    required this.desc,
    required this.xp,
    required this.monedas,
    required this.colorHex,
    String? colorHex2,
  }) : displayTitle = displayTitle ?? titulo,
       colorHex2 = colorHex2 ?? colorHex;

  static List<ChallengeType> get allChallenges => const [
    ChallengeType(
      id: 'ducha',
      emoji: '🚿',
      titulo: 'Speedrun de la Ducha',
      displayTitle: 'Speedrun Ducha',
      desc: 'Dúchate en menos de 10 min',
      xp: 50,
      monedas: 5,
      colorHex: '#2196F3',
      colorHex2: '#1976D2',
    ),
    ChallengeType(
      id: 'inspeccion',
      emoji: '🔍',
      titulo: 'Inspección del Día',
      displayTitle: 'Cazador Sombras',
      desc: 'Misión rotativa para el hogar',
      xp: 100,
      monedas: 15,
      colorHex: '#FFB74D',
      colorHex2: '#F57C00',
    ),
    ChallengeType(
      id: 'trivia',
      emoji: '🧠',
      titulo: 'Trivia Infinita',
      displayTitle: 'Trivia Eco',
      desc: '3 vidas · preguntas de ecología',
      xp: 150,
      monedas: 15,
      colorHex: '#E040FB',
      colorHex2: '#9C27B0',
    ),
    ChallengeType(
      id: 'puzzle',
      emoji: '🎯',
      titulo: 'Eco-Puzzle',
      displayTitle: 'Eco-Puzzle',
      desc: 'Clasifica residuos en 60 segundos',
      xp: 120,
      monedas: 20,
      colorHex: '#FF5252',
      colorHex2: '#C62828',
    ),
    ChallengeType(
      id: 'wordle',
      emoji: '🔤',
      titulo: 'Eco-Wordle del Día',
      displayTitle: 'Eco-Wordle',
      desc: 'Adivina la palabra ecológica de hoy',
      xp: 50,
      monedas: 5,
      colorHex: '#4CAF50',
      colorHex2: '#388E3C',
    ),
    ChallengeType(
      id: 'sopa',
      emoji: '🔠',
      titulo: 'Sopa de Letras',
      displayTitle: 'Sopa de Letras',
      desc: 'Busca las palabras ecológicas ocultas',
      xp: 100,
      monedas: 10,
      colorHex: '#00796B',
      colorHex2: '#004D40',
    ),
    ChallengeType(
      id: 'pesca',
      emoji: '🐟',
      titulo: 'Mar Limpio (Bono)',
      displayTitle: 'Mar Limpio',
      desc: 'Recoge basura del océano y salva peces',
      xp: 150,
      monedas: 15,
      colorHex: '#0096C7',
      colorHex2: '#023E8A',
    ),
  ];
}
