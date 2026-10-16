import 'package:flutter/material.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/features/rewards/services/rewards_service.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';

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

  RewardItem? _propuestaHoy;
  RewardItem? get propuestaHoy => _propuestaHoy;
  bool get yaPropusoHoy => _propuestaHoy != null;

  List<FamilyColecta> _colectasActivas = [];
  List<FamilyColecta> get colectasActivas => _colectasActivas;

  UserProfile get currentUser => SessionService().currentUser ?? UserProfile.empty;

  final RewardsService _rewardsService = RewardsService();

  /// Callback al que la pantalla puede suscribirse para mostrar diálogos o modales de feedback
  void Function(String titulo, String mensaje, bool esExito)? onCanjeResuelto;

  late final VoidCallback _unsubscribeSocket;

  RewardsController() {
    _unsubscribeSocket = SocketService.subscribe(_onSocketEvent);
  }

  /// Escucha eventos del socket relacionados con canjes, propuestas y colectas
  void _onSocketEvent(Map<String, dynamic> data) {
    final tipo = data['tipo']?.toString() ?? '';
    final userId = data['user_id']?.toString() ?? '';
    final myId = currentUser.id;

    // 1. Eventos dirigidos exclusivamente a este usuario
    if (userId.isNotEmpty && userId == myId) {
      if (tipo == 'CANJE_APROBADO') {
        final premio = data['reward_titulo']?.toString() ?? 'tu premio';
        onCanjeResuelto?.call(
          '🎉 ¡Canje aprobado!',
          'El Jefe aprobó tu solicitud de "$premio". ¡Disfrútalo!',
          true,
        );
        loadRewards();
        return;
      } else if (tipo == 'CANJE_RECHAZADO') {
        final premio = data['reward_titulo']?.toString() ?? 'tu premio';
        final motivo = data['motivo']?.toString();
        final mensajeExtra = motivo != null && motivo.isNotEmpty ? '\nMotivo: $motivo' : '';
        onCanjeResuelto?.call(
          '❌ Solicitud rechazada',
          'El Jefe rechazó tu solicitud de "$premio". Tus monedas fueron reembolsadas.$mensajeExtra',
          false,
        );
        loadRewards();
        return;
      } else if (tipo == 'PROPUESTA_APROBADA') {
        final premio = data['reward_titulo']?.toString() ?? 'tu premio';
        final costo = data['costo']?.toString() ?? '';
        onCanjeResuelto?.call(
          '🎉 ¡Propuesta aprobada!',
          'El Jefe aprobó tu propuesta de "$premio" fijando un costo de $costo 🪙. ¡Ya puedes canjearlo en la tienda!',
          true,
        );
        loadRewards();
        return;
      } else if (tipo == 'PROPUESTA_RECHAZADA') {
        final premio = data['reward_titulo']?.toString() ?? 'tu premio';
        final motivo = data['motivo']?.toString();
        final mensajeExtra = motivo != null && motivo.isNotEmpty ? '\nMotivo: $motivo' : '';
        onCanjeResuelto?.call(
          '❌ Propuesta no aprobada',
          'El Jefe no aprobó tu propuesta de "$premio".$mensajeExtra',
          false,
        );
        loadRewards();
        return;
      }
    }

    // 2. Eventos familiares generales (colectas o nuevos premios)
    if (tipo == 'COLECTA_COMPLETADA') {
      final premio = data['reward_titulo']?.toString() ?? 'el premio familiar';
      onCanjeResuelto?.call(
        '🏆 ¡Meta familiar completada!',
        '¡Toda la familia aportó y completaron "$premio"! Se canjeó automáticamente.',
        true,
      );
      loadRewards();
    } else if (tipo == 'COLECTA_INICIADA' || tipo == 'COLECTA_APORTE' || tipo == 'PREMIO_CREADO') {
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
      final catalog = await _rewardsService.getCatalog();
      _rewards = catalog.rewards;
      _propuestaHoy = catalog.propuestaHoy;
      _colectasActivas = catalog.colectasActivas;
      _state = RewardsState.idle;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = RewardsState.error;
    }
    notifyListeners();
  }

  /// Canje personal individual (1 por día por usuario)
  Future<void> redeemReward(RewardItem reward, BuildContext context) async {
    if (currentUser.monedas < reward.costo) {
      HabitikFeedback.showError(context, 'No tienes suficientes monedas (${currentUser.monedas} 🪙) para canjear este premio (${reward.costo} 🪙).');
      return;
    }

    try {
      final result = await _rewardsService.redeemReward(reward.id);
      
      // Actualizamos las monedas localmente
      if (result['monedas_restantes'] != null) {
        SessionService().updateRewardsAndXp(
          xp: currentUser.xp, 
          monedas: (result['monedas_restantes'] as num).toInt(),
        );
      }
      
      if (context.mounted) {
        HabitikFeedback.showSuccess(
          context, 
          result['message'] ?? '¡Canje solicitado! Espera la aprobación del Jefe.',
        );
      }
      
      await loadRewards();
    } catch (e) {
      if (context.mounted) {
        HabitikFeedback.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  /// Inicia o aporta a una colecta familiar colaborativa
  Future<void> contributeColecta(RewardItem reward, BuildContext context) async {
    try {
      final result = await _rewardsService.contributeColecta(reward.id);
      
      if (result['monedas_restantes'] != null) {
        SessionService().updateRewardsAndXp(
          xp: currentUser.xp, 
          monedas: (result['monedas_restantes'] as num).toInt(),
        );
      }

      if (context.mounted) {
        HabitikFeedback.showSuccess(context, result['message'] ?? '¡Aporte realizado con éxito!');
      }

      await loadRewards();
    } catch (e) {
      if (context.mounted) {
        HabitikFeedback.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  /// Miembro envía una propuesta personal diaria
  Future<void> proposeReward({
    required String titulo,
    String? descripcion,
    String? emoji,
    required BuildContext context,
  }) async {
    try {
      await _rewardsService.proposeReward(
        titulo: titulo,
        descripcion: descripcion,
        emoji: emoji,
      );

      if (context.mounted) {
        HabitikFeedback.showSuccess(
          context, 
          '¡Propuesta enviada al Jefe de Hogar! Te avisaremos cuando le asigne monedas.',
        );
      }

      await loadRewards();
    } catch (e) {
      if (context.mounted) {
        HabitikFeedback.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  /// Jefe crea un premio familiar o personal directamente
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
        HabitikFeedback.showSuccess(context, 'Premio creado exitosamente.');
      }
      
      await loadRewards();
    } catch (e) {
      if (context.mounted) {
        HabitikFeedback.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }
}
