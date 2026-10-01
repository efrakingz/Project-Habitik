import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/reward.dart';
import 'package:habitik/shared/widgets/modals/confirm_dialog.dart';

class RewardsList extends StatelessWidget {
  final List<RewardItem> rewards;
  final Function(RewardItem) onRedeem;

  const RewardsList({
    super.key,
    required this.rewards,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Aún no hay recompensas aquí.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Los premios creados aparecerán en esta lista.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final isCooldownActive = reward.isCooldownActive;
        final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

        return Opacity(
          opacity: isCooldownActive ? 0.6 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16251B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: HabitikShadows.card,
              border: isCooldownActive
                  ? Border.all(color: HabitikColors.orange500, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16251B) : HabitikColors.bgLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(reward.emoji, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          decoration: isCooldownActive ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.descripcion,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : HabitikColors.textMid,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCooldownActive) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: HabitikColors.orange500),
                              const SizedBox(width: 4),
                              const Text(
                                'En enfriamiento',
                                style: TextStyle(
                                  color: HabitikColors.orange500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (reward.lastRedeemedByNombre != null &&
                            reward.lastRedeemedByNombre!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Canjeado por: ${reward.lastRedeemedByNombre}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: isCooldownActive
                      ? null
                      : () async {
                          final result = await HabitikConfirmDialog.show(
                            context,
                            title: 'Reclamar Premio',
                            description: '¿Quieres canjear ${reward.costo} monedas por "${reward.titulo}"?',
                            confirmLabel: '¡Canjear!',
                            cancelLabel: 'Mejor no',
                          );
                          if (result == true) {
                            onRedeem(reward);
                          }
                        },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCooldownActive ? Colors.grey.withValues(alpha: 0.2) : HabitikColors.orange500,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${reward.costo}',
                          style: TextStyle(
                            color: isCooldownActive ? Colors.grey : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('🪙', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
