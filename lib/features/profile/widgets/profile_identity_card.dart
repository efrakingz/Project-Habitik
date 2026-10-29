import 'edit_profile_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';
import 'badge_svg_icons.dart';

class ProfileIdentityCard extends StatelessWidget {
  final UserProfile user;
  final bool isDark;

  const ProfileIdentityCard({
    super.key,
    required this.user,
    required this.isDark,
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
      descripcion: 'Logro completado con éxito y seleccionado como insignia destacada en tu perfil.',
      emoji: '⭐',
      desbloqueado: true,
    );
  }

  void _showFeaturedBadgeModal(BuildContext context, String featuredKey, bool isDark) {
    final item = _getAchievementDetails(featuredKey);

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
                    : 'Logro completado con éxito y lucido con orgullo en tu perfil.',
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
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: SessionService().currentUserNotifier,
      builder: (context, sessionUser, _) {
        final currentUser = sessionUser ?? user;
        final featuredKey = SessionService().badgeDestacado ?? currentUser.badgeDestacado;
        final hasFeatured = featuredKey != null && featuredKey.isNotEmpty;

        return Column(
          children: [
            // Ultra-compact Profile Card (Identity + Inline Coins & Streak)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : const LinearGradient(
                        colors: [HabitikColors.green50, Color(0xFFE8F5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isDark ? const Color(0xFF16221A) : null,
                borderRadius: HabitikRadius.xl_,
                border: Border.all(
                  color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green200.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? HabitikColors.green500.withValues(alpha: 0.05)
                        : HabitikColors.green900.withValues(alpha: 0.06),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with subtle glow y badge de edicion
                  GestureDetector(
                    onTap: () => EditProfileModal.show(context),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getGlowColor(currentUser.nivel).withValues(alpha: 0.25),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: UserAvatar(
                            letra: currentUser.avatarLetra,
                            colorHex: currentUser.avatarColor,
                            avatarUrl: currentUser.avatarUrl,
                            radius: 28,
                            showBorder: true,
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: HabitikColors.green600,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF16221A) : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(
                    begin: const Offset(0.85, 0.85),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(width: 14),

                  // User Info (Name + Featured Badge, Email, Role)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name Row with Featured Badge Mini Tag
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                currentUser.nombre,
                                style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : HabitikColors.textDark,
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasFeatured) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _showFeaturedBadgeModal(context, featuredKey, isDark),
                                borderRadius: BorderRadius.circular(10),
                                child: Tooltip(
                                  message: 'Insignia destacada: ${BadgeSvgIcons.getBadgeTitle(featuredKey)} (Toca para ver)',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2E220D) : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        BadgeSvgIcons.buildSvg(featuredKey, size: 14),
                                        const SizedBox(width: 3),
                                        const Text('⭐', style: TextStyle(fontSize: 9)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (currentUser.email != null && currentUser.email!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            currentUser.email!,
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white60 : HabitikColors.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 6),

                        // Role Badge (Miembro / Jefe)
                        RolBadge(currentUser.rol, fontSize: 11),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Stats stacked on the right (Symmetrical & Tappable for info)
                  GestureDetector(
                    onTap: () => ProfileStatsInfoModal.show(context, isDark: isDark),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Coins pill (🪙)
                          _MiniStatBadge(
                            icon: '🪙',
                            value: '${currentUser.monedas}',
                            bgColor: isDark ? const Color(0xFF2E2412) : const Color(0xFFFFF8E7),
                            textColor: isDark ? HabitikColors.amber300 : const Color(0xFFB78103),
                            borderColor: HabitikColors.amber400.withValues(alpha: isDark ? 0.4 : 0.6),
                          ),
                          const SizedBox(height: 6),

                          // Streak pill (🔥)
                          _MiniStatBadge(
                            icon: '🔥',
                            value: '${currentUser.rachaDias}',
                            bgColor: isDark ? const Color(0xFF2E1A12) : const Color(0xFFFFF0EA),
                            textColor: isDark ? HabitikColors.orange300 : const Color(0xFFD84315),
                            borderColor: HabitikColors.orange500.withValues(alpha: isDark ? 0.4 : 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            const SizedBox(height: 12),

            // Level / XP Progress Bar right below
            XpProgressBar(xp: currentUser.xp, nivel: currentUser.nivel)
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.05),
          ],
        );
      },
    );
  }

  Color _getGlowColor(int nivel) {
    if (nivel >= 5) return Colors.purpleAccent;
    if (nivel >= 3) return HabitikColors.amber400;
    return HabitikColors.green400;
  }
}

/// Modal que explica las monedas y la racha del usuario
abstract class ProfileStatsInfoModal {
  static void show(BuildContext context, {required bool isDark}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2E22) : Colors.white,
            borderRadius: HabitikRadius.xl_,
            border: Border.all(
              color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green500.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: isDark ? HabitikColors.green400 : HabitikColors.green700,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tus Estadísticas',
                    style: TextStyle(
                      color: isDark ? Colors.white : HabitikColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monedas explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262010) : const Color(0xFFFFF8E7),
                  borderRadius: HabitikRadius.md_,
                  border: Border.all(
                    color: HabitikColors.amber400.withValues(alpha: isDark ? 0.3 : 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estas son tus Monedas',
                            style: TextStyle(
                              color: isDark ? HabitikColors.amber300 : const Color(0xFF9E6C00),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Monedas acumuladas al completar retos y hábitos sostenibles. Úsalas para canjear recompensas en la tienda.',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : HabitikColors.textMid,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Racha explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF281810) : const Color(0xFFFFF0EA),
                  borderRadius: HabitikRadius.md_,
                  border: Border.all(
                    color: HabitikColors.orange500.withValues(alpha: isDark ? 0.3 : 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Este es tu Día de Racha',
                            style: TextStyle(
                              color: isDark ? HabitikColors.orange300 : const Color(0xFFC8380A),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Representa los días consecutivos que llevas realizando hábitos ecológicos. ¡Cumple al menos un hábito al día para mantener encendida la llama!',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : HabitikColors.textMid,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '¡Entendido!',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStatBadge extends StatelessWidget {
  final String icon;
  final String value;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _MiniStatBadge({
    required this.icon,
    required this.value,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
