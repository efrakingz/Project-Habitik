import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'game/rewards_controller.dart';
import 'widgets/rewards_hud_overlay.dart';
import 'widgets/rewards_error_view.dart';
import 'widgets/create_reward_dialog.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late final RewardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RewardsController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.loadRewards();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentUser = _controller.currentUser;
        final isJefe = currentUser.isJefe;

        return ScreenShell(
          titulo: 'Canjes',
          subtitulo: '${currentUser.monedas} 🪙 disponibles',
          useDefaultBackground: true,
          headerActions: isJefe
              ? [
                  GestureDetector(
                    onTap: () => showCreateRewardDialog(
                      context,
                      onCreate: (reward) => _controller.createReward(reward, context),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: HabitikColors.green500,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Crear Premio',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              : null,
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.state == RewardsState.loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    if (_controller.state == RewardsState.error) {
      return RewardsErrorView(
        message: _controller.errorMessage ?? 'Error desconocido',
        onRetry: _controller.loadRewards,
      );
    }
    return RewardsHudOverlay(controller: _controller);
  }
}
