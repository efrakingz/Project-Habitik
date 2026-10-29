import 'dart:convert';

class FamilyMember {
  final String id;
  final String nombre;
  final String rol;
  final int xp;
  final int xpSemanal;
  final int nivel;
  final int rachaDias;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;
  final String? badgeDestacado;

  const FamilyMember({
    this.id = '',
    required this.nombre,
    required this.rol,
    required this.xp,
    this.xpSemanal = 0,
    required this.nivel,
    this.rachaDias = 0,
    required this.avatarLetra,
    required this.avatarColor,
    this.avatarUrl,
    this.badgeDestacado,
  });

  bool get isJefe {
    final r = rol.toLowerCase().trim();
    return r == 'jefe' || r == 'jefa' || r == 'admin' || r == 'co-admin';
  }

  FamilyMember copyWith({
    String? id,
    String? nombre,
    String? rol,
    int? xp,
    int? xpSemanal,
    int? nivel,
    int? rachaDias,
    String? avatarLetra,
    String? avatarColor,
    String? avatarUrl,
    String? badgeDestacado,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      xp: xp ?? this.xp,
      xpSemanal: xpSemanal ?? this.xpSemanal,
      nivel: nivel ?? this.nivel,
      rachaDias: rachaDias ?? this.rachaDias,
      avatarLetra: avatarLetra ?? this.avatarLetra,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      badgeDestacado: badgeDestacado ?? this.badgeDestacado,
    );
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    String letra = 'U';
    String color = '#43A047';
    String? url;

    String? badge;

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
        badge = avMap['badge_destacado']?.toString() ??
            avMap['badgeDestacado']?.toString() ??
            avMap['badge']?.toString() ??
            avMap['insignia']?.toString() ??
            avMap['insignia_destacada']?.toString() ??
            avMap['medalla']?.toString();
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
            badge = avMap['badge_destacado']?.toString() ??
                avMap['badgeDestacado']?.toString() ??
                avMap['badge']?.toString() ??
                avMap['insignia']?.toString() ??
                avMap['insignia_destacada']?.toString() ??
                avMap['medalla']?.toString();
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

    // Buscar en la raíz de json si no estaba en avatar
    badge ??= json['badge_destacado']?.toString() ??
        json['badgeDestacado']?.toString() ??
        json['insignia_destacada']?.toString() ??
        json['insigniaDestacada']?.toString() ??
        json['medalla_destacada']?.toString() ??
        json['medallaDestacada']?.toString() ??
        json['badge']?.toString() ??
        json['insignia']?.toString() ??
        json['medalla']?.toString() ??
        json['logro']?.toString() ??
        json['logro_destacado']?.toString() ??
        json['logroDestacado']?.toString() ??
        json['badge_id']?.toString() ??
        json['badgeId']?.toString();

    // Si viene anidado en usuario / user
    if (badge == null) {
      final userObj = json['usuario'] ?? json['user'];
      if (userObj is Map) {
        badge = userObj['badge_destacado']?.toString() ??
            userObj['badgeDestacado']?.toString() ??
            userObj['insignia_destacada']?.toString() ??
            userObj['badge']?.toString();
      }
    }

    // Si viene lista de logros/badges del miembro en el JSON de /familia/miembros
    if (badge == null) {
      if (json['logros'] is List && (json['logros'] as List).isNotEmpty) {
        final logrosList = json['logros'] as List;
        Map? elegido;
        for (final item in logrosList) {
          if (item is Map && (item['destacado'] == true || item['es_destacado'] == true || item['selected'] == true)) {
            elegido = item;
            break;
          }
        }
        if (elegido == null) {
          for (final item in logrosList) {
            if (item is Map && (item['desbloqueado'] == true || item['completado'] == true || item['unlocked'] == true)) {
              elegido = item;
              break;
            }
          }
        }
        if (elegido != null) {
          badge = elegido['codigo']?.toString() ??
              elegido['key']?.toString() ??
              elegido['titulo']?.toString() ??
              elegido['nombre']?.toString();
        }
      } else if (json['badges'] is List && (json['badges'] as List).isNotEmpty) {
        final badgesList = json['badges'] as List;
        Map? elegido;
        for (final item in badgesList) {
          if (item is Map && (item['destacado'] == true || item['selected'] == true)) {
            elegido = item;
            break;
          }
        }
        if (elegido == null) {
          for (final item in badgesList) {
            if (item is Map && (item['desbloqueado'] == true || item['unlocked'] == true)) {
              elegido = item;
              break;
            }
          }
        }
        if (elegido != null) {
          badge = elegido['codigo']?.toString() ??
              elegido['key']?.toString() ??
              elegido['name']?.toString() ??
              elegido['title']?.toString();
        }
      }
    }

    return FamilyMember(
      id: json['id']?.toString() ??
          json['user_id']?.toString() ??
          json['usuario_id']?.toString() ??
          json['id_usuario']?.toString() ??
          json['userId']?.toString() ??
          '',
      nombre: json['nombre'] ?? '',
      rol: (json['rol'] ?? 'miembro').toString().toLowerCase(),
      xp: (json['xp_total'] ?? json['total_xp'] ?? json['xp']) is num
          ? ((json['xp_total'] ?? json['total_xp'] ?? json['xp']) as num).toInt()
          : int.tryParse('${json['xp_total'] ?? json['total_xp'] ?? json['xp']}') ?? 0,
      xpSemanal: (json['xp_semanal'] ?? json['weekly_xp']) is num
          ? ((json['xp_semanal'] ?? json['weekly_xp']) as num).toInt()
          : int.tryParse('${json['xp_semanal'] ?? json['weekly_xp']}') ?? 0,
      nivel: json['nivel'] is num
          ? (json['nivel'] as num).toInt()
          : int.tryParse('${json['nivel']}') ?? 1,
      rachaDias: (json['racha_dias'] ?? json['racha']) is num
          ? ((json['racha_dias'] ?? json['racha']) as num).toInt()
          : int.tryParse('${json['racha_dias'] ?? json['racha']}') ?? 0,
      avatarLetra: letra,
      avatarColor: color,
      avatarUrl: url,
      badgeDestacado: badge,
    );
  }
}
