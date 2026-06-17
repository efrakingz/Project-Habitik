import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import 'package:habitik/features/notifications/notifications_screen.dart';
import 'package:habitik/features/profile/profile_screen.dart';
import 'package:habitik/features/home/family_screen.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/light_clear_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _user = UserProfile.mock;
  final _evidences = EvidenceItem.mockList;
  final Set<String> _liked = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────────
            buildHomeHeader(
              context: context,
              familyName: _user.familyName ?? 'Mi Familia',
              userName: _user.nombre,
              userRol: _user.rol,
              avatarLetra: _user.avatarLetra,
              avatarColor: _user.avatarColor,
              notifCount: 2,
              onNotifTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              ),
              onAvatarTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ),
              onFamilyTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FamilyScreen()),
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111D15) : HabitikColors.bgLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Stack(
                    children: [
                      // Fondo interactivo claro de Flame
                      const Positioned.fill(
                        child: LightClearBackground(),
                      ),
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        children: [
                          // XP Progress
                          XpProgressBar(xp: _user.xp, nivel: _user.nivel)
                              .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                          const SizedBox(height: 16),

                          // Coins chip
                          _CoinsChip(monedas: _user.monedas)
                              .animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),

                          const SizedBox(height: 20),

                          // Actividad de la Familia / Muro Title
                          const GameSectionTitle(
                            icon: Icons.feed_outlined,
                            title: 'Actividad de la Familia',
                          ),
                          const SizedBox(height: 12),

                          // Feed directly
                          Column(
                            children: _evidences.asMap().entries.map((e) => EvidenceCard(
                              evidence: e.value,
                              liked: _liked.contains(e.value.id),
                              onLike: () => setState(() {
                                if (_liked.contains(e.value.id)) {
                                  _liked.remove(e.value.id);
                                } else {
                                  _liked.add(e.value.id);
                                }
                              }),
                              index: e.key,
                            )).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinsChip extends StatelessWidget {
  final int monedas;
  const _CoinsChip({required this.monedas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: HabitikColors.xpGold,
        borderRadius: HabitikRadius.md_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.colored(HabitikColors.amber400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GameCoinIcon(size: 20),
          const SizedBox(width: 8),
          Text('$monedas monedas disponibles', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: HabitikRadius.xxl_),
            child: const Text('Canjear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}


