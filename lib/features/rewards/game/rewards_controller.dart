import 'package:flutter/material.dart';
import 'package:habitik/core/services/socket_service.dart';
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

  /// Callback al que la pantalla puede suscribirse para mostrar diálogos/snackbars
  void Function(String titulo, String mensaje, bool esExito)? onCanjeResuelto;

  late final VoidCallback _unsubscribeSocket;

  RewardsController() {
    _unsubscribeSocket = SocketService.subscribe(_onSocketEvent);
  }

  /// Escucha eventos del socket relacionados con canjes del usuario actual
  void _onSocketEvent(Map<String, dynamic> data) {
    final tipo = data['tipo']?.toString() ?? '';
    final userId = data['user_id']?.toString() ?? '';
    final myId = currentUser.id;

    // Solo procesamos eventos dirigidos a este usuario
    if (userId.isNotEmpty && userId != myId) return;

    if (tipo == 'CANJE_APROBADO') {
      final premio = data['reward_titulo']?.toString() ?? 'tu premio';
      onCanjeResuelto?.call(
        '🎉 ¡Canje aprobado!',
        'El Jefe aprobó tu solicitud de "$premio". ¡Disfrútalo!',
        true,
      );
      loadRewards(); // Refrescar lista (quitar cooldown si aplica)
    } else if (tipo == 'CANJE_RECHAZADO') {
      final premio = data['reward_titulo']?.toString() ?? 'tu premio';
      final motivo = data['motivo']?.toString();
      final mensajeExtra = motivo != null ? '\nMotivo: $motivo' : '';
      onCanjeResuelto?.call(
        '❌ Solicitud rechazada',
        'El Jefe rechazó tu solicitud de "$premio". Tus monedas fueron reembolsadas.$mensajeExtra',
        false,
      );
      // Refrescar monedas desde la sesión (el backend ya las reembolsó)
      loadRewards();
    }
  }

  @override
  void dispose() {
    _unsubscribeSocket();
    super.dispose();
  }

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
        monedas: (result['monedas_restantes'] as num).toInt(),
      );
      
      if (context.mounted) {
        _showSnackBar(context, result['message'] ?? '¡Canje enviado! Espera la aprobación del Jefe.', isSuccess: true);
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
      final rewardPayload = {
        'titulo': newReward.titulo,
        'descripcion': newReward.descripcion,
        'emoji': newReward.emoji,
        'costo': newReward.costo,
        'es_familiar': newReward.esFamiliar,
        'metadata': newReward.metadata,
      };

      await _rewardsService.createReward(rewardPayload);
      
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
