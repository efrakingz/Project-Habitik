import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Este es tu muro familiar',
          subtitulo: 'Aquí debe ir tu familia',
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2E22) : Colors.white,
                    borderRadius: HabitikRadius.lg_,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                      width: 2,
                    ),
                    boxShadow: HabitikShadows.card,
                  ),
                  child: Column(
                    children: [
                      const Text('👥', style: TextStyle(fontSize: 54))
                          .animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      const Text(
                        'Ranking de la Familia',
                        style: TextStyle(
                          color: HabitikColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Compara el XP acumulado por cada miembro y descubre quién lidera la sustentabilidad en casa.',
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: HabitikColors.heroGreen,
                            borderRadius: HabitikRadius.md_,
                            boxShadow: HabitikShadows.colored(HabitikColors.green600),
                          ),
                          child: const Text(
                            '👥 Ver Miembros',
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
