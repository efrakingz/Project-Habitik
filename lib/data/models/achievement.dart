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
  final String? requisito;
  final bool destacado;

  const AchievementItem({
    this.id,
    required this.key,
    required this.nombre,
    required this.descripcion,
    required this.emoji,
    this.dificultad = 'medio',
    this.xp = 0,
    this.monedas = 0,
    this.desbloqueado = false,
    this.reclamado = false,
    this.desbloqueadoEn,
    this.requisito,
    this.destacado = false,
  });

  /// Retorna la fecha de desbloqueo formateada amigablemente en español
  String get fechaFormateada {
    if (desbloqueadoEn == null || desbloqueadoEn!.isEmpty) {
      return 'Recientemente';
    }
    try {
      final parsed = DateTime.tryParse(desbloqueadoEn!);
      if (parsed != null) {
        final meses = [
          'enero',
          'febrero',
          'marzo',
          'abril',
          'mayo',
          'junio',
          'julio',
          'agosto',
          'septiembre',
          'octubre',
          'noviembre',
          'diciembre',
        ];
        return '${parsed.day} de ${meses[parsed.month - 1]} de ${parsed.year}';
      }
    } catch (_) {}
    return desbloqueadoEn!;
  }

  /// Requisitos pendientes para mostrar cuando la medalla está bloqueada
  String get requisitoPendiente {
    if (requisito != null && requisito!.isNotEmpty) return requisito!;
    final search = '$key $nombre $descripcion'.toUpperCase();
    if (search.contains('DUCHA')) return 'Completa 5 speedruns de ducha en 5 minutos o menos.';
    if (search.contains('RECICL') || search.contains('PUZZLE')) return 'Completa 15 partidas de Eco-Puzzle clasificando todos los residuos sin errores.';
    if (search.contains('TRIVIA') || search.contains('MENTE') || search.contains('CEREBRO')) return 'Responde correctamente 10 trivias ambientales con puntuación perfecta.';
    if (search.contains('RACHA') || search.contains('CONSTANCIA')) return 'Mantén una racha consecutiva de hábitos sostenibles.';
    if (search.contains('BOLETA') || search.contains('GUARDIAN')) return 'Escanea y registra boletas de servicios demostrando ahorro mensual.';
    if (search.contains('FAMILIAR') || search.contains('EQUIPO')) return 'Colabora activamente en retos y colectas con tu familia.';
    return descripcion.isNotEmpty ? descripcion : 'Cumple los retos ecológicos correspondientes en la aplicación.';
  }

  /// Categoría ecológica del logro para agrupación limpia e intuitiva
  String get categoria {
    final search = '$key $nombre $descripcion'.toUpperCase();
    if (search.contains('DUCHA') || search.contains('AGUA')) return 'Ahorro de Agua';
    if (search.contains('RECICL') || search.contains('PUZZLE')) return 'Reciclaje';
    if (search.contains('TRIVIA') || search.contains('MENTE') || search.contains('CEREBRO')) return 'Trivia Ambiental';
    if (search.contains('RACHA') || search.contains('CONSTANCIA')) return 'Racha y Hábitos';
    if (search.contains('BOLETA') || search.contains('GUARDIAN') || search.contains('ENERGIA')) return 'Ahorro Energético';
    if (search.contains('FAMILIAR') || search.contains('EQUIPO')) return 'Misión Familiar';
    return 'Sustentabilidad';
  }

  /// Nivel o escalón de progresión del logro (Nivel I, II o III)
  String get nivelTier {
    final search = '$key $nombre'.toUpperCase();
    if (search.contains('ORO') || search.contains('RELAMPAGO') || search.contains('LEGENDARIA') || monedas >= 30) {
      return 'Nivel III';
    }
    if (search.contains('PLATA') || search.contains('BRONCE') || search.contains('IMPECABLE') || search.contains('EQUIPO') || monedas >= 20) {
      return 'Nivel II';
    }
    return 'Nivel I';
  }


  AchievementItem copyWith({
    String? id,
    String? key,
    String? nombre,
    String? descripcion,
    String? emoji,
    String? dificultad,
    int? xp,
    int? monedas,
    bool? desbloqueado,
    bool? reclamado,
    String? desbloqueadoEn,
    String? requisito,
    bool? destacado,
  }) {
    return AchievementItem(
      id: id ?? this.id,
      key: key ?? this.key,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      emoji: emoji ?? this.emoji,
      dificultad: dificultad ?? this.dificultad,
      xp: xp ?? this.xp,
      monedas: monedas ?? this.monedas,
      desbloqueado: desbloqueado ?? this.desbloqueado,
      reclamado: reclamado ?? this.reclamado,
      desbloqueadoEn: desbloqueadoEn ?? this.desbloqueadoEn,
      requisito: requisito ?? this.requisito,
      destacado: destacado ?? this.destacado,
    );
  }

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    final rawKey = json['codigo']?.toString() ?? json['key']?.toString() ?? json['id']?.toString() ?? '';
    final rawNombre = json['titulo']?.toString() ?? json['nombre']?.toString() ?? '';
    final rawMonedas = json['monedas_recompensa'] ?? json['monedas'] ?? json['recompensa_monedas'];
    final parsedMonedas = rawMonedas is num ? rawMonedas.toInt() : int.tryParse('$rawMonedas') ?? 0;
    final rawXp = json['xp'] ?? json['experiencia'];
    final parsedXp = rawXp is num ? rawXp.toInt() : int.tryParse('$rawXp') ?? 0;

    String emoji = json['emoji']?.toString() ?? json['icono']?.toString() ?? '';
    if (emoji.isEmpty) {
      final search = '$rawKey $rawNombre'.toUpperCase();
      if (search.contains('DUCHA') || search.contains('AGUA')) {
        emoji = '🚿';
      } else if (search.contains('ECO') || search.contains('RECICL') || search.contains('PUZZLE')) {
        emoji = '♻️';
      } else if (search.contains('CEREBRO') || search.contains('MENTE') || search.contains('TRIVIA')) {
        emoji = '🧠';
      } else if (search.contains('RACHA') || search.contains('CONSTANCIA') || search.contains('FUEGO')) {
        emoji = '🔥';
      } else if (search.contains('BOLETA') || search.contains('GUARDIAN')) {
        emoji = '🧾';
      } else if (search.contains('WORDLE')) {
        emoji = '📝';
      } else if (search.contains('CANJE')) {
        emoji = '🎁';
      } else if (search.contains('ENERGIA') || search.contains('SOLAR') || search.contains('RELAMPAGO')) {
        emoji = '⚡';
      } else if (search.contains('FAMILIAR') || search.contains('EQUIPO')) {
        emoji = '👨‍👩‍👧‍👦';
      } else if (search.contains('BRONCE')) {
        emoji = '🥉';
      } else if (search.contains('PLATA')) {
        emoji = '🥈';
      } else if (search.contains('ORO')) {
        emoji = '🥇';
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
      requisito: json['requisito']?.toString(),
      destacado: json['destacado'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo': key,
    'key': key,
    'titulo': nombre,
    'nombre': nombre,
    'descripcion': descripcion,
    'emoji': emoji,
    'dificultad': dificultad,
    'xp': xp,
    'monedas_recompensa': monedas,
    'monedas': monedas,
    'desbloqueado': desbloqueado,
    'reclamado': reclamado,
    'fecha_desbloqueo': desbloqueadoEn,
    'requisito': requisito,
    'destacado': destacado,
  };

  static const AchievementItem empty = AchievementItem(
    key: '',
    nombre: '',
    descripcion: '',
    emoji: '🏆',
  );

  /// Catálogo oficial de insignias del Sprint 4 (CA-4.2C-1 y QA CP-VITRINA-01)
  /// Contiene exactamente 2 ganadas y 3 pendientes para validación inicial de vitrina.
  static List<AchievementItem> get mockList => const [
    AchievementItem(
      id: 'ca5f187f-9bbb-46fc-bda1-b65f959cd4fd',
      key: 'PRIMERA_DUCHA',
      nombre: 'Ducha Ninja',
      descripcion: 'Dúchate en menos de 5 minutos y ahorra más de 40 litros de agua.',
      emoji: '🚿',
      dificultad: 'fácil',
      xp: 100,
      monedas: 10,
      desbloqueado: true,
      reclamado: false,
      desbloqueadoEn: '2026-10-26T20:00:00.000Z',
      requisito: 'Completa 5 speedruns de ducha en 5 minutos o menos.',
      destacado: true,
    ),
    AchievementItem(
      id: 'bb7de31d-0f81-42c2-80d9-2d7de9b0f73d',
      key: 'MAESTRO_ECO',
      nombre: 'Maestro del Reciclaje',
      descripcion: 'Clasifica todos los residuos en el Eco-Puzzle sin cometer errores.',
      emoji: '♻️',
      dificultad: 'medio',
      xp: 150,
      monedas: 15,
      desbloqueado: true,
      reclamado: true,
      desbloqueadoEn: '2026-10-26T20:02:00.000Z',
      requisito: 'Completa 15 Eco-Puzzles con 0 errores.',
    ),
    AchievementItem(
      id: 'cc8de42e-1f92-43d3-91e8-3e8ef0b1e84e',
      key: 'CEREBRO_VERDE',
      nombre: 'Cerebro Verde',
      descripcion: 'Responde correctamente todas las preguntas de la trivia ecológica.',
      emoji: '🧠',
      dificultad: 'difícil',
      xp: 200,
      monedas: 20,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Responde 10 trivias consecutivas con puntuación perfecta (100%).',
    ),
    AchievementItem(
      id: 'b5756983-789d-4dd7-86b8-f2841d8a8417',
      key: 'RACHA_14',
      nombre: 'Racha Legendaria',
      descripcion: 'Mantén vivo el hábito ecológico y cumple retos durante 14 días seguidos.',
      emoji: '🔥',
      dificultad: 'difícil',
      xp: 300,
      monedas: 25,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Registra actividad sustentable durante 14 días consecutivos sin interrupciones.',
    ),
    AchievementItem(
      id: 'dd9ef53f-2003-54e4-a2f9-4f9fa1c2f95f',
      key: 'GUARDIAN_BOLETAS',
      nombre: 'Guardián de Boletas',
      descripcion: 'Escanea tus boletas de luz o agua y demuestra una reducción del consumo mensual.',
      emoji: '🧾',
      dificultad: 'difícil',
      xp: 400,
      monedas: 35,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Carga 3 boletas consecutivas con un porcentaje de ahorro energético superior al 5%.',
    ),
  ];
}
