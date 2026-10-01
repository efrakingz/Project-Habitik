import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';

class ProfileIdentityCard extends StatelessWidget {
  final UserProfile user;
  final bool isDark;

  const ProfileIdentityCard({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
              // Avatar with subtle glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getGlowColor(user.nivel).withValues(alpha: 0.25),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: UserAvatar(
                  letra: user.avatarLetra,
                  colorHex: user.avatarColor,
                  avatarUrl: user.avatarUrl,
                  radius: 28,
                  showBorder: true,
                ),
              ).animate().scale(
                begin: const Offset(0.85, 0.85),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(width: 14),

              // User Info (Name, Email, Role)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.nombre,
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (user.email != null && user.email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.email!,
                        style: TextStyle(
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
                    RolBadge(user.rol, fontSize: 11),
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
                        value: '${user.monedas}',
                        bgColor: isDark ? const Color(0xFF2E2412) : const Color(0xFFFFF8E7),
                        textColor: isDark ? HabitikColors.amber300 : const Color(0xFFB78103),
                        borderColor: HabitikColors.amber400.withValues(alpha: isDark ? 0.4 : 0.6),
                      ),
                      const SizedBox(height: 6),

                      // Streak pill (🔥)
                      _MiniStatBadge(
                        icon: '🔥',
                        value: '${user.rachaDias}',
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
        XpProgressBar(xp: user.xp, nivel: user.nivel)
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.05),
      ],
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
      constraints: const BoxConstraints(minWidth: 62, minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
