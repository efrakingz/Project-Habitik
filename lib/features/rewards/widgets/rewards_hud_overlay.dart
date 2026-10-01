import 'package:flutter/material.dart';
import 'package:habitik/features/rewards/game/rewards_controller.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'rewards_list.dart';

class RewardsHudOverlay extends StatelessWidget {
  final RewardsController controller;

  const RewardsHudOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadRewards,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroBannerCard(
              emoji: '🎁',
              title: 'Tienda de Canjes',
              description: 'Usa tus monedas de ahorro para reclamar recompensas.',
              actionLabel: 'Actualizar',
              onAction: controller.loadRewards,
              compact: true,
            ),
            const SizedBox(height: 28),

            // ── Premios Familiares ────────────────────────────────────────
            const _SectionLabel(emoji: '🎁', title: 'Premios Familiares'),
            const SizedBox(height: 12),
            RewardsList(
              rewards: controller.premiosFamiliares,
              onRedeem: (r) => controller.redeemReward(r, context),
            ),
            const SizedBox(height: 28),

            // ── Premios Personales ────────────────────────────────────────
            const _SectionLabel(emoji: '🛍️', title: 'Premios Personales'),
            const SizedBox(height: 12),
            RewardsList(
              rewards: controller.premiosPersonales,
              onRedeem: (r) => controller.redeemReward(r, context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionLabel – encabezado de sección sin botón
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String emoji;
  final String title;

  const _SectionLabel({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}
