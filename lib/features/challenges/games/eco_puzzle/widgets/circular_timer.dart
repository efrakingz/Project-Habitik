import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';

class CircularTimer extends StatelessWidget {
  final int timeLeft;
  final int totalTimeLimit;
  final int score;
  final int targetScore;

  const CircularTimer({
    super.key,
    required this.timeLeft,
    required this.totalTimeLimit,
    required this.score,
    required this.targetScore,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = timeLeft <= 10;
    final color = isCritical ? Colors.red : HabitikColors.gameTimerCyan;
    final progress = timeLeft / totalTimeLimit;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: HabitikColors.gamePanelDark,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '0:${timeLeft.toString().padLeft(2, '0')}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$score/$targetScore LISTO',
          style: GoogleFonts.pressStart2p(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
