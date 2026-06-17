import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/core/theme/theme.dart';

class LevelSelect extends StatelessWidget {
  final Function(int) onLevelSelected;

  const LevelSelect({super.key, required this.onLevelSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.withAlpha(80), width: 3),
              ),
              child: const Icon(Icons.recycling, size: 70, color: Colors.green),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              'Selecciona un Nivel',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Arrastra los residuos al contenedor que corresponda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _LevelCard(
              title: 'Nivel 1: Inicio de Planta',
              desc: '4 contenedores • Ritmo relajado',
              icon: Icons.eco,
              color: Colors.green,
              onTap: () => onLevelSelected(1),
            ).animate().slideY(begin: 0.3, delay: 100.ms),
            const SizedBox(height: 16),
            _LevelCard(
              title: 'Nivel 2: Desafío Orgánico',
              desc: '5 contenedores • Ritmo medio',
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              onTap: () => onLevelSelected(2),
            ).animate().slideY(begin: 0.3, delay: 200.ms),
            const SizedBox(height: 16),
            _LevelCard(
              title: 'Nivel 3: Más Tipos',
              desc: '6 contenedores • Ritmo veloz',
              icon: Icons.hardware,
              color: Colors.red,
              onTap: () => onLevelSelected(3),
            ).animate().slideY(begin: 0.3, delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AudioService.playSFX('click.mp3');
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HabitikColors.gamePanelDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(80), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: color, size: 32),
          ],
        ),
      ),
    );
  }
}
