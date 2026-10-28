import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/features/profile/widgets/badge_svg_icons.dart';
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

    return ValueListenableBuilder<UserProfile?>(
      valueListenable: SessionService().currentUserNotifier,
      builder: (context, currentUser, _) {
        final isCurrentUser = currentUser != null &&
            (currentUser.id == member.id ||
                (member.id.isEmpty &&
                    currentUser.nombre.toLowerCase().trim() ==
                        member.nombre.toLowerCase().trim()));
        final effectiveBadge = (isCurrentUser ? SessionService().badgeDestacado : null) ??
            member.badgeDestacado;
        final hasBadge = effectiveBadge != null && effectiveBadge.trim().isNotEmpty;

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
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : HabitikColors.green900.withValues(alpha: 0.03),
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(
                    letra: member.avatarLetra,
                    colorHex: member.avatarColor,
                    avatarUrl: member.avatarUrl,
                    radius: 20,
                  ),
                  if (hasBadge)
                    Positioned(
                      bottom: -2,
                      right: -3,
                      child: Container(
                        width: 17,
                        height: 17,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFB300),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: BadgeSvgIcons.buildSvg(
                            effectiveBadge,
                            size: 11,
                          ),
                        ),
                      ),
                    ),
                ],
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
                        if (hasBadge) ...[
                          const SizedBox(width: 5),
                          Tooltip(
                            message:
                                'Insignia destacada: ${BadgeSvgIcons.getBadgeTitle(effectiveBadge)}',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2E220D)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFF59E0B),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BadgeSvgIcons.buildSvg(effectiveBadge, size: 12),
                                  const SizedBox(width: 2.5),
                                  const Text('⭐', style: TextStyle(fontSize: 8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Nivel ${member.nivel}',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : HabitikColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        if (hasBadge) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: isDark ? Colors.white30 : HabitikColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              BadgeSvgIcons.getBadgeTitle(effectiveBadge),
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFB45309),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
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
                        backgroundColor:
                            isDark ? const Color(0xFF141F17) : Colors.grey.shade100,
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
      },
    );
  }

  static String _medal(int pos) => ['🥇', '🥈', '🥉'][pos - 1];
}
