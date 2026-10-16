import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/features/rewards/game/rewards_controller.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'rewards_list.dart';

class RewardsHudOverlay extends StatelessWidget {
  final RewardsController controller;

  const RewardsHudOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final propuesta = controller.propuestaHoy;

    return RefreshIndicator(
      onRefresh: controller.loadRewards,
      color: HabitikColors.green500,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroBannerCard(
              emoji: '🎁',
              title: 'Tienda de Canjes',
              description: 'Usa tus monedas de ahorro para canjear recompensas personales o colaborar en metas familiares.',
              actionLabel: 'Actualizar',
              onAction: controller.loadRewards,
              compact: true,
            ),
            if (propuesta != null) ...[
              const SizedBox(height: 16),
              _DailyProposalBanner(propuesta: propuesta),
            ],
            const SizedBox(height: 24),

            // ── Premios Familiares Colaborativos ──────────────────────────
            const _SectionLabel(
              emoji: '👨‍👩‍👧',
              title: 'Premios Familiares Colaborativos',
              subtitle: 'El costo se divide entre todos y se auto-canjea al completarse.',
            ),
            const SizedBox(height: 12),
            RewardsList(
              rewards: controller.premiosFamiliares,
              onRedeem: (r) => controller.redeemReward(r, context),
              onContributeColecta: (r) => controller.contributeColecta(r, context),
            ),
            const SizedBox(height: 28),

            // ── Premios Personales Individuales ───────────────────────────
            const _SectionLabel(
              emoji: '👤',
              title: 'Premios Personales',
              subtitle: 'Cada integrante canjea individualmente con sus monedas (1x día).',
            ),
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

class _DailyProposalBanner extends StatelessWidget {
  final RewardItem propuesta;
  const _DailyProposalBanner({required this.propuesta});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final esPendiente = propuesta.estado == 'propuesto';
    final esAprobado = propuesta.estado == 'activo';

    Color bg;
    Color border;
    Color textColor;
    String estadoTexto;
    IconData icon;

    if (esPendiente) {
      bg = isDark ? const Color(0xFF2C220E) : const Color(0xFFFFF8E1);
      border = HabitikColors.amber400;
      textColor = const Color(0xFFFFB300);
      estadoTexto = 'Propuesta de hoy en revisión por el Jefe';
      icon = Icons.hourglass_top_rounded;
    } else if (esAprobado) {
      bg = isDark ? const Color(0xFF1B2E1F) : const Color(0xFFE8F5E9);
      border = HabitikColors.green500;
      textColor = HabitikColors.green400;
      estadoTexto = '¡Propuesta aprobada por ${propuesta.costo} 🪙!';
      icon = Icons.check_circle_rounded;
    } else {
      bg = isDark ? const Color(0xFF331A1A) : const Color(0xFFFFEBEE);
      border = Colors.redAccent;
      textColor = Colors.redAccent;
      estadoTexto = 'Propuesta de hoy no aprobada';
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: border.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(propuesta.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: textColor),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        estadoTexto,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  propuesta.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : HabitikColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;

  const _SectionLabel({
    required this.emoji,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
