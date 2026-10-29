/// Modelo para los elementos del Feed Social Familiar en Tiempo Real (CA-4.1-3)
class FamilyFeedItem {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String rolUsuario;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;
  final String tipoReto; // 'speedrun_ducha', 'trivia', 'puzzle', 'wordle', etc.
  final String tituloReto;
  final String descripcion;
  final String? imagenUrl;
  final int xpGanada;
  final int monedasGanadas;
  final DateTime fecha;
  final Map<String, int> reacciones;
  final Set<String> misReacciones;
  final String? miReaccion;
  final String? badgeDestacado;

  const FamilyFeedItem({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    this.rolUsuario = 'Miembro',
    required this.avatarLetra,
    required this.avatarColor,
    this.avatarUrl,
    required this.tipoReto,
    required this.tituloReto,
    required this.descripcion,
    this.imagenUrl,
    required this.xpGanada,
    required this.monedasGanadas,
    required this.fecha,
    this.reacciones = const {'👏': 0, '🔥': 0, '💧': 0, '❤️': 0},
    this.misReacciones = const {},
    this.miReaccion,
    this.badgeDestacado,
  });

  /// Mapeos estándar entre claves del backend y emojis de la UI
  static const Map<String, String> keyToEmoji = {
    'fuego': '🔥',
    'aplauso': '👏',
    'corazon': '❤️',
    'planta': '🌱',
    'gota': '💧',
    'like': '👍',
  };

  static const Map<String, String> emojiToKey = {
    '🔥': 'fuego',
    '👏': 'aplauso',
    '❤️': 'corazon',
    '🌱': 'planta',
    '💧': 'gota',
    '👍': 'like',
  };

  /// Mapea un diccionario de conteo del backend a emojis y claves compatibles
  static Map<String, int> mapReaccionesConteo(Map raw) {
    final Map<String, int> result = {'👏': 0, '🔥': 0, '💧': 0, '❤️': 0};
    raw.forEach((k, v) {
      final keyStr = k.toString().toLowerCase();
      final count = _parseInt(v);
      result[keyStr] = count;
      final emoji = keyToEmoji[keyStr];
      if (emoji != null) {
        result[emoji] = count;
      }
    });
    return result;
  }

  FamilyFeedItem copyWith({
    String? id,
    String? usuarioId,
    String? nombreUsuario,
    String? rolUsuario,
    String? avatarLetra,
    String? avatarColor,
    String? avatarUrl,
    String? tipoReto,
    String? tituloReto,
    String? descripcion,
    String? imagenUrl,
    int? xpGanada,
    int? monedasGanadas,
    DateTime? fecha,
    Map<String, int>? reacciones,
    Set<String>? misReacciones,
    String? miReaccion,
    String? badgeDestacado,
  }) {
    return FamilyFeedItem(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      rolUsuario: rolUsuario ?? this.rolUsuario,
      avatarLetra: avatarLetra ?? this.avatarLetra,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tipoReto: tipoReto ?? this.tipoReto,
      tituloReto: tituloReto ?? this.tituloReto,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      xpGanada: xpGanada ?? this.xpGanada,
      monedasGanadas: monedasGanadas ?? this.monedasGanadas,
      fecha: fecha ?? this.fecha,
      reacciones: reacciones ?? this.reacciones,
      misReacciones: misReacciones ?? this.misReacciones,
      miReaccion: miReaccion ?? this.miReaccion,
      badgeDestacado: badgeDestacado ?? this.badgeDestacado,
    );
  }

