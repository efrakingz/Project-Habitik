/// Modelo para los elementos del Feed Social Familiar en Tiempo Real (CA-4.1-3)
class FamilyFeedItem {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String rolUsuario;
  final String avatarLetra;
  final String avatarColor;
  final String tipoReto; // 'ducha', 'trivia', 'puzzle', 'wordle', etc.
  final String tituloReto;
  final String descripcion;
  final int xpGanada;
  final int monedasGanadas;
  final DateTime fecha;
  final Map<String, int> reacciones;
  final Set<String> misReacciones;

  const FamilyFeedItem({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    this.rolUsuario = 'Miembro',
    required this.avatarLetra,
    required this.avatarColor,
    required this.tipoReto,
    required this.tituloReto,
    required this.descripcion,
    required this.xpGanada,
    required this.monedasGanadas,
    required this.fecha,
    this.reacciones = const {'👏': 0, '🔥': 0, '💧': 0, '❤️': 0},
    this.misReacciones = const {},
  });

  FamilyFeedItem copyWith({
    String? id,
    String? usuarioId,
    String? nombreUsuario,
    String? rolUsuario,
    String? avatarLetra,
    String? avatarColor,
    String? tipoReto,
    String? tituloReto,
    String? descripcion,
    int? xpGanada,
    int? monedasGanadas,
    DateTime? fecha,
    Map<String, int>? reacciones,
    Set<String>? misReacciones,
  }) {
    return FamilyFeedItem(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      rolUsuario: rolUsuario ?? this.rolUsuario,
      avatarLetra: avatarLetra ?? this.avatarLetra,
      avatarColor: avatarColor ?? this.avatarColor,
      tipoReto: tipoReto ?? this.tipoReto,
      tituloReto: tituloReto ?? this.tituloReto,
      descripcion: descripcion ?? this.descripcion,
      xpGanada: xpGanada ?? this.xpGanada,
      monedasGanadas: monedasGanadas ?? this.monedasGanadas,
      fecha: fecha ?? this.fecha,
      reacciones: reacciones ?? this.reacciones,
      misReacciones: misReacciones ?? this.misReacciones,
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
    final rawReacciones = json['reacciones'];
    final Map<String, int> reaccMap = {'👏': 0, '🔥': 0, '💧': 0, '❤️': 0};
    if (rawReacciones is Map) {
      for (final key in ['👏', '🔥', '💧', '❤️']) {
        final val = rawReacciones[key];
        if (val is num) {
          reaccMap[key] = val.toInt();
        } else if (val != null) {
          reaccMap[key] = int.tryParse('$val') ?? 0;
        }
      }
    }

    final rawMisReacc = json['mis_reacciones'];
    final Set<String> misReaccSet = {};
    if (rawMisReacc is List) {
      misReaccSet.addAll(rawMisReacc.map((e) => e.toString()));
    }

    return FamilyFeedItem(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString() ?? '',
      nombreUsuario: json['nombre_usuario']?.toString() ?? 'Familiar',
      rolUsuario: json['rol_usuario']?.toString() ?? 'Miembro',
      avatarLetra: json['avatar_letra']?.toString() ?? 'F',
      avatarColor: json['avatar_color']?.toString() ?? '#43A047',
      tipoReto: json['tipo_reto']?.toString() ?? 'trivia',
      tituloReto: json['titulo_reto']?.toString() ?? 'Reto Ecológico',
      descripcion: json['descripcion']?.toString() ?? '',
      xpGanada: json['xp_ganada'] is num
          ? (json['xp_ganada'] as num).toInt()
          : int.tryParse('${json['xp_ganada']}') ?? 0,
      monedasGanadas: json['monedas_ganadas'] is num
          ? (json['monedas_ganadas'] as num).toInt()
          : int.tryParse('${json['monedas_ganadas']}') ?? 0,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reacciones: reaccMap,
      misReacciones: misReaccSet,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre_usuario': nombreUsuario,
    'rol_usuario': rolUsuario,
    'avatar_letra': avatarLetra,
    'avatar_color': avatarColor,
    'tipo_reto': tipoReto,
    'titulo_reto': tituloReto,
    'descripcion': descripcion,
    'xp_ganada': xpGanada,
    'monedas_ganadas': monedasGanadas,
    'fecha': fecha.toIso8601String(),
    'reacciones': reacciones,
    'mis_reacciones': misReacciones.toList(),
  };

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
    ),
  ];
}
