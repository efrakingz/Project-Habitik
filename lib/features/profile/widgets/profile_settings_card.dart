import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/features/auth/splash_screen.dart';

class ProfileSettingsCard extends StatelessWidget {
  final bool isDark;

  const ProfileSettingsCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Ajustes',
            style: TextStyle(
              color: isDark ? Colors.white70 : HabitikColors.textMid,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16221A) : HabitikColors.green50,
            borderRadius: HabitikRadius.lg_,
            border: Border.all(
              color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green200.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : HabitikColors.green900.withValues(alpha: 0.04),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                context: context,
                icon: Icons.person_outline_rounded,
                iconColor: HabitikColors.green500,
                title: 'Editar Perfil',
                subtitle: 'Personaliza tu avatar y nombre',
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente disponible'),
                      backgroundColor: HabitikColors.green700,
                    ),
                  );
                },
              ),
              
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                indent: 64,
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.indigoAccent : Colors.orange).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                        color: isDark ? Colors.indigoAccent : Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Modo Oscuro',
                        style: TextStyle(
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isDarkModeNotifier,
                      builder: (context, isDarkTheme, _) {
                        return Switch(
                          value: isDarkTheme,
                          onChanged: (val) {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (context, anim1, anim2) => ThemeTransitionScreen(targetIsDark: val),
                                transitionsBuilder: (context, anim1, anim2, child) {
                                  return FadeTransition(opacity: anim1, child: child);
                                },
                                transitionDuration: 400.ms,
                              ),
                            );
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: HabitikColors.green600,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade300,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.05),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : HabitikColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
