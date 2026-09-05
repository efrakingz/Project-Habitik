class AchievementItem {
  final String? id;
  final String key;
  final String nombre;
  final String descripcion;
  final String emoji;
  final String dificultad;
  final int xp;
  final int monedas;
  final bool desbloqueado;
  final bool reclamado;
  final String? desbloqueadoEn;

  const AchievementItem({
    this.id,
    required this.key,
    required this.nombre,
    required this.descripcion,
    required this.emoji,
    required this.dificultad,
    required this.xp,
    required this.monedas,
    this.desbloqueado = false,
    this.reclamado = false,
    this.desbloqueadoEn,
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    final rawKey = json['codigo']?.toString() ?? json['key']?.toString() ?? '';
    final rawNombre = json['titulo']?.toString() ?? json['nombre']?.toString() ?? '';
    final rawMonedas = json['monedas_recompensa'] ?? json['monedas'];
    final parsedMonedas = rawMonedas is num ? rawMonedas.toInt() : int.tryParse('$rawMonedas') ?? 0;
    final rawXp = json['xp'];
    final parsedXp = rawXp is num ? rawXp.toInt() : int.tryParse('$rawXp') ?? 0;

    String emoji = json['emoji']?.toString() ?? '';
    if (emoji.isEmpty) {
      if (rawKey.contains('ducha') || rawKey.contains('agua')) {
        emoji = '🚿';
      } else if (rawKey.contains('reto')) {
        emoji = '🌱';
      } else if (rawKey.contains('racha')) {
        emoji = '🔥';
      } else if (rawKey.contains('wordle')) {
        emoji = '📝';
      } else if (rawKey.contains('trivia')) {
        emoji = '🧠';
      } else if (rawKey.contains('canje')) {
        emoji = '🎁';
      } else {
        emoji = '🏆';
      }
    }

    return AchievementItem(
      id: json['id']?.toString(),
      key: rawKey,
      nombre: rawNombre,
      descripcion: json['descripcion']?.toString() ?? '',
      emoji: emoji,
      dificultad: json['dificultad']?.toString() ?? 'medio',
      xp: parsedXp,
      monedas: parsedMonedas,
      desbloqueado: json['desbloqueado'] == true,
      reclamado: json['reclamado'] == true,
      desbloqueadoEn: json['fecha_desbloqueo']?.toString() ?? json['desbloqueado_en']?.toString(),
    );
  }

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
