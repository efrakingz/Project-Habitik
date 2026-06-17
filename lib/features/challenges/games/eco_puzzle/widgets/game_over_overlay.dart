import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';

class GameOverOverlay extends StatelessWidget {
  final bool won;
  final int score;
  final int targetScore;
  final VoidCallback onComplete;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const GameOverOverlay({
    super.key,
    required this.won,
    required this.score,
    required this.targetScore,
    required this.onComplete,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(180),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HabitikColors.gameBlueBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: won ? HabitikColors.gameSuccessGreen : Colors.red,
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (won ? HabitikColors.gameSuccessGreen : Colors.red).withAlpha(100),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 70,
                color: won ? Colors.amber : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                won ? '¡OBJETIVO LOGRADO!' : '¡TIEMPO AGOTADO!',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Clasificaste $score de $targetScore residuos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 28),
              if (won)
                ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.gameSuccessGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: Text(
                    'RECLAMAR RECOMPENSA',
                    style: GoogleFonts.pressStart2p(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onMenu,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('MENÚ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('REINTENTAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
