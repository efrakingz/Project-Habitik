import 'package:flutter/material.dart';
import 'package:habitik/data/models/reward.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/features/rewards/services/rewards_service.dart';

enum RewardsState { loading, idle, error }

class RewardsController extends ChangeNotifier {
  RewardsState _state = RewardsState.loading;
  RewardsState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RewardItem> _rewards = [];
  List<RewardItem> get rewards => _rewards;
  List<RewardItem> get premiosFamiliares => _rewards.where((r) => r.esFamiliar).toList();
  List<RewardItem> get premiosPersonales => _rewards.where((r) => !r.esFamiliar).toList();

  UserProfile get currentUser => SessionService().currentUser ?? UserProfile.empty;

  final RewardsService _rewardsService = RewardsService();

  Future<void> init(BuildContext context) async {
    await loadRewards();
  }

  Future<void> loadRewards() async {
    _state = RewardsState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _rewards = await _rewardsService.getRewards();
      _state = RewardsState.idle;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = RewardsState.error;
    }
    notifyListeners();
  }

  Future<void> redeemReward(RewardItem reward, BuildContext context) async {
    if (currentUser.monedas < reward.costo) {
      _showSnackBar(context, 'No tienes suficientes monedas para canjear este premio.');
      return;
    }

    try {
      final result = await _rewardsService.redeemReward(reward.id);
      
      // Actualizamos las monedas localmente usando lo que dice el backend
      SessionService().updateRewardsAndXp(
        xp: currentUser.xp, 
        monedas: result['monedas_restantes'] as int,
      );
      
      if (context.mounted) {
        _showSnackBar(context, result['message'], isSuccess: true);
      }
      
      await loadRewards(); // Recargamos para actualizar los estados (cooldowns, etc)
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> createReward(RewardItem newReward, BuildContext context) async {
    try {
      final rewardData = {
        'titulo': newReward.titulo,
        'descripcion': newReward.descripcion,
        'emoji': newReward.emoji,
        'costo': newReward.costo,
        'es_familiar': newReward.esFamiliar,
        'metadata': newReward.metadata,
      };

      await _rewardsService.createReward(rewardData);
      
      if (context.mounted) {
        _showSnackBar(context, 'Premio creado exitosamente.', isSuccess: true);
      }
      
      await loadRewards();
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
