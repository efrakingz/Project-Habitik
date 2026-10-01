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
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ScreenShell(
          titulo: 'Canjes',
          subtitulo: null,
          useDefaultBackground: true,
          headerActions: [
            if (isJefe) ...[
              GestureDetector(
                onTap: () => showCreateRewardDialog(
                  context,
                  onCreate: (reward) => _controller.createReward(reward, context),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'Crear',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            _buildCoinsCard(context, currentUser.monedas, isDark),
          ],
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildCoinsCard(BuildContext context, int monedas, bool isDark) {
    return GestureDetector(
      onTap: () => _mostrarDetalleMonedas(context, monedas, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2F23).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? HabitikColors.amber400.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF382D12) : const Color(0xFFFFF8E1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('🪙', style: TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monedas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.1,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'disponibles',
                  style: TextStyle(
                    color: isDark
                        ? HabitikColors.green200
                        : Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.0,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleMonedas(BuildContext context, int monedas, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? HabitikColors.darkCardBg : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF382D12) : const Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🪙', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 14),
              Text(
                '$monedas Monedas Disponibles',
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gana monedas completando tus retos y hábitos ecológicos diarios. Puedes usarlas para canjear cualquiera de los premios de la tienda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : HabitikColors.textMid,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
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
