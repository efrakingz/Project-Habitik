class AchievementItem {
  final String key;
  final String nombre;
  final String descripcion;
  final String emoji;
  final String dificultad;
  final int xp;
  final int monedas;
  final bool desbloqueado;
  final String? desbloqueadoEn;

  const AchievementItem({
    required this.key,
    required this.nombre,
    required this.descripcion,
    required this.emoji,
    required this.dificultad,
    required this.xp,
    required this.monedas,
    this.desbloqueado = false,
    this.desbloqueadoEn,
  });

  static List<AchievementItem> get mockList => const [
    AchievementItem(
      key: 'primer_reto',
      nombre: 'Primer Reto',
      descripcion: 'Completa tu primer reto',
      emoji: '🌱',
      dificultad: 'fácil',
      xp: 50,
      monedas: 5,
      desbloqueado: true,
      desbloqueadoEn: '2026-05-01',
    ),
    AchievementItem(
      key: 'racha_7',
      nombre: 'Semana Perfecta',
      descripcion: 'Completa retos 7 días seguidos',
      emoji: '🔥',
      dificultad: 'medio',
      xp: 200,
      monedas: 20,
      desbloqueado: true,
      desbloqueadoEn: '2026-05-10',
    ),
    AchievementItem(
      key: 'wordle_master',
      nombre: 'Wordle Master',
      descripcion: 'Gana 10 Wordle ecológicos',
      emoji: '📝',
      dificultad: 'medio',
      xp: 100,
      monedas: 10,
      desbloqueado: false,
    ),
    AchievementItem(
      key: 'trivia_pro',
      nombre: 'Trivia Pro',
      descripcion: 'Responde 50 preguntas correctas',
      emoji: '🧠',
      dificultad: 'difícil',
      xp: 300,
      monedas: 30,
      desbloqueado: false,
    ),
    AchievementItem(
      key: 'eco_warrior',
      nombre: 'Eco Guerrero',
      descripcion: 'Ahorra 100kWh en familia',
      emoji: '⚡',
      dificultad: 'difícil',
      xp: 500,
      monedas: 50,
      desbloqueado: false,
    ),
    AchievementItem(
      key: 'primer_canje',
      nombre: 'Primer Canje',
      descripcion: 'Canjea tu primera recompensa',
      emoji: '🎁',
      dificultad: 'fácil',
      xp: 30,
      monedas: 3,
      desbloqueado: true,
      desbloqueadoEn: '2026-05-15',
    ),
  ];
}
