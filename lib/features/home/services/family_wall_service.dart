import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/badge_service.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/data/models/family_energy_model.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/data/models/user.dart';

/// Servicio para el Muro Social Familiar (HU 4.1).
/// Conecta con la API para los miembros reales, feed social cronológico
/// y reacciones en tiempo real vía WebSockets.
class FamilyWallService extends ChangeNotifier {
  static final FamilyWallService _instance = FamilyWallService._internal();
  factory FamilyWallService() => _instance;
  FamilyWallService._internal() {
    _initSocketSubscription();
    SessionService().currentUserNotifier.addListener(_onCurrentUserChanged);
  }

  void _onCurrentUserChanged() {
    final user = SessionService().currentUserNotifier.value;
    if (user != null) {
      updateMemberProfile(user);
    }
  }

  final FamilyEnergyModel _energy = FamilyEnergyModel.mockDefault;
  List<FamilyMember> _members = [];
  List<FamilyFeedItem> _feed = [];
  bool _isLoading = false;
  bool _membersLoading = false;
  String? _membersError;

  bool _feedLoading = false;
  String? _feedError;
  bool _hasMore = false;
  String? _nextCursor;
  bool _isLoadingMore = false;

  VoidCallback? _socketUnsubscribe;

  // StreamController para eventos en tiempo real (CA-4.1-3)
  final StreamController<FamilyFeedItem> _realtimeFeedController =
      StreamController<FamilyFeedItem>.broadcast();

  FamilyEnergyModel get energy => _energy;
  List<FamilyMember> get members => List.unmodifiable(_members);
  List<FamilyFeedItem> get feed => List.unmodifiable(_feed);
  bool get isLoading => _isLoading;
  bool get membersLoading => _membersLoading;
  String? get membersError => _membersError;
  bool get feedLoading => _feedLoading;
  String? get feedError => _feedError;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  Stream<FamilyFeedItem> get realtimeStream => _realtimeFeedController.stream;

  void _initSocketSubscription() {
    _socketUnsubscribe?.call();
    _socketUnsubscribe = SocketService.subscribe(_onSocketEvent);
  }

