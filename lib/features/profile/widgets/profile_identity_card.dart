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
        // Hero Header (Identity)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: isDark 
                ? null 
                : const LinearGradient(
                    colors: [HabitikColors.green50, Color(0xFFDFF0DF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            color: isDark ? const Color(0xFF16221A) : null,
            borderRadius: HabitikRadius.xl_,
            border: Border.all(
              color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green200.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? HabitikColors.green500.withValues(alpha: 0.05) 
                    : HabitikColors.green900.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar with Glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getGlowColor(user.nivel).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: UserAvatar(
                  letra: user.avatarLetra,
                  colorHex: user.avatarColor,
                  avatarUrl: user.avatarUrl,
                  radius: 48,
                  showBorder: true,
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(height: 16),
              
              // Name & Email
              Text(
                user.nombre,
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              
              if (user.email != null && user.email!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.email!,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : HabitikColors.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RolBadge(user.rol, fontSize: 12),
                  if (user.familyName != null && user.familyName!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E22) : HabitikColors.green50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HabitikColors.green200.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.home_rounded, size: 14, color: HabitikColors.green600),
                          const SizedBox(width: 4),
                          Text(
                            user.familyName!,
                            style: TextStyle(
                              color: isDark ? HabitikColors.green300 : HabitikColors.green800,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Gamification Stats (Glassmorphism inspired)
        XpProgressBar(xp: user.xp, nivel: user.nivel).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _GlassStatBadge(
                icon: '🪙',
                label: 'Monedas',
                value: '${user.monedas}',
                color: HabitikColors.amber400,
                isDark: isDark,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _GlassStatBadge(
                icon: '🔥',
                label: 'Racha',
                value: '${user.rachaDias} días',
                color: HabitikColors.orange500,
                isDark: isDark,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            ),
          ],
        ),
      ],
    );
  }

  Color _getGlowColor(int nivel) {
    if (nivel >= 5) return Colors.purpleAccent;
    if (nivel >= 3) return HabitikColors.amber400;
    return HabitikColors.green400;
  }
}

class _GlassStatBadge extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _GlassStatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16221A) : HabitikColors.green50,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.6),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.05 : 0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : HabitikColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
