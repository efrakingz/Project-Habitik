import 'dart:convert';

class UserProfile {
  final String id;
  final String nombre;
  final String? email;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;
  final String rol;
  final String? familyId;
  final int xp;
  final int nivel;
  final int monedas;
  final String? familyName;
  final bool onboardingCompleted;

  const UserProfile({
    this.id = '',
    required this.nombre,
    this.email,
    this.avatarLetra = 'U',
    this.avatarColor = '#43A047',
    this.avatarUrl,
    this.rol = 'miembro',
    this.familyId,
    this.xp = 0,
    this.nivel = 1,
    this.monedas = 0,
    this.familyName,
    this.onboardingCompleted = false,
  });

  bool get isJefe {
    final r = rol.toLowerCase().trim();
    return r == 'jefe' || r == 'jefa' || r == 'admin' || r == 'co-admin';
  }

  bool get isMiembro => !isJefe;

  UserProfile copyWith({
    String? id,
    String? nombre,
    String? email,
    String? avatarLetra,
    String? avatarColor,
    String? avatarUrl,
    String? rol,
    String? familyId,
    int? xp,
    int? nivel,
    int? monedas,
    String? familyName,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarLetra: avatarLetra ?? this.avatarLetra,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rol: rol ?? this.rol,
      familyId: familyId ?? this.familyId,
      xp: xp ?? this.xp,
      nivel: nivel ?? this.nivel,
      monedas: monedas ?? this.monedas,
      familyName: familyName ?? this.familyName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // 1. Extracción de Avatar Híbrido (JSONB Map o String vs columnas planas)
    String letra = 'U';
    String color = '#43A047';
    String? url;

    if (json['avatar'] != null && json['avatar'].toString() != 'null') {
      if (json['avatar'] is Map) {
        final avMap = json['avatar'] as Map;
        letra =
            avMap['letra']?.toString() ??
            (json['nombre'] != null && json['nombre'].toString().isNotEmpty
                ? json['nombre'].toString()[0].toUpperCase()
                : 'U');
        color = avMap['color']?.toString() ?? '#43A047';
        url = avMap['url']?.toString();
      } else if (json['avatar'] is String) {
        try {
          final avMap = jsonDecode(json['avatar']);
          if (avMap is Map) {
            letra =
                avMap['letra']?.toString() ??
                (json['nombre'] != null && json['nombre'].toString().isNotEmpty
                    ? json['nombre'].toString()[0].toUpperCase()
                    : 'U');
            color = avMap['color']?.toString() ?? '#43A047';
            url = avMap['url']?.toString();
          }
        } catch (_) {}
      }
    } else {
      letra =
          json['avatar_letra'] ??
          (json['nombre'] != null && json['nombre'].toString().isNotEmpty
              ? json['nombre'].toString()[0].toUpperCase()
              : 'U');
      color = json['avatar_color'] ?? '#43A047';
      url = json['avatar_url'];
    }

    // 2. Validación de Onboarding
    final answers = json['onboarding_answers'];
    bool hasValidAnswers = false;
    if (answers != null && answers.toString() != 'null') {
      if (answers is Map) {
        hasValidAnswers = answers.isNotEmpty;
      } else if (answers is String) {
        final trimmed = answers.trim();
        if (trimmed.isNotEmpty && trimmed != '{}' && trimmed != '[]') {
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is Map) {
              hasValidAnswers = decoded.isNotEmpty;
            } else if (decoded is List) {
              hasValidAnswers = decoded.isNotEmpty;
            } else {
              hasValidAnswers = true;
            }
          } catch (_) {
            hasValidAnswers = true;
          }
        }
      } else {
        hasValidAnswers = true;
      }
    }
    final hasCompletedFlag =
        json['onboarding_completed'] == true ||
        json['onboardingCompleted'] == true;

    return UserProfile(
      id: json['id'] ?? json['user_id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'],
      avatarLetra: letra,
      avatarColor: color,
      avatarUrl: url,
      rol: (json['rol'] ?? 'miembro').toString().toLowerCase(),
      familyId: json['family_id'],
      xp: json['xp'] is num
          ? (json['xp'] as num).toInt()
          : int.tryParse('${json['xp']}') ?? 0,
      nivel: json['nivel'] is num
          ? (json['nivel'] as num).toInt()
          : int.tryParse('${json['nivel']}') ?? 1,
      monedas: json['monedas'] is num
          ? (json['monedas'] as num).toInt()
          : int.tryParse('${json['monedas']}') ?? 0,
      familyName: json['family_name'],
      onboardingCompleted: hasValidAnswers || hasCompletedFlag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'avatar_letra': avatarLetra,
      'avatar_color': avatarColor,
      'avatar_url': avatarUrl,
      'rol': rol,
      'family_id': familyId,
      'xp': xp,
      'nivel': nivel,
      'monedas': monedas,
      'family_name': familyName,
      'onboarding_completed': onboardingCompleted,
    };
  }

  static UserProfile get mock => const UserProfile(
    id: 'mock-user-1',
    nombre: 'Sofía Torres',
    email: 'sofia@habitik.cl',
    avatarLetra: 'S',
    avatarColor: '#9C27B0',
    rol: 'jefa',
    familyId: 'mock-family',
    xp: 350,
    nivel: 3,
    monedas: 42,
    familyName: 'Familia Torres',
    onboardingCompleted: true,
  );

  static UserProfile get mockJefe => const UserProfile(
    id: 'mock-jefe',
    nombre: 'Carlos Torres',
    email: 'carlos@habitik.cl',
    avatarLetra: 'C',
    avatarColor: '#2E7D32',
    rol: 'jefe',
    familyId: 'mock-family',
    xp: 820,
    nivel: 5,
    monedas: 80,
    familyName: 'Familia Torres',
    onboardingCompleted: true,
  );
}
