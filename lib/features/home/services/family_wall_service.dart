import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/family_energy_model.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'package:habitik/data/models/family_member.dart';

/// Servicio para el Muro Social Familiar (HU 4.1).
/// Conecta con la API para los miembros reales y gestiona el feed social.
class FamilyWallService extends ChangeNotifier {
  static final FamilyWallService _instance = FamilyWallService._internal();
  factory FamilyWallService() => _instance;
  FamilyWallService._internal();

  final FamilyEnergyModel _energy = FamilyEnergyModel.mockDefault;
  List<FamilyMember> _members = [];
  List<FamilyFeedItem> _feed = [];
  bool _isLoading = false;
  bool _membersLoading = false;
  String? _membersError;

  // StreamController para simular eventos en tiempo real (CA-4.1-3)
  final StreamController<FamilyFeedItem> _realtimeFeedController =
      StreamController<FamilyFeedItem>.broadcast();

  FamilyEnergyModel get energy => _energy;
  List<FamilyMember> get members => List.unmodifiable(_members);
  List<FamilyFeedItem> get feed => List.unmodifiable(_feed);
  bool get isLoading => _isLoading;
  bool get membersLoading => _membersLoading;
  String? get membersError => _membersError;
  Stream<FamilyFeedItem> get realtimeStream => _realtimeFeedController.stream;

  /// Carga de datos del muro (miembros reales del hogar + feed)
  Future<void> loadWallData({bool notify = true}) async {
    _isLoading = true;
    _membersLoading = true;
    _membersError = null;
    if (notify) notifyListeners();

    try {
      final user = SessionService().currentUser;
      if (user != null && user.familyId != null && user.familyId!.isNotEmpty) {
        final path = '/familia/miembros?family_id=${user.familyId}';
        final response = await ApiClient().get(path);
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          _members = data.map((json) {
            final m = FamilyMember.fromJson(json as Map<String, dynamic>);
            return m.id == user.id ? m.copyWith(xp: user.xp, nivel: user.nivel) : m;
          }).toList()
            ..sort((a, b) => b.xp.compareTo(a.xp));
        }
      } else {
        _members = [];
      }
    } catch (e) {
      debugPrint('⚠️ [FamilyWallService] Error al cargar miembros familiares: $e');
      _membersError = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _membersLoading = false;
    }

    if (_feed.isEmpty) {
      _feed = List.from(FamilyFeedItem.mockList);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Alternar reacción rápida a un post del feed (👏, 🔥, 💧, ❤️)
  void toggleReaction(String feedItemId, String emoji) {
    final index = _feed.indexWhere((item) => item.id == feedItemId);
    if (index == -1) return;

    final item = _feed[index];
    final currentCount = item.reacciones[emoji] ?? 0;
    final yaReacciono = item.misReacciones.contains(emoji);

    final newMisReacciones = Set<String>.from(item.misReacciones);
    final newReacciones = Map<String, int>.from(item.reacciones);

    if (yaReacciono) {
      newMisReacciones.remove(emoji);
      newReacciones[emoji] = (currentCount - 1).clamp(0, 9999);
    } else {
      newMisReacciones.add(emoji);
      newReacciones[emoji] = currentCount + 1;
    }

    _feed[index] = item.copyWith(
      reacciones: newReacciones,
      misReacciones: newMisReacciones,
    );

    notifyListeners();
  }

  /// Permite inyectar un nuevo evento al feed en vivo (simulación de SSE)
  void simulateNewFeedEvent(FamilyFeedItem newItem) {
    _feed.insert(0, newItem);
    _realtimeFeedController.add(newItem);
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeFeedController.close();
    super.dispose();
  }
}
