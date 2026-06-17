import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

class ConveyorBelt extends StatelessWidget {
  final Animation<double> controller;
  final List<Widget> items;

  const ConveyorBelt({
    super.key,
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // Enlarge conveyor belt container height (+20%)
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Belt background structure
          Positioned(
            left: 0,
            right: 0,
            height: 120, // Enlarge belt background structure height (+20%)
            child: Container(
              decoration: const BoxDecoration(
                color: HabitikColors.beltDark,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF282828),
                    Color(0xFF1B1B1B),
                    Color(0xFF121212),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Animating vertical division lines
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ConveyorLinesPainter(controller.value),
                        );
                      },
                    ),
                  ),
                  
                  // Rotating wheels (Reduced from 4 to 3 for better spacing / "menos junto")
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        return _ConveyorWheel(animation: controller);
                      }),
                    ),
                  ),

                  // Caution stripes on the right end (bounded by top/bottom rails)
                  Positioned(
                    top: 6,
                    bottom: 6,
                    right: 0,
                    width: 38, // Enlarge caution stripes width (+20%)
                    child: CustomPaint(
                      painter: _CautionStripesPainter(),
                    ),
                  ),

                  // Top Chrome Metal Rail
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withAlpha(140),
                            HabitikColors.beltMetalBorder,
                            HabitikColors.beltMetalBorder.withAlpha(178),
                            HabitikColors.beltGearDarkHub.withAlpha(76),
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Neon Cyan Glow Strip (Visual game element matching HUD)
                  Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: HabitikColors.gameTimerCyan.withAlpha(217),
                        boxShadow: [
                          BoxShadow(
                            color: HabitikColors.gameTimerCyan.withAlpha(153),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Chrome Metal Rail
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            HabitikColors.beltMetalBorder.withAlpha(217),
                            HabitikColors.beltMetalBorder,
                            HabitikColors.beltGearDarkHub.withAlpha(127),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Items stack
          ...items,
        ],
      ),
    );
  }
}

class _ConveyorLinesPainter extends CustomPainter {
  final double animationValue;

  _ConveyorLinesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // 3D carved grooves: dark shadow line followed by a thin light highlight line
    final Paint darkPaint = Paint()
      ..color = Colors.black.withAlpha(140)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint lightPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Increased spacing from 30.0 to 36.0 (+20%)
    const double spacing = 36.0;
    final double offset = animationValue * spacing;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      final double xx = x + offset;
      if (xx >= 0 && xx <= size.width) {
        // Draw the groove shadow
        canvas.drawLine(Offset(xx, 0), Offset(xx, size.height), darkPaint);
        // Draw the groove highlight right next to it
        canvas.drawLine(Offset(xx + 1.5, 0), Offset(xx + 1.5, size.height), lightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConveyorLinesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _CautionStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double stripeWidth = 5.0;
    final Paint paintYellow = Paint()..color = HabitikColors.beltYellowStripe;
    final Paint paintBlack = Paint()..color = HabitikColors.beltDark;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintYellow);

    for (double y = -size.width; y < size.height; y += stripeWidth * 2) {
      final Path path = Path()
        ..moveTo(0, y)
        ..lineTo(size.width, y + size.width)
        ..lineTo(size.width, y + size.width + stripeWidth)
        ..lineTo(0, y + stripeWidth)
        ..close();
      canvas.drawPath(path, paintBlack);
    }
  }

  @override
  bool shouldRepaint(covariant _CautionStripesPainter oldDelegate) => false;
}

class _ConveyorWheel extends StatelessWidget {
  final Animation<double> animation;

  const _ConveyorWheel({required this.animation});

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: CustomPaint(
        size: const Size(76, 76),
        painter: _WheelPainter(),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Outer edge dropshadow for depth
    canvas.drawCircle(
      Offset(cx + 1.5, cy + 1.5),
      r - 1.5,
      Paint()..color = Colors.black.withAlpha(102),
    );

    // Shiny metallic wheel base
    final Paint metalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HabitikColors.beltGearMetal.withAlpha(153),
          HabitikColors.beltMetalBorder,
          HabitikColors.beltGearMetal,
          const Color(0xFF37474F),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;

    final Paint darkPaint = Paint()
      ..color = HabitikColors.beltGearDarkHub
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer edge rim
    canvas.drawCircle(Offset(cx, cy), r - 1.5, metalPaint);
    canvas.drawCircle(Offset(cx, cy), r - 1.5, darkPaint);
    canvas.drawCircle(Offset(cx, cy), r - 5, darkPaint);

    // Center pivot
    canvas.drawCircle(Offset(cx, cy), 6.0, Paint()..color = HabitikColors.beltGearDarkHub);
    canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = Colors.white);

    // 6 spokes
    final Paint spokePaint = Paint()
      ..color = HabitikColors.beltGearDarkHub
      ..strokeWidth = 3.5;

    for (int i = 0; i < 6; i++) {
      final double angle = i * pi / 3;
      final double dx = cos(angle);
      final double dy = sin(angle);
      canvas.drawLine(
        Offset(cx + dx * 6, cy + dy * 6),
        Offset(cx + dx * (r - 5), cy + dy * (r - 5)),
        spokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
