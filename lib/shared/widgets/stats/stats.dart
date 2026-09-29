import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';

export 'package:habitik/shared/widgets/cards/ranking_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// XpProgressBar – barra de progreso de XP del usuario
// ─────────────────────────────────────────────────────────────────────────────
class XpProgressBar extends StatelessWidget {
  final int xp;
  final int nivel;

  const XpProgressBar({super.key, required this.xp, required this.nivel});

  @override
  Widget build(BuildContext context) {
    final maxXp = nivel * 500;
    final pct = (xp / maxXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: HabitikColors.xpGold,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.colored(HabitikColors.amber400),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Nivel $nivel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ]),
              Text('$xp / $maxXp XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: HabitikRadius.xs_,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: 600.ms,
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor: Colors.white.withAlpha(60),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${maxXp - xp} XP para nivel ${nivel + 1}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
