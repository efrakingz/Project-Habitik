import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import '../game/eco_puzzle_game.dart';
import '../game/models/eco_puzzle_state.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class FailureOverlay extends StatelessWidget {
  final EcoPuzzleGame game;

  const FailureOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcoPuzzleState>(
      valueListenable: game.gameStateNotifier,
      builder: (context, _, __) {
        if (game.gameState != EcoPuzzleState.failure) {
          return const SizedBox.shrink();
        }

        final timeOut = game.timeLeft <= 0;

        return Container(
          color: Colors.black.withValues(alpha: 0.7),
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💔', style: TextStyle(fontSize: 64))
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  '¡Oh no!',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  timeOut 
                    ? 'Se te agotó el tiempo. Debes ser más rápido clasificando la basura.'
                    : 'Cometiste demasiados errores. Asegúrate de separar bien los residuos.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: const Color(0xFF546E7A),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HabitikColors.green600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      game.overlays.remove('Failure');
                      game.retry();
                    },
                    child: Text(
                      'Intentar de nuevo',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => game.closeGame(),
                  child: Text(
                    'Volver al menú',
                    style: GoogleFonts.outfit(
                      color: HabitikColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).shake(hz: 3, offset: const Offset(5, 0)),
        );
      },
    );
  }
}
