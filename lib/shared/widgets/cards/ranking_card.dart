import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RankingCard – Tarjeta reutilizable de miembro familiar en el ranking
// ─────────────────────────────────────────────────────────────────────────────
class RankingCard extends StatelessWidget {
  final int position;
  final FamilyMember member;
  final int? maxXp;
  final EdgeInsetsGeometry? margin;

  const RankingCard({
    super.key,
    required this.position,
    required this.member,
    this.maxXp,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = position <= 3;
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

    // Colores y sombras para el podio (oro, plata, bronce)
    Color borderColor;
    Color shadowColor;
    if (position == 1) {
      borderColor = HabitikColors.amber400;
      shadowColor = HabitikColors.amber400.withValues(alpha: 0.25);
    } else if (position == 2) {
      borderColor = Colors.blueGrey.shade300;
      shadowColor = Colors.blueGrey.withValues(alpha: 0.2);
    } else if (position == 3) {
      borderColor = Colors.deepOrange.shade300;
      shadowColor = Colors.deepOrange.withValues(alpha: 0.2);
    } else {
      borderColor = isDark ? const Color(0x20FFFFFF) : HabitikColors.green200.withValues(alpha: 0.4);
      shadowColor = Colors.transparent;
    }

    final effectiveMaxXp = (maxXp != null && maxXp! > 0)
        ? maxXp!
        : (member.xp > 0 ? member.xp : 1);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
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
                : Text(
                    '#$position',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : HabitikColors.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          UserAvatar(
            letra: member.avatarLetra,
            colorHex: member.avatarColor,
            avatarUrl: member.avatarUrl,
            radius: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Nivel ${member.nivel}',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : HabitikColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member.xp} XP',
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: HabitikRadius.xs_,
                child: SizedBox(
                  width: 60,
                  height: 6,
                  child: LinearProgressIndicator(
                    value: (member.xp / effectiveMaxXp).clamp(0.0, 1.0),
                    backgroundColor: isDark ? const Color(0xFF141F17) : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(
                      isTop3
                          ? borderColor
                          : (isDark ? HabitikColors.green500 : HabitikColors.green600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (position * 80).ms)
        .slideX(begin: 0.08, duration: 350.ms, curve: Curves.easeOutQuad);
  }

  static String _medal(int pos) => ['🥇', '🥈', '🥉'][pos - 1];
}
