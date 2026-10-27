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
  final int progresoActual;
  final int progresoMeta;
  final String? progresoTexto;

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
    this.progresoActual = 0,
    this.progresoMeta = 0,
    this.progresoTexto,
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

  /// Texto de progreso formateado según el contrato del backend y diseño oficial
  String get progresoDisplay {
    if (progresoTexto != null && progresoTexto!.trim().isNotEmpty) {
      return progresoTexto!;
    }
    if (desbloqueado) {
      if (progresoMeta > 0) {
        return '$progresoMeta/$progresoMeta completado';
      }
      return 'Completado';
    }
    if (progresoMeta > 0) {
      final search = '$key $nombre'.toUpperCase();
      if (search.contains('RACHA') || categoria.contains('Racha')) {
        return 'Racha $progresoActual/$progresoMeta dias';
      }
      if (categoria.contains('Agua') && progresoMeta > 1) {
        return '$progresoActual/$progresoMeta completadas';
      }
      return '$progresoActual/$progresoMeta completado';
    }
    return 'Pendiente';
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
    if (search.contains('ORO') || search.contains('RELAMPAGO') || search.contains('LEGENDARIA') || search.contains('CONSTANCIA') || monedas >= 30) {
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
    int? progresoActual,
    int? progresoMeta,
    String? progresoTexto,
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
      progresoActual: progresoActual ?? this.progresoActual,
      progresoMeta: progresoMeta ?? this.progresoMeta,
      progresoTexto: progresoTexto ?? this.progresoTexto,
    );
  }

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    final rawKey = json['codigo']?.toString() ?? json['key']?.toString() ?? json['id']?.toString() ?? '';
    final rawNombre = json['titulo']?.toString() ?? json['nombre']?.toString() ?? '';
    final rawMonedas = json['monedas_recompensa'] ?? json['monedas'] ?? json['recompensa_monedas'];
    final parsedMonedas = rawMonedas is num ? rawMonedas.toInt() : int.tryParse('$rawMonedas') ?? 0;
    final rawXp = json['xp'] ?? json['experiencia'];
    final parsedXp = rawXp is num ? rawXp.toInt() : int.tryParse('$rawXp') ?? 0;

    final rawActual = json['progreso_actual'] ?? json['progreso'] ?? json['hechos_completos'] ?? json['actual'] ?? json['current'];
    int parsedActual = rawActual is num ? rawActual.toInt() : int.tryParse('$rawActual') ?? 0;

    final rawMeta = json['progreso_meta'] ?? json['meta'] ?? json['objetivo'] ?? json['total_requerido'] ?? json['maximo'] ?? json['target'];
    int parsedMeta = rawMeta is num ? rawMeta.toInt() : int.tryParse('$rawMeta') ?? 0;

    final rawTexto = json['progreso_texto']?.toString() ?? json['texto_progreso']?.toString();

    final isUnlocked = json['desbloqueado'] == true;

    // Inferencia de meta defensiva según requisito/descripción si el backend no la incluye
    if (parsedMeta == 0) {
      final search = '$rawKey $rawNombre ${json['descripcion']} ${json['requisito']}'.toUpperCase();
      if (search.contains('3 DIAS') || search.contains('3 DÍAS') || search.contains('3 BOLETAS')) {
        parsedMeta = 3;
      } else if (search.contains('5 DUCHAS') || search.contains('5 RETOS') || search.contains('5 PARTIDAS') || search.contains('5 PALABRAS')) {
        parsedMeta = 5;
      } else if (search.contains('10 TRIVIAS') || search.contains('10 SPEEDRUNS') || search.contains('10 ')) {
        parsedMeta = 10;
      } else if (search.contains('14 DIAS') || search.contains('14 DÍAS')) {
        parsedMeta = 14;
      } else if (search.contains('20 SPEEDRUNS') || search.contains('20 ')) {
        parsedMeta = 20;
      } else {
        parsedMeta = 1;
      }
    }

    if (isUnlocked && parsedActual < parsedMeta) {
      parsedActual = parsedMeta;
    }

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
      desbloqueado: isUnlocked,
      reclamado: json['reclamado'] == true,
      desbloqueadoEn: json['fecha_desbloqueo']?.toString() ?? json['desbloqueado_en']?.toString(),
      requisito: json['requisito']?.toString(),
      destacado: json['destacado'] == true,
      progresoActual: parsedActual,
      progresoMeta: parsedMeta,
      progresoTexto: rawTexto,
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
    'progreso_actual': progresoActual,
    'progreso_meta': progresoMeta,
    'progreso_texto': progresoTexto,
  };

  static const AchievementItem empty = AchievementItem(
    key: '',
    nombre: '',
    descripcion: '',
    emoji: '🏆',
  );

  /// Catálogo de prueba para QA y CP-VITRINA-01 (exactamente 2 ganadas y 3 pendientes)
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
      progresoActual: 1,
      progresoMeta: 1,
      progresoTexto: '1/1 completado',
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
      progresoActual: 1,
      progresoMeta: 1,
      progresoTexto: 'Completado',
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
      progresoActual: 0,
      progresoMeta: 10,
      progresoTexto: '0/10 completadas',
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
      progresoActual: 0,
      progresoMeta: 14,
      progresoTexto: 'Racha 0/14 dias',
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
      progresoActual: 0,
      progresoMeta: 3,
      progresoTexto: '0/3 registradas',
    ),
  ];

  /// Catálogo Oficial de las 11 Insignias del Backend y Vitrina de Trofeos
  static List<AchievementItem> get officialCatalog => const [
    AchievementItem(
      id: 'ca5f187f-9bbb-46fc-bda1-b65f959cd4fd',
      key: 'PRIMERA_DUCHA',
      nombre: 'Ducha Eficiente',
      descripcion: 'Completa tu primer Speedrun de Ducha válido',
      emoji: '🚿',
      dificultad: 'fácil',
      xp: 100,
      monedas: 10,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Completa tu primer Speedrun de Ducha válido',
      progresoActual: 0,
      progresoMeta: 1,
      progresoTexto: '0/1 completado',
    ),
    AchievementItem(
      id: 'bb7de31d-0f81-42c2-80d9-2d7de9b0f73d',
      key: 'MAESTRO_ECO',
      nombre: 'Experto del Reciclaje',
      descripcion: 'Completa un Eco-Puzzle con 0 errores',
      emoji: '♻️',
      dificultad: 'medio',
      xp: 150,
      monedas: 15,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Completa un Eco-Puzzle con 0 errores',
      progresoActual: 0,
      progresoMeta: 1,
      progresoTexto: 'Pendiente',
    ),
    AchievementItem(
      id: 'b5756983-789d-4dd7-86b8-f2841d8a8417',
      key: 'CONSTANCIA_VERDE',
      nombre: 'Constancia Verde',
      descripcion: 'Alcanza una racha de 3 dias consecutivos',
      emoji: '🔥',
      dificultad: 'difícil',
      xp: 200,
      monedas: 20,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Alcanza una racha de 3 dias consecutivos',
      progresoActual: 0,
      progresoMeta: 3,
      progresoTexto: 'Racha 0/3 dias',
    ),
    AchievementItem(
      id: 'c17a582e-9d21-4fa2-bc78-9842f1a8c901',
      key: 'DUCHA_BRONCE',
      nombre: 'Ducha de Bronce',
      descripcion: 'Completa 5 duchas ecológicas válidas.',
      emoji: '🥉',
      dificultad: 'medio',
      xp: 250,
      monedas: 30,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Completa 5 duchas ecológicas válidas en 5 minutos o menos',
      progresoActual: 0,
      progresoMeta: 5,
      progresoTexto: '0/5 completadas',
    ),
    AchievementItem(
      id: 'cc8de42e-1f92-43d3-91e8-3e8ef0b1e84e',
      key: 'CEREBRO_VERDE',
      nombre: 'Cerebro Verde',
      descripcion: 'Responde correctamente 10 trivias ecológicas con puntuación perfecta.',
      emoji: '🧠',
      dificultad: 'medio',
      xp: 200,
      monedas: 20,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Responde 10 trivias ecológicas sin cometer fallos.',
      progresoActual: 0,
      progresoMeta: 10,
      progresoTexto: '0/10 completadas',
    ),
    AchievementItem(
      id: 'dd9ef53f-2003-54e4-a2f9-4f9fa1c2f95f',
      key: 'GUARDIAN_BOLETAS',
      nombre: 'Guardián de Boletas',
      descripcion: 'Escanea tus boletas de luz o agua y demuestra reducción de consumo.',
      emoji: '🧾',
      dificultad: 'difícil',
      xp: 400,
      monedas: 35,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Carga 3 boletas consecutivas con un porcentaje de ahorro energético superior al 5%.',
      progresoActual: 0,
      progresoMeta: 3,
      progresoTexto: '0/3 registradas',
    ),
    AchievementItem(
      id: 'e28b693f-0e32-4cb3-cd89-0953a2b9d012',
      key: 'DUCHA_PLATA',
      nombre: 'Ducha de Plata',
      descripcion: 'Completa 10 speedruns de ducha en menos de 5 minutos.',
      emoji: '🥈',
      dificultad: 'difícil',
      xp: 350,
      monedas: 40,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Completa 10 speedruns válidos con ahorro de agua.',
      progresoActual: 0,
      progresoMeta: 10,
      progresoTexto: '0/10 completadas',
    ),
    AchievementItem(
      id: 'f39c704a-1f43-4dc4-de90-1064b3cae123',
      key: 'DUCHA_ORO',
      nombre: 'Ducha de Oro',
      descripcion: 'Completa 20 speedruns de ducha rápida y sustentable.',
      emoji: '🥇',
      dificultad: 'difícil',
      xp: 500,
      monedas: 50,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Alcanza la excelencia con 20 speedruns en 4 minutos.',
      progresoActual: 0,
      progresoMeta: 20,
      progresoTexto: '0/20 completadas',
    ),
    AchievementItem(
      id: 'a40d815b-2a54-4ed5-ef01-2175c4dbf234',
      key: 'RACHA_LEGENDARIA',
      nombre: 'Racha Legendaria',
      descripcion: 'Mantén una racha de hábitos durante 14 días consecutivos.',
      emoji: '🔥',
      dificultad: 'difícil',
      xp: 450,
      monedas: 35,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Registra actividad sustentable durante 14 días seguidos.',
      progresoActual: 0,
      progresoMeta: 14,
      progresoTexto: 'Racha 0/14 dias',
    ),
    AchievementItem(
      id: 'b51e926c-3b65-4fe6-f012-3286d5eca345',
      key: 'MENTE_VERDE',
      nombre: 'Palabra Ecológica',
      descripcion: 'Adivina 5 palabras en Eco-Wordle con menos de 4 intentos.',
      emoji: '📝',
      dificultad: 'medio',
      xp: 200,
      monedas: 20,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Resuelve 5 desafíos diarios en Eco-Wordle.',
      progresoActual: 0,
      progresoMeta: 5,
      progresoTexto: '0/5 completadas',
    ),
    AchievementItem(
      id: 'c62f037d-4c76-40f7-0123-4397e6fdb456',
      key: 'HOGAR_SUSTENTABLE',
      nombre: 'Hogar Sustentable',
      descripcion: 'Completa 5 retos colaborativos en familia y colectas comunitarias.',
      emoji: '👨‍👩‍👧‍👦',
      dificultad: 'difícil',
      xp: 350,
      monedas: 30,
      desbloqueado: false,
      reclamado: false,
      requisito: 'Aporta y completa 5 colectas o retos colaborativos familiares.',
      progresoActual: 0,
      progresoMeta: 5,
      progresoTexto: '0/5 completados',
    ),
  ];
}
