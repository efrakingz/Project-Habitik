import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/achievement.dart';
import '../../data/models/family_member.dart';
import 'api_client.dart';
import 'session_service.dart';

/// Resultado del reclamo de recompensas de un logro
class ReclamarLogroResult {
  final bool exito;
  final int monedasGanadas;
  final int saldoMonedas;
  final String mensaje;

  const ReclamarLogroResult({
    required this.exito,
    this.monedasGanadas = 0,
    this.saldoMonedas = 0,
    required this.mensaje,
  });
}

/// Servicio Singleton para el Módulo de Logros, Medallas y Vitrina de Trofeos
/// (HU 4.2C y HU 4.2C.2).
class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  final ApiClient _apiClient = ApiClient();
  final SessionService _sessionService = SessionService();

  /// Cache en memoria de insignias de miembros familiares para evitar llamadas repetitivas
  final Map<String, String?> _memberBadgeCache = {};

  /// Retorna la insignia destacada actual desde la sesión
  String? get badgeDestacado => _sessionService.badgeDestacado;

  /// Remueve o limpia la insignia destacada actual
  Future<void> removerBadgeDestacado() async {
    await _sessionService.setBadgeDestacado(null);
    _syncBadgeDestacadoToBackend(null);
  }

  /// Enriquece la lista de miembros del hogar con sus insignias destacadas
  /// consultadas directamente desde la base de datos (/auth/perfil/:id y /logros/:id).
  Future<List<FamilyMember>> enrichMembers(List<FamilyMember> members) async {
    final current = _sessionService.currentUser;
    final String? currentSessionBadge = _sessionService.badgeDestacado;

    return Future.wait(members.map((m) async {
      final isMe = current != null &&
          (m.id == current.id ||
              (m.id.isEmpty &&
                  m.nombre.toLowerCase().trim() ==
                      current.nombre.toLowerCase().trim()));

      if (isMe) {
        final effectiveBadge =
            currentSessionBadge ?? current.badgeDestacado ?? m.badgeDestacado;
        return m.copyWith(
          xp: current.xp > 0 ? current.xp : m.xp,
          nivel: current.nivel > 0 ? current.nivel : m.nivel,
          badgeDestacado: effectiveBadge,
        );
      }

      // Si ya vino la insignia destacada en el JSON de /familia/miembros desde la BD, respetarla
      if (m.badgeDestacado != null && m.badgeDestacado!.trim().isNotEmpty) {
        return m;
      }

      // Consultar estrictamente desde la BD (/auth/perfil/:id y /logros/:id)
      final badgeFromDb = await fetchMemberBadge(m.id);
      return m.copyWith(badgeDestacado: badgeFromDb);
    }));
  }

  /// Consulta la insignia destacada de un miembro desde la base de datos (backend como única fuente de verdad)
  Future<String?> fetchMemberBadge(String memberId) async {
    if (memberId.isEmpty) return null;

    if (_memberBadgeCache.containsKey(memberId)) {
      return _memberBadgeCache[memberId];
    }

    // 1. Consultar perfil en BD (GET /auth/perfil/:id)
    try {
      final perfilRes = await _apiClient.get('/auth/perfil/$memberId');
      if (perfilRes.statusCode == 200) {
        final jsonResponse = jsonDecode(perfilRes.body);
        final dynamic data = jsonResponse['data'] ?? jsonResponse;
        if (data is Map) {
          String? badge = data['badge_destacado']?.toString() ??
              data['badgeDestacado']?.toString() ??
              data['insignia_destacada']?.toString() ??
              data['badge']?.toString();

          if (badge == null && data['avatar'] != null) {
            if (data['avatar'] is Map) {
              badge = (data['avatar'] as Map)['badge_destacado']?.toString() ??
                  (data['avatar'] as Map)['badgeDestacado']?.toString();
            } else if (data['avatar'] is String) {
              try {
                final av = jsonDecode(data['avatar']);
                if (av is Map) {
                  badge = av['badge_destacado']?.toString() ??
                      av['badgeDestacado']?.toString();
                }
              } catch (_) {}
            }
          }

          if (badge != null && badge.trim().isNotEmpty && badge != 'null') {
            _memberBadgeCache[memberId] = badge;
            return badge;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [BadgeService] Error consultando /auth/perfil/$memberId: $e');
    }

    // 2. Consultar vitrina de logros del miembro en BD (GET /logros/:id)
    try {
      final logrosRes = await _apiClient.get('/logros/$memberId');
      if (logrosRes.statusCode == 200) {
        final decoded = jsonDecode(logrosRes.body);
        List<dynamic> listaRaw = [];
        if (decoded is Map && decoded['logros'] is List) {
          listaRaw = decoded['logros'];
        } else if (decoded is Map && decoded['data'] is List) {
          listaRaw = decoded['data'];
        } else if (decoded is Map && decoded['data'] is Map && decoded['data']['logros'] is List) {
          listaRaw = decoded['data']['logros'];
        } else if (decoded is List) {
          listaRaw = decoded;
        }

        // 2a. Buscar si en la BD tiene un logro marcado como destacado
        Map? elegido;
        for (final item in listaRaw) {
          if (item is Map && (item['destacado'] == true || item['es_destacado'] == true || item['selected'] == true)) {
            elegido = item;
            break;
          }
        }

        // 2b. Si la BD no usa flag de destacado plano, tomar el logro desbloqueado en la BD
        if (elegido == null) {
          for (final item in listaRaw) {
            if (item is Map && (item['desbloqueado'] == true || item['completado'] == true || item['unlocked'] == true)) {
              elegido = item;
              break;
            }
          }
        }

        if (elegido != null) {
          final key = elegido['codigo']?.toString() ??
              elegido['key']?.toString() ??
              elegido['id']?.toString() ??
              elegido['titulo']?.toString();
          if (key != null && key.isNotEmpty && key != 'null') {
            _memberBadgeCache[memberId] = key;
            return key;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [BadgeService] Error consultando /logros/$memberId: $e');
    }

    // El backend es la única fuente de verdad: si no tiene logro desbloqueado ni destacado en la BD, es null.
    _memberBadgeCache[memberId] = null;
    return null;
  }

  /// Consulta la vitrina de logros y nivel del usuario (GET /logros/:userId).
  /// Regla Backend: Actualiza el nivel del jugador en la sesión global en vivo.
  Future<({int nivelActual, List<AchievementItem> logros})> fetchBadges(String userId) async {
    debugPrint('🏆 [BadgeService] Solicitando vitrina de logros para usuario: $userId');
    try {
      // 1. Intentar endpoint principal según guía del backend: /logros/:userId
      final response = await _apiClient.get('/logros/$userId');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return _parseBadgesResponse(decoded);
      }
    } catch (e) {
      debugPrint('⚠️ [BadgeService] Falló GET /logros/$userId: $e. Intentando ruta alterna...');
      // 2. Intentar endpoint alterno especificado en CA-4.2C.2-1: /api/usuarios/me/badges
      try {
        final response = await _apiClient.get('/api/usuarios/me/badges');
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          return _parseBadgesResponse(decoded);
        }
      } catch (e2) {
        debugPrint('⚠️ [BadgeService] Falló ruta alterna de badges: $e2');
      }
    }

    // 3. Fallback a caché local o catálogo oficial para modo offline y CP-VITRINA-01
    return _getCachedOrMockBadges();
  }

  /// Procesa defensivamente la respuesta JSON de logros
  Future<({int nivelActual, List<AchievementItem> logros})> _parseBadgesResponse(dynamic decoded) async {
    int nivel = _sessionService.currentUser?.nivel ?? 1;
    List<dynamic> listaRaw = [];

    if (decoded is Map<String, dynamic>) {
      if (decoded['nivel_actual'] != null) {
        nivel = _parseInt(decoded['nivel_actual']);
      } else if (decoded['data'] is Map && decoded['data']['nivel_actual'] != null) {
        nivel = _parseInt(decoded['data']['nivel_actual']);
      }

      if (decoded['logros'] is List) {
        listaRaw = decoded['logros'];
      } else if (decoded['data'] is List) {
        listaRaw = decoded['data'];
      } else if (decoded['data'] is Map && decoded['data']['logros'] is List) {
        listaRaw = decoded['data']['logros'];
      }
    } else if (decoded is List) {
      listaRaw = decoded;
    }

    // Actualizar nivel en vivo en SessionService si cambió
    if (_sessionService.currentUser != null && nivel > 0 && nivel != _sessionService.currentUser!.nivel) {
      await _sessionService.updateRewardsAndXp(nivel: nivel);
    }

    final String? badgeDestacadoActual = _sessionService.badgeDestacado;
    final int rachaReal = _sessionService.currentUser?.rachaDias ?? 0;

    final logros = listaRaw.map((item) {
      if (item is Map<String, dynamic>) {
        var achievement = AchievementItem.fromJson(item);
        if (badgeDestacadoActual != null &&
            (achievement.key == badgeDestacadoActual || achievement.emoji == badgeDestacadoActual)) {
          achievement = achievement.copyWith(destacado: true);
        }
        // Enriquecer progreso con datos de sesión backend si la API no envió progreso_actual
        if (!achievement.desbloqueado &&
            (achievement.key.contains('CONSTANCIA') || achievement.key.contains('RACHA')) &&
            rachaReal > 0 &&
            achievement.progresoActual == 0) {
          final actual = rachaReal.clamp(0, achievement.progresoMeta);
          achievement = achievement.copyWith(
            progresoActual: actual,
            progresoTexto: 'Racha $actual/${achievement.progresoMeta} dias',
          );
        }
        return achievement;
      }
      return AchievementItem.empty;
    }).where((a) => a.key.isNotEmpty || a.nombre.isNotEmpty).toList();

    // Guardar en caché local
    await _cacheBadgesLocally(logros);

    debugPrint('✅ [BadgeService] Se cargaron ${logros.length} logros exitosamente. Nivel: $nivel');
    return (nivelActual: nivel, logros: logros.isNotEmpty ? logros : AchievementItem.officialCatalog);
  }

  /// Reclama las monedas de una medalla desbloqueada (POST /logros/reclamar)
  Future<ReclamarLogroResult> reclamarRecompensa(String logroId) async {
    debugPrint('🎁 [BadgeService] Reclamando recompensa para logro ID: $logroId');
    try {
      final response = await _apiClient.post('/logros/reclamar', {
        'logroId': logroId,
      });

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        int monedasGanadas = 0;
        int saldoMonedas = (_sessionService.currentUser?.monedas ?? 0);

        if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is Map<String, dynamic>) {
            final data = decoded['data'] as Map<String, dynamic>;
            monedasGanadas = _parseInt(data['monedas_ganadas']);
            saldoMonedas = _parseInt(data['saldo_monedas']);
          } else if (decoded['monedas_ganadas'] != null) {
            monedasGanadas = _parseInt(decoded['monedas_ganadas']);
            saldoMonedas = _parseInt(decoded['saldo_monedas']);
          }
        }

        // Actualizar el saldo global de monedas de la app en vivo
        if (saldoMonedas > 0) {
          await _sessionService.updateRewardsAndXp(monedas: saldoMonedas);
        } else if (monedasGanadas > 0 && _sessionService.currentUser != null) {
          final nuevoSaldo = _sessionService.currentUser!.monedas + monedasGanadas;
          await _sessionService.updateRewardsAndXp(monedas: nuevoSaldo);
          saldoMonedas = nuevoSaldo;
        }

        debugPrint('✅ [BadgeService] Recompensa reclamada con éxito: +$monedasGanadas monedas. Nuevo saldo: $saldoMonedas');
        return ReclamarLogroResult(
          exito: true,
          monedasGanadas: monedasGanadas,
          saldoMonedas: saldoMonedas,
          mensaje: decoded['message']?.toString() ?? 'Monedas de logro otorgadas con éxito.',
        );
      } else {
        final msg = decoded is Map ? (decoded['message']?.toString() ?? 'Error al reclamar') : 'Error al reclamar';
        debugPrint('❌ [BadgeService] Error 400 al reclamar: $msg');
        return ReclamarLogroResult(
          exito: false,
          mensaje: msg,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [BadgeService] Excepción al reclamar logro en red: $e');
      // Modo defensivo offline o simulación:
      return ReclamarLogroResult(
        exito: false,
        mensaje: 'No se pudo conectar al servidor para reclamar la medalla.',
      );
    }
  }

  /// Alterna o establece la insignia destacada para mostrar al lado del avatar
  Future<void> alternarBadgeDestacado(AchievementItem logro) async {
    final actual = _sessionService.badgeDestacado;
    final String? newBadge = (actual == logro.key || actual == logro.emoji) ? null : logro.key;

    if (newBadge == null) {
      await _sessionService.setBadgeDestacado(null);
      debugPrint('⭐ [BadgeService] Insignia destacada removida');
    } else {
      await _sessionService.setBadgeDestacado(newBadge);
      debugPrint('⭐ [BadgeService] Nueva insignia destacada: ${logro.nombre} ($newBadge)');
    }

    // Sincronizar en segundo plano con la base de datos
    _syncBadgeDestacadoToBackend(newBadge);
  }

  Future<void> _syncBadgeDestacadoToBackend(String? badgeKey) async {
    final current = _sessionService.currentUser;
    if (current == null) return;
    try {
      await _apiClient.patch('/auth/perfil', {'badge_destacado': badgeKey});
    } catch (_) {
      try {
        await _apiClient.put('/auth/perfil/${current.id}', {'badge_destacado': badgeKey});
      } catch (_) {}
    }
  }

  /// Helper para verificar si un payload de actividad trae badge desbloqueado
  static AchievementItem? detectarBadgeDesbloqueado(Map<String, dynamic> responseData) {
    bool unlocked = false;
    dynamic badgeData;

    if (responseData['badge_unlocked'] == true) {
      unlocked = true;
      badgeData = responseData['badge_data'] ?? responseData['badge'] ?? responseData['logro'];
    } else if (responseData['data'] is Map<String, dynamic>) {
      final inner = responseData['data'] as Map<String, dynamic>;
      if (inner['badge_unlocked'] == true) {
        unlocked = true;
        badgeData = inner['badge_data'] ?? inner['badge'] ?? inner['logro'];
      }
    }

    if (unlocked) {
      if (badgeData is Map<String, dynamic>) {
        return AchievementItem.fromJson(badgeData);
      }
      return const AchievementItem(
        key: 'NUEVO_LOGRO',
        nombre: '¡Logro Desbloqueado!',
        descripcion: '¡Completaste un hito ecológico en Habitik!',
        emoji: '🏆',
        desbloqueado: true,
      );
    }
    return null;
  }

  Future<void> _cacheBadgesLocally(List<AchievementItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _sessionService.currentUser?.id ?? 'guest';
      final jsonList = list.map((a) => a.toJson()).toList();
      await prefs.setString('cached_badges_$userId', jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<({int nivelActual, List<AchievementItem> logros})> _getCachedOrMockBadges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _sessionService.currentUser?.id ?? 'guest';
      final cached = prefs.getString('cached_badges_$userId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        final list = decoded.map((e) => AchievementItem.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) {
          final String? destacado = _sessionService.badgeDestacado;
          final updatedList = list.map((item) {
            return item.copyWith(destacado: item.key == destacado || item.emoji == destacado);
          }).toList();
          return (nivelActual: _sessionService.currentUser?.nivel ?? 1, logros: updatedList);
        }
      }
    } catch (_) {}

    final String? destacado = _sessionService.badgeDestacado;
    final int rachaReal = _sessionService.currentUser?.rachaDias ?? 0;
    final catalog = AchievementItem.officialCatalog.map((item) {
      var it = item.copyWith(destacado: item.key == destacado || item.emoji == destacado);
      if (!it.desbloqueado && (it.key.contains('CONSTANCIA') || it.key.contains('RACHA')) && rachaReal > 0) {
        final actual = rachaReal.clamp(0, it.progresoMeta);
        it = it.copyWith(
          progresoActual: actual,
          progresoTexto: 'Racha $actual/${it.progresoMeta} dias',
        );
      }
      return it;
    }).toList();

    return (nivelActual: _sessionService.currentUser?.nivel ?? 1, logros: catalog);
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
