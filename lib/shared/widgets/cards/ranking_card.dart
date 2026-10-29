import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
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

  AchievementItem _getAchievementDetails(String key) {
    final upper = key.toUpperCase().trim();
    final title = BadgeSvgIcons.getBadgeTitle(key);

    try {
      return AchievementItem.officialCatalog.firstWhere(
        (b) =>
            b.key.toUpperCase() == upper ||
            b.nombre.toUpperCase() == title.toUpperCase() ||
            b.emoji == key,
      );
    } catch (_) {}

    try {
      return AchievementItem.mockList.firstWhere(
        (b) =>
            b.key.toUpperCase() == upper ||
            b.nombre.toUpperCase() == title.toUpperCase() ||
            b.emoji == key,
      );
    } catch (_) {}

    return AchievementItem(
      key: key,
      nombre: title,
      descripcion: 'Logro completado con éxito y seleccionado como insignia destacada.',
      emoji: '⭐',
      desbloqueado: true,
    );
  }

  void _showBadgeDetailModal(BuildContext context, String badgeKey, bool isDark) {
    final item = _getAchievementDetails(badgeKey);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16251B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF2E4233) : const Color(0xFFBCE0C8),
              width: 1.5,
            ),
            boxShadow: HabitikShadows.floating,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tirador superior (drag handle)
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Contenedor del ícono/logo de la insignia
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2410) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: BadgeSvgIcons.buildSvg(item.key, size: 40),
              ),

              const SizedBox(height: 14),

              // Tag "INSIGNIA DESTACADA ⭐"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E220D) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'INSIGNIA DESTACADA',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Nombre del logro
              Text(
                item.nombre,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : const Color(0xFF0F291E),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 6),

              // Descripción del logro
              Text(
                item.descripcion.isNotEmpty
                    ? item.descripcion
                    : 'Logro completado con éxito por este miembro del hogar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              if (item.categoria.isNotEmpty || item.nivelTier.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF142E1F) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? HabitikColors.green700 : const Color(0xFFA5DCB6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${item.categoria}${item.nivelTier.isNotEmpty ? ' · ${item.nivelTier}' : ''}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? HabitikColors.green300 : const Color(0xFF166534),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Botón de cerrar ("¡Entendido!")
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Entendido',
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
              // Avatar limpio (sin insignia sobrepuesta)
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
                        if (hasBadge) ...[
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () => _showBadgeDetailModal(context, effectiveBadge, isDark),
                            borderRadius: BorderRadius.circular(8),
                            child: Tooltip(
                              message:
                                  'Insignia destacada: ${BadgeSvgIcons.getBadgeTitle(effectiveBadge)} (Toca para ver)',
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
