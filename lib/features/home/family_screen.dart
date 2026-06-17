import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserProfile.mock;
    final members = FamilyMember.mockList;
    final sortedMembers = List<FamilyMember>.from(members)..sort((a, b) => b.xp.compareTo(a.xp));
    final maxXp = members.isEmpty ? 1 : members.map((m) => m.xp).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          bottom: false,
          child: ScreenShell(
            titulo: user.familyName ?? 'Mi Familia',
            subtitulo: 'Muro Familiar',
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Family Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: HabitikColors.heroGreen,
                    borderRadius: HabitikRadius.lg_,
                    border: Border.all(color: Colors.white, width: 3.0),
                    boxShadow: HabitikShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🏡', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.familyName ?? 'Mi Familia',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                const Text(
                                  'Miembros activos en Habitik',
                                  style: TextStyle(
                                    color: HabitikColors.green100,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summaryStat('${members.length}', 'Miembros'),
                          _summaryStat('${members.fold<int>(0, (prev, element) => prev + element.xp)}', 'XP Total'),
                          _summaryStat('Nivel ${user.nivel}', 'Nivel Promedio'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Ranking Section Title
                const GameSectionTitle(
                  icon: Icons.emoji_events_outlined,
                  title: 'Ranking de la Familia',
                ),
                const SizedBox(height: 12),

                // List of ranking cards
                Column(
                  children: sortedMembers.asMap().entries.map((e) {
                    final index = e.key;
                    final member = e.value;
                    return RankingCard(
                      position: index + 1,
                      member: member,
                      maxXp: maxXp,
                    ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms).slideX(begin: -0.05);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: HabitikColors.green100,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