  /// Retorna un formato amigable y relativo de tiempo
  String get tiempoRelativo {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  factory FamilyFeedItem.fromJson(Map<String, dynamic> json) {
    // 1. Parseo de Avatar (puede venir como objeto {url, color, letra} o individual)
    String? avatarUrl;
    String avatarColor = '#43A047';
    String avatarLetra = 'F';

    final rawAvatar = json['avatar'];
    if (rawAvatar is Map) {
      avatarUrl = rawAvatar['url']?.toString();
      avatarColor = rawAvatar['color']?.toString() ?? '#43A047';
      avatarLetra = rawAvatar['letra']?.toString() ?? 'F';
    } else {
      avatarUrl = json['avatar_url']?.toString() ?? json['avatarUrl']?.toString();
      avatarColor = json['avatar_color']?.toString() ?? '#43A047';
      avatarLetra = json['avatar_letra']?.toString() ?? 'F';
    }

    final nombreUsuario = json['nombre']?.toString() ??
        json['nombre_usuario']?.toString() ??
        'Familiar';

    if (avatarLetra.isEmpty && nombreUsuario.isNotEmpty) {
      avatarLetra = nombreUsuario[0].toUpperCase();
    }

    // 2. Tipo y Título del Reto / Actividad
    final rawTipo = json['tipo']?.toString() ??
        json['tipo_reto']?.toString() ??
        json['origen_actividad']?.toString() ??
        'reto';
    final normalizedTipo = _normalizeTipoReto(rawTipo);
    final tituloReto = json['titulo_reto']?.toString() ?? _deriveTitle(rawTipo);
    final descripcion = json['mensaje']?.toString() ??
        json['descripcion']?.toString() ??
        '';

    // 3. Recompensas (XP y Monedas)
    int xp = 0;
    int monedas = 0;
    if (json['recompensas'] is Map) {
      final r = json['recompensas'] as Map;
      xp = _parseInt(r['xp']);
      monedas = _parseInt(r['monedas']);
    } else {
      xp = _parseInt(json['xp_ganada'] ?? json['xp_otorgada'] ?? json['xp']);
      monedas = _parseInt(
        json['monedas_ganadas'] ?? json['monedas_otorgadas'] ?? json['monedas'],
      );
    }

    // 4. Reacciones y Mi Reacción
    final rawReaccionesConteo = json['reacciones_conteo'];
    final rawReacciones = json['reacciones'];
    Map<String, int> reaccMap = {'👏': 0, '🔥': 0, '💧': 0, '❤️': 0};

    if (rawReaccionesConteo is Map) {
      reaccMap = mapReaccionesConteo(rawReaccionesConteo);
    } else if (rawReacciones is Map) {
      for (final key in ['👏', '🔥', '💧', '❤️']) {
        final val = rawReacciones[key];
        reaccMap[key] = _parseInt(val);
      }
    }

    final String? miReacc = json['mi_reaccion']?.toString();
    final Set<String> misReaccSet = {};
    if (miReacc != null && miReacc.isNotEmpty) {
      misReaccSet.add(miReacc);
      final emoji = keyToEmoji[miReacc.toLowerCase()];
      if (emoji != null) misReaccSet.add(emoji);
    }
    final rawMisReacc = json['mis_reacciones'];
    if (rawMisReacc is List) {
      misReaccSet.addAll(rawMisReacc.map((e) => e.toString()));
    }

    return FamilyFeedItem(
      id: json['id']?.toString() ?? '',
      usuarioId: json['user_id']?.toString() ?? json['usuario_id']?.toString() ?? '',
      nombreUsuario: nombreUsuario,
      rolUsuario: json['rol_usuario']?.toString() ?? json['rol']?.toString() ?? 'Miembro',
      avatarLetra: avatarLetra,
      avatarColor: avatarColor,
      avatarUrl: avatarUrl,
      tipoReto: normalizedTipo,
      tituloReto: tituloReto,
      descripcion: descripcion,
      imagenUrl: json['imagen_url']?.toString() ?? json['imagenUrl']?.toString(),
      xpGanada: xp,
      monedasGanadas: monedas,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      reacciones: reaccMap,
      misReacciones: misReaccSet,
      miReaccion: miReacc,
      badgeDestacado: json['badge_destacado']?.toString() ?? json['badgeDestacado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre_usuario': nombreUsuario,
    'rol_usuario': rolUsuario,
    'avatar_letra': avatarLetra,
    'avatar_color': avatarColor,
    'avatar_url': avatarUrl,
    'tipo_reto': tipoReto,
    'titulo_reto': tituloReto,
    'descripcion': descripcion,
    'imagen_url': imagenUrl,
    'xp_ganada': xpGanada,
    'monedas_ganadas': monedasGanadas,
    'fecha': fecha.toIso8601String(),
    'reacciones': reacciones,
    'mis_reacciones': misReacciones.toList(),
    'mi_reaccion': miReaccion,
    'badge_destacado': badgeDestacado,
  };

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static String _normalizeTipoReto(String tipo) {
    final t = tipo.toLowerCase().trim();
    if (t.contains('ducha')) return 'ducha';
    if (t.contains('trivia')) return 'trivia';
    if (t.contains('puzzle')) return 'puzzle';
    if (t.contains('wordle')) return 'wordle';
    if (t.contains('tarea')) return 'inspeccion';
    if (t.contains('evidencia') || t.contains('reto')) return 'inspeccion';
    if (t.contains('canje')) return 'pesca';
    return t;
  }

  static String _deriveTitle(String tipo) {
    switch (tipo.toLowerCase().trim()) {
      case 'speedrun_ducha':
      case 'ducha':
        return 'Ducha Speedrun';
      case 'tarea_completada':
      case 'tarea':
        return 'Tarea del Hogar';
      case 'reto_evidencia':
      case 'reto':
        return 'Reto Ecológico';
      case 'evidencia_accion':
        return 'Evidencia Familiar';
      case 'logro':
        return 'Logro Desbloqueado';
      case 'canje':
        return 'Canje en Tienda';
      case 'eco_puzzle':
      case 'puzzle':
        return 'Eco-Puzzle';
      case 'wordle':
      case 'eco_wordle':
        return 'Eco-Wordle';
      case 'trivia':
        return 'Trivia Ecológica';
      case 'bonus_constancia':
        return 'Bonus de Constancia';
      case 'recompensa_nivel':
        return 'Subida de Nivel';
      default:
        return 'Actividad Familiar';
    }
  }

  /// Lista representativa de mock feeds
  static List<FamilyFeedItem> get mockList => [
    FamilyFeedItem(
      id: 'feed_1',
      usuarioId: 'u_1',
      nombreUsuario: 'Sofía',
      rolUsuario: 'Hija',
      avatarLetra: 'S',
      avatarColor: '#E91E63',
      tipoReto: 'trivia',
      tituloReto: 'Trivia Ecológica',
      descripcion: 'Completó 8 preguntas consecutivas sin perder vidas.',
      xpGanada: 120,
      monedasGanadas: 2,
      fecha: DateTime.now().subtract(const Duration(minutes: 8)),
      reacciones: const {'👏': 4, '🔥': 5, '💧': 1, '❤️': 3},
      misReacciones: const {'🔥'},
      badgeDestacado: '🧠',
    ),
    FamilyFeedItem(
      id: 'feed_2',
      usuarioId: 'u_2',
      nombreUsuario: 'Papá',
      rolUsuario: 'Jefe de Hogar',
      avatarLetra: 'P',
      avatarColor: '#2E7D32',
      tipoReto: 'ducha',
      tituloReto: 'Ducha Speedrun',
      descripcion: 'Se duchó en 3m 42s y ahorró más de 45 litros de agua.',
      xpGanada: 100,
      monedasGanadas: 3,
      fecha: DateTime.now().subtract(const Duration(minutes: 25)),
      reacciones: const {'👏': 3, '🔥': 2, '💧': 6, '❤️': 2},
      misReacciones: const {'💧'},
      badgeDestacado: '🚿',
    ),
    FamilyFeedItem(
      id: 'feed_3',
      usuarioId: 'u_3',
      nombreUsuario: 'Mateo',
      rolUsuario: 'Hijo',
      avatarLetra: 'M',
      avatarColor: '#1976D2',
      tipoReto: 'wordle',
      tituloReto: 'Eco-Wordle',
      descripcion: 'Adivinó la palabra ecológica del día al 3er intento.',
      xpGanada: 90,
      monedasGanadas: 2,
      fecha: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
      reacciones: const {'👏': 5, '🔥': 4, '💧': 0, '❤️': 4},
      misReacciones: const {},
    ),
    FamilyFeedItem(
      id: 'feed_4',
      usuarioId: 'u_4',
      nombreUsuario: 'Mamá',
      rolUsuario: 'Jefa de Hogar',
      avatarLetra: 'M',
      avatarColor: '#9C27B0',
      tipoReto: 'puzzle',
      tituloReto: 'Eco-Puzzle',
      descripcion: 'Clasificó 15 residuos en sus contenedores correctos.',
      xpGanada: 150,
      monedasGanadas: 4,
      fecha: DateTime.now().subtract(const Duration(hours: 3)),
      reacciones: const {'👏': 6, '🔥': 3, '💧': 2, '❤️': 5},
      misReacciones: const {'❤️'},
      badgeDestacado: '♻️',
    ),
  ];
}

