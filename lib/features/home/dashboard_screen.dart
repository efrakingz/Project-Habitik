import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/features/notifications/notifications_screen.dart';
import 'package:habitik/features/profile/profile_screen.dart';
import 'package:habitik/features/home/family_screen.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _user = UserProfile.mock;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Este es tu muro familiar',
          subtitulo: 'Aquí debe ir tu familia',
          headerLeft: GestureDetector(
            onTap: () => Navigator.push(
              context,
              FadePageRoute(child: const FamilyScreen()),
            ),
            child: UserAvatar(
              letra: (_user.familyName ?? 'F').isNotEmpty
                  ? (_user.familyName ?? 'F')[0]
                  : 'F',
              colorHex: _user.avatarColor,
              radius: 22,
            ),
          ),
          headerActions: [
            IconActionButton(
              icon: Icons.notifications_outlined,
              onTap: () => Navigator.push(
                context,
                FadePageRoute(child: const NotificationsScreen()),
              ),
              hasBadge: true,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                FadePageRoute(child: const ProfileScreen()),
              ),
              child: UserAvatar(
                letra: _user.avatarLetra,
                colorHex: _user.avatarColor,
                radius: 20,
                showBorder: true,
              ),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E2E22)
                        : Colors.white,
                    borderRadius: HabitikRadius.lg_,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0x30FFFFFF)
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                    boxShadow: HabitikShadows.card,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🏡',
                        style: TextStyle(fontSize: 54),
                      ).animate().scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Muro Familiar',
                        style: TextStyle(
                          color: HabitikColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Visualiza la actividad de ahorro y el progreso ecológico de tu hogar en tiempo real.',
                        style: TextStyle(
                          color: HabitikColors.textLight,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: HabitikColors.heroGreen,
                            borderRadius: HabitikRadius.md_,
                            boxShadow: HabitikShadows.colored(
                              HabitikColors.green600,
                            ),
                          ),
                          child: const Text(
                            '🏡 Ver Muro Completo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
