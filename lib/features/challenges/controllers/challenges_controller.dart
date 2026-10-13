import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';

class ChallengesController extends ChangeNotifier {
  List<bool> _streakDays = [false, false, false, false, false, false, false];
  List<bool> get streakDays => List.unmodifiable(_streakDays);

  Set<String> _completedChallenges = {};
  Set<String> get completedChallenges => Set.unmodifiable(_completedChallenges);

  String? _selectedChallengeId;
  String? get selectedChallengeId => _selectedChallengeId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Inicializa datos del controlador (racha semanal y retos completados locales)
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      loadCompletedChallenges(),
      loadWeeklyStreak(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCompletedChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final user = SessionService().currentUser;
      final key = 'completed_challenges_${user?.id}_$dateStr';
      final completed = prefs.getStringList(key) ?? [];
      _completedChallenges = completed.toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ [ChallengesController] Error cargando retos completados: $e');
    }
  }

  Future<void> loadWeeklyStreak() async {
    final user = SessionService().currentUser;
    if (user == null) return;

    try {
      final res = await ApiClient().get('/reto/racha-semanal/${user.id}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['ok'] == true && decoded['data'] != null) {
          final diasRaw = decoded['data']['dias'];
          if (diasRaw is List && diasRaw.length == 7) {
            _streakDays = diasRaw.map((d) => d == true).toList();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [ChallengesController] Error cargando racha semanal: $e');
    }
  }

  Future<void> markChallengeCompleted(String id) async {
    _completedChallenges = {..._completedChallenges, id};
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final user = SessionService().currentUser;
      final key = 'completed_challenges_${user?.id}_$dateStr';
      await prefs.setStringList(key, _completedChallenges.toList());
    } catch (e) {
      debugPrint('⚠️ [ChallengesController] Error persistiendo reto completado: $e');
    }

    await loadWeeklyStreak();
  }

  void selectChallenge(String? id) {
    if (_selectedChallengeId != id) {
      _selectedChallengeId = id;
      notifyListeners();
    }
  }
}
