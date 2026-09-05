import 'dart:convert';

class FamilyMember {
  final String id;
  final String nombre;
  final String rol;
  final int xp;
  final int nivel;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;

  const FamilyMember({
    this.id = '',
    required this.nombre,
    required this.rol,
    required this.xp,
    required this.nivel,
    required this.avatarLetra,
    required this.avatarColor,
    this.avatarUrl,
  });

  FamilyMember copyWith({
    String? id,
    String? nombre,
    String? rol,
    int? xp,
    int? nivel,
    String? avatarLetra,
    String? avatarColor,
    String? avatarUrl,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      xp: xp ?? this.xp,
      nivel: nivel ?? this.nivel,
      avatarLetra: avatarLetra ?? this.avatarLetra,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
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

    return FamilyMember(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      rol: (json['rol'] ?? 'miembro').toString().toLowerCase(),
      xp: (json['xp_total'] ?? json['total_xp'] ?? json['xp']) is num
          ? ((json['xp_total'] ?? json['total_xp'] ?? json['xp']) as num).toInt()
          : int.tryParse('${json['xp_total'] ?? json['total_xp'] ?? json['xp']}') ?? 0,
      nivel: json['nivel'] is num
          ? (json['nivel'] as num).toInt()
          : int.tryParse('${json['nivel']}') ?? 1,
      avatarLetra: letra,
      avatarColor: color,
      avatarUrl: url,
    );
  }
}
