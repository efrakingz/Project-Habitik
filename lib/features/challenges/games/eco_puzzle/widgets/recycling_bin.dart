import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/waste_item.dart';

class PixelBinWidget extends StatelessWidget {
  final BinData bin;
  final bool isHovered;
  final double width;
  final double height;

  const PixelBinWidget({
    super.key,
    required this.bin,
    required this.isHovered,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _BinShapePainter(
              color: bin.color,
              isHovered: isHovered,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: bin.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              bin.name,
              style: GoogleFonts.pressStart2p(
                fontSize: 6.5,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BinShapePainter extends CustomPainter {
  final Color color;
  final bool isHovered;

  _BinShapePainter({required this.color, required this.isHovered});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Extract dark shades for 3D depth
    final hsv = HSVColor.fromColor(color);
    final bodyColor = hsv.withValue((hsv.value * 0.82).clamp(0.0, 1.0)).toColor();
    final shadowColor = hsv.withValue((hsv.value * 0.55).clamp(0.0, 1.0)).toColor();
    final topColor = color;

    // Height of top lip is proportionate, e.g. 20% of height, max of 18px
    final double lipHeight = (h * 0.18).clamp(8.0, 18.0);

    // Drop shadow under bin
    final shadowPaint = Paint()..color = Colors.black.withAlpha(90);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, h - 3, w - 16, 3),
        const Radius.circular(1.5),
      ),
      shadowPaint,
    );

    // Bin trapezoidal body
    final Path bodyPath = Path()
      ..moveTo(6, lipHeight)
      ..lineTo(w - 6, lipHeight)
      ..lineTo(w - 11, h - 2)
      ..lineTo(11, h - 2)
      ..close();
    
    final Paint bodyPaint = Paint()..color = bodyColor;
    canvas.drawPath(bodyPath, bodyPaint);

    // Bin lip/rim (top lid)
    final Paint lipPaint = Paint()..color = topColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 0, w - 4, lipHeight),
        const Radius.circular(2.5),
      ),
      lipPaint,
    );

    // Dark stroke outline
    final Paint strokePaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 0, w - 4, lipHeight),
        const Radius.circular(2.5),
      ),
      strokePaint,
    );
    canvas.drawPath(bodyPath, strokePaint);

    // Draw pixel recycling logo in center of bucket
    final Paint logoPaint = Paint()..color = Colors.white;
    // Adapt logo size to bucket height
    final double logoSize = (h * 0.18).clamp(8.0, 14.0);
    _drawPixelLogo(canvas, w / 2, lipHeight + (h - lipHeight) / 2 - 1, logoSize, logoPaint);

    // Glow highlight if dragged item is hovering over this bin
    if (isHovered) {
      final Paint glowPaint = Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, -2, w, h + 4),
          const Radius.circular(4),
        ),
        glowPaint,
      );
    }
  }

  void _drawPixelLogo(Canvas canvas, double cx, double cy, double size, Paint paint) {
    final double blockSize = size / 5;
    final logoMap = [
      [0, 1, 1, 1, 0],
      [1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [0, 1, 1, 1, 0],
    ];

    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        if (logoMap[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              cx - (size / 2) + (c * blockSize),
              cy - (size / 2) + (r * blockSize),
              blockSize - 0.5,
              blockSize - 0.5,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BinShapePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isHovered != isHovered;
  }
}
