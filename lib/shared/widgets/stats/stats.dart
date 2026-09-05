import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// RankingCard – fila de ranking de miembro familiar
// ─────────────────────────────────────────────────────────────────────────────
class RankingCard extends StatelessWidget {
  final int position;
  final FamilyMember member;
  final int maxXp;

  const RankingCard({super.key, required this.position, required this.member, required this.maxXp});

  @override
  Widget build(BuildContext context) {
    final isTop3 = position <= 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores para el podio
    Color? borderColor;
    Color? shadowColor;
    if (position == 1) {
      borderColor = HabitikColors.amber400;
      shadowColor = HabitikColors.amber400.withValues(alpha: 0.2);
    } else if (position == 2) {
      borderColor = Colors.blueGrey.shade300;
      shadowColor = Colors.blueGrey.withValues(alpha: 0.15);
    } else if (position == 3) {
      borderColor = Colors.deepOrange.shade300;
      shadowColor = Colors.deepOrange.withValues(alpha: 0.15);
    } else {
      borderColor = isDark ? const Color(0x20FFFFFF) : HabitikColors.green200.withValues(alpha: 0.4);
      shadowColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16221A) : HabitikColors.green50,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: borderColor, width: isTop3 ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          if (!isTop3)
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : HabitikColors.green900.withValues(alpha: 0.03),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isTop3
                ? Text(_medal(position), style: const TextStyle(fontSize: 22))
                : Text('#$position',
                    style: TextStyle(
                        color: isDark ? Colors.white60 : HabitikColors.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
          ),
          UserAvatar(letra: member.avatarLetra, colorHex: member.avatarColor, avatarUrl: member.avatarUrl, radius: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(
                      member.nombre,
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  RolBadge(member.rol),
                ]),
                const SizedBox(height: 2),
                Text('Nivel ${member.nivel}', style: TextStyle(color: isDark ? Colors.white54 : HabitikColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${member.xp} XP',
                  style: TextStyle(
                      color: isDark ? Colors.white : HabitikColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: HabitikRadius.xs_,
                child: SizedBox(
                  width: 60,
                  height: 6,
                  child: LinearProgressIndicator(
                    value: maxXp > 0 ? (member.xp / maxXp).clamp(0.0, 1.0) : 0,
                    backgroundColor: isDark ? const Color(0xFF141F17) : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(isTop3 ? borderColor : (isDark ? HabitikColors.green500 : HabitikColors.green600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (position * 100).ms).slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  String _medal(int pos) => ['🥇', '🥈', '🥉'][pos - 1];
}