  /// Escucha eventos de Socket.io en tiempo real
  void _onSocketEvent(Map<String, dynamic> data) {
    try {
      final tipo = data['tipo'];
      if (tipo == 'FEED_REACCION') {
        final payload = data['payload'];
        if (payload is Map) {
          _applyReactionUpdate(payload);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [FamilyWallService] Error procesando evento de feed en socket: $e');
    }
  }

  /// Aplica actualización en vivo de reacciones proveniente de WebSockets
  void _applyReactionUpdate(Map payload) {
    final feedId = payload['feed_id']?.toString();
    if (feedId == null) return;

    final index = _feed.indexWhere((it) => it.id == feedId);
    if (index == -1) return;

    final item = _feed[index];
    final rawConteo = payload['reacciones_conteo'];

    Map<String, int> newReacciones = Map.from(item.reacciones);
    if (rawConteo is Map) {
      newReacciones = FamilyFeedItem.mapReaccionesConteo(rawConteo);
    }

    // Si el evento lo generó el usuario actual, actualizar su estado local
    final currentUserId = SessionService().currentUser?.id;
    final eventUserId = payload['user_id']?.toString();
    Set<String> newMisReacciones = Set.from(item.misReacciones);
    String? newMiReaccion = item.miReaccion;

    if (eventUserId != null && currentUserId != null && eventUserId == currentUserId) {
      final tipoKey = payload['tipo']?.toString();
      final accion = payload['accion']?.toString();
      final emoji = FamilyFeedItem.keyToEmoji[tipoKey] ?? tipoKey;

      if (accion == 'eliminada') {
        if (emoji != null) newMisReacciones.remove(emoji);
        if (tipoKey != null) newMisReacciones.remove(tipoKey);
        newMiReaccion = null;
      } else {
        newMisReacciones.clear();
        if (emoji != null) newMisReacciones.add(emoji);
        if (tipoKey != null) newMisReacciones.add(tipoKey);
        newMiReaccion = tipoKey;
      }
    }

    _feed[index] = item.copyWith(
      reacciones: newReacciones,
      misReacciones: newMisReacciones,
      miReaccion: newMiReaccion,
    );
    notifyListeners();
  }

  /// Carga de datos del muro (miembros reales del hogar + feed real)
  Future<void> loadWallData({bool notify = true}) async {
    _isLoading = true;
    _membersLoading = true;
    _feedLoading = true;
    _membersError = null;
    _feedError = null;
    if (notify) notifyListeners();

    final user = SessionService().currentUser;
    final hasFamily = user != null && user.familyId != null && user.familyId!.isNotEmpty;

    // 1. Cargar miembros del ranking familiar
    if (hasFamily) {
      try {
        final path = '/familia/miembros?family_id=${user.familyId}';
        final response = await ApiClient().get(path);
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          final raw = data.map((json) {
            final m = FamilyMember.fromJson(json as Map<String, dynamic>);
            return m.id == user.id
                ? m.copyWith(
                    xp: user.xp,
                    nivel: user.nivel,
                    nombre: user.nombre,
                    avatarColor: user.avatarColor,
                    avatarLetra: user.avatarLetra,
                    avatarUrl: user.avatarUrl,
                  )
                : m;
          }).toList();
          final enriched = await BadgeService().enrichMembers(raw);
          enriched.sort((a, b) => b.xp.compareTo(a.xp));
          _members = enriched;
        }
      } catch (e) {
        debugPrint('⚠️ [FamilyWallService] Error al cargar miembros familiares: $e');
        _membersError = e.toString().replaceAll('Exception:', '').trim();
      } finally {
        _membersLoading = false;
      }
    } else {
      _members = [];
      _membersLoading = false;
    }

    // 2. Cargar feed familiar desde la API
    if (hasFamily) {
      try {
        final feedResponse = await ApiClient().get('/feed?limit=20');
        if (feedResponse.statusCode >= 200 && feedResponse.statusCode < 300) {
          final dynamic body = jsonDecode(feedResponse.body);
          if (body is Map && body['data'] is List) {
            final List items = body['data'] as List;
            _feed = items
                .map((e) => FamilyFeedItem.fromJson(e as Map<String, dynamic>))
                .toList();

            final pagination = body['pagination'];
            if (pagination is Map) {
              _hasMore = pagination['has_more'] == true;
              _nextCursor = pagination['next_cursor']?.toString();
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ [FamilyWallService] Error al cargar feed del muro: $e');
        _feedError = e.toString().replaceAll('Exception:', '').trim();
        if (_feed.isEmpty) {
          _feed = List.from(FamilyFeedItem.mockList);
        }
      } finally {
        _feedLoading = false;
      }
    } else {
      if (_feed.isEmpty) {
        _feed = List.from(FamilyFeedItem.mockList);
      }
      _feedLoading = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cargar siguiente página de publicaciones del muro (Scroll infinito / paginación)
  Future<void> fetchMoreFeed() async {
    if (!_hasMore || _isLoadingMore || _nextCursor == null) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final path = '/feed?limit=20&cursor=$_nextCursor';
      final response = await ApiClient().get(path);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map && body['data'] is List) {
          final List newItems = body['data'] as List;
          final parsed = newItems
              .map((e) => FamilyFeedItem.fromJson(e as Map<String, dynamic>))
              .toList();

          // Evitar duplicados por id
          final existingIds = _feed.map((e) => e.id).toSet();
          for (final item in parsed) {
            if (!existingIds.contains(item.id)) {
              _feed.add(item);
            }
          }

          final pagination = body['pagination'];
          if (pagination is Map) {
            _hasMore = pagination['has_more'] == true;
            _nextCursor = pagination['next_cursor']?.toString();
          } else {
            _hasMore = false;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [FamilyWallService] Error al cargar más feed: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Alternar reacción a un post del feed con actualización optimista y persistencia en backend
  void toggleReaction(String feedItemId, String emoji) {
    final index = _feed.indexWhere((item) => item.id == feedItemId);
    if (index == -1) return;

    final item = _feed[index];
    final backendKey = FamilyFeedItem.emojiToKey[emoji] ?? emoji;
    final currentCount = item.reacciones[emoji] ?? 0;
    final yaReacciono = item.misReacciones.contains(emoji) ||
        item.misReacciones.contains(backendKey) ||
        item.miReaccion == backendKey;

    final newMisReacciones = Set<String>.from(item.misReacciones);
    final newReacciones = Map<String, int>.from(item.reacciones);
    String? newMiReaccion;

    // Actualización visual optimista instantánea
    if (yaReacciono) {
      newMisReacciones.remove(emoji);
      newMisReacciones.remove(backendKey);
      final nextCount = (currentCount - 1).clamp(0, 9999);
      newReacciones[emoji] = nextCount;
      newReacciones[backendKey] = nextCount;
      newMiReaccion = null;
    } else {
      newMisReacciones.add(emoji);
      newMisReacciones.add(backendKey);
      final nextCount = currentCount + 1;
      newReacciones[emoji] = nextCount;
      newReacciones[backendKey] = nextCount;
      newMiReaccion = backendKey;
    }

    _feed[index] = item.copyWith(
      reacciones: newReacciones,
      misReacciones: newMisReacciones,
      miReaccion: newMiReaccion,
    );
    notifyListeners();

    // Sincronizar en segundo plano con el backend
    _syncReactionToBackend(feedItemId, backendKey, emoji);
  }

  Future<void> _syncReactionToBackend(String feedItemId, String backendKey, String emoji) async {
    try {
      final response = await ApiClient().post(
        '/feed/$feedItemId/react',
        {'tipo': backendKey},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic resBody = jsonDecode(response.body);
        if (resBody is Map && resBody['data'] is Map) {
          final dataMap = resBody['data'] as Map<String, dynamic>;
          final rawConteo = dataMap['reacciones_conteo'];
          final isReacted = dataMap['reaccionado'] == true;

          final idx = _feed.indexWhere((it) => it.id == feedItemId);
          if (idx != -1) {
            final current = _feed[idx];
            final syncedReacciones = rawConteo is Map
                ? FamilyFeedItem.mapReaccionesConteo(rawConteo)
                : current.reacciones;

            final syncedMis = <String>{};
            if (isReacted) {
              syncedMis.add(emoji);
              syncedMis.add(backendKey);
            }

            _feed[idx] = current.copyWith(
              reacciones: syncedReacciones,
              misReacciones: syncedMis,
              miReaccion: isReacted ? backendKey : null,
            );
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [FamilyWallService] Error al enviar reacción a API: $e');
    }
  }

  /// Actualiza inmediatamente los datos del usuario en la lista de miembros del ranking
  void updateMemberProfile(UserProfile updatedUser) {
    bool changed = false;
    _members = _members.map((m) {
      if (m.id == updatedUser.id) {
        changed = true;
        return m.copyWith(
          nombre: updatedUser.nombre,
          avatarColor: updatedUser.avatarColor,
          avatarLetra: updatedUser.avatarLetra,
          avatarUrl: updatedUser.avatarUrl,
          xp: updatedUser.xp,
          nivel: updatedUser.nivel,
        );
      }
      return m;
    }).toList();

    if (changed) {
      notifyListeners();
    }
  }

  /// Permite inyectar un nuevo evento al feed en vivo (simulación de SSE o tests)
  void simulateNewFeedEvent(FamilyFeedItem newItem) {
    _feed.insert(0, newItem);
    _realtimeFeedController.add(newItem);
    notifyListeners();
  }

  @override
  void dispose() {
    SessionService().currentUserNotifier.removeListener(_onCurrentUserChanged);
    _socketUnsubscribe?.call();
    _realtimeFeedController.close();
    super.dispose();
  }
}

