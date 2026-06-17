import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = HabitikColors.gameBlueBg;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final crossPaint = Paint()
      ..color = HabitikColors.gameGridLines
      ..strokeWidth = 1.2;

    const step = 36.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        // Draw small blueprint grid crosses
        canvas.drawLine(Offset(x - 3, y), Offset(x + 3, y), crossPaint);
        canvas.drawLine(Offset(x, y - 3), Offset(x, y + 3), crossPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
