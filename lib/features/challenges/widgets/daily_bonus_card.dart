import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

const _kAnimMedium = Duration(milliseconds: 300);

class DailyBonusCard extends StatelessWidget {
  final bool claimed;
  const DailyBonusCard({super.key, required this.claimed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: _kAnimMedium,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: claimed ? null : HabitikColors.xpGold,
        color: claimed
            ? (isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC))
            : null,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: isDark ? 4.0 : 3.0),
        boxShadow: claimed
            ? []
            : HabitikShadows.colored(HabitikColors.amber400),
      ),
      child: Row(
        children: [
          claimed
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: HabitikColors.green500,
                  size: 28,
                )
              : const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 28,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claimed ? 'Bonus reclamado' : 'Bonus del Día',
                  style: TextStyle(
                    color: claimed
                        ? (isDark ? Colors.white70 : HabitikColors.green600)
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      claimed
                          ? '¡Completaste 3 retos hoy!'
                          : 'Completa 3 retos hoy → +50 ',
                      style: TextStyle(
                        color: claimed
                            ? (isDark
                                  ? Colors.white54
                                  : HabitikColors.textLight)
                            : Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                    if (!claimed) const GameCoinIcon(size: 11),
                    if (!claimed)
                      Text(
                        ' extra',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
