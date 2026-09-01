import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class ProfileFamilyList extends StatelessWidget {
  final bool loading;
  final String? errorMessage;
  final List<FamilyMember> familyMembers;
  final VoidCallback onRetry;
  final bool isDark;

  const ProfileFamilyList({
    super.key,
    required this.loading,
    required this.errorMessage,
    required this.familyMembers,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              const Text('👥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'Miembros del Hogar',
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: HabitikColors.green600),
            ),
          )
        else if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C1E1E) : Colors.red.shade50,
              borderRadius: HabitikRadius.md_,
              border: Border.all(
                color: isDark ? Colors.redAccent.withAlpha(50) : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Error al cargar miembros: $errorMessage',
                  style: TextStyle(
                    color: isDark ? Colors.redAccent : Colors.red.shade800,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Reintentar',
                  onTap: onRetry,
                  color: Colors.redAccent,
                ),
              ],
            ),
          )
        else if (familyMembers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2E22) : Colors.white,
              borderRadius: HabitikRadius.md_,
              border: Border.all(
                color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
              ),
            ),
            child: const Text(
              'No hay otros miembros en la familia todavía.',
              style: TextStyle(color: HabitikColors.textLight, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: familyMembers.length,
            itemBuilder: (context, index) {
              final member = familyMembers[index];
              final maxXP = familyMembers.fold<int>(
                1,
                (prev, elem) => elem.xp > prev ? elem.xp : prev,
              );
              return RankingCard(
                position: index + 1,
                member: member,
                maxXp: maxXP,
              );
            },
          ),
      ],
    );
  }
}
