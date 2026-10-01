import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:habitik/data/models/family_energy_model.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'package:habitik/data/models/family_member.dart';

/// Servicio puramente de Frontend para el Muro Social Familiar (HU 4.1).
/// Opera con datos Mock desacoplados del backend y soporte para actualizaciones reactivas.
class FamilyWallService extends ChangeNotifier {
  static final FamilyWallService _instance = FamilyWallService._internal();
  factory FamilyWallService() => _instance;
  FamilyWallService._internal();

  FamilyEnergyModel _energy = FamilyEnergyModel.mockDefault;
  List<FamilyMember> _members = [];
  List<FamilyFeedItem> _feed = [];
  bool _isLoading = false;

  // StreamController para simular eventos en tiempo real (CA-4.1-3)
  final StreamController<FamilyFeedItem> _realtimeFeedController =
      StreamController<FamilyFeedItem>.broadcast();

  FamilyEnergyModel get energy => _energy;
  List<FamilyMember> get members => List.unmodifiable(_members);
  List<FamilyFeedItem> get feed => List.unmodifiable(_feed);
  bool get isLoading => _isLoading;
  Stream<FamilyFeedItem> get realtimeStream => _realtimeFeedController.stream;

  /// Carga inicial de datos del muro
  Future<void> loadWallData({bool notify = true}) async {
    _isLoading = true;
    if (notify) notifyListeners();

    // Pequeño retardo simulado para suavidad visual
    await Future.delayed(const Duration(milliseconds: 350));

    _energy = const FamilyEnergyModel(
      totalXpMes: 3680,
      metaMensualXp: 5000,
      periodo: 'Mes Actual',
    );

    _members = [
      const FamilyMember(
        id: 'mem_1',
        nombre: 'Sofía',
        rol: 'miembro',
        xp: 1420,
        xpSemanal: 380,
        nivel: 5,
        rachaDias: 12,
        avatarLetra: 'S',
        avatarColor: '#E91E63',
      ),
      const FamilyMember(
        id: 'mem_2',
        nombre: 'Papá',
        rol: 'jefe',
        xp: 1150,
        xpSemanal: 290,
        nivel: 4,
        rachaDias: 9,
        avatarLetra: 'P',
        avatarColor: '#2E7D32',
      ),
      const FamilyMember(
        id: 'mem_3',
        nombre: 'Mamá',
        rol: 'jefe',
        xp: 980,
        xpSemanal: 310,
        nivel: 4,
        rachaDias: 7,
        avatarLetra: 'M',
        avatarColor: '#9C27B0',
      ),
      const FamilyMember(
        id: 'mem_4',
        nombre: 'Mateo',
        rol: 'miembro',
        xp: 630,
        xpSemanal: 190,
        nivel: 3,
        rachaDias: 4,
        avatarLetra: 'M',
        avatarColor: '#1976D2',
      ),
    ];

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
