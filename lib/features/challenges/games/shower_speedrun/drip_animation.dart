import 'dart:math';
import 'package:flutter/material.dart';

class ShowerDripAnimation extends StatefulWidget {
  final bool active;
  const ShowerDripAnimation({super.key, required this.active});

  @override
  State<ShowerDripAnimation> createState() => _ShowerDripAnimationState();
}

class _ShowerDripAnimationState extends State<ShowerDripAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Drip> _drips = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Initialize drip particles
    for (int i = 0; i < 15; i++) {
      _drips.add(_Drip(
        xPct: 0.15 + _rand.nextDouble() * 0.7, // Keep within shower cabin width
        speed: 0.7 + _rand.nextDouble() * 0.5,
        delay: _rand.nextDouble(),
        size: 3.5 + _rand.nextDouble() * 4.5,
      ));
    }

    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShowerDripAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _DripPainter(
            drips: _drips,
            progress: _controller.value,
            active: widget.active,
          ),
        );
      },
    );
  }
}

class _Drip {
  final double xPct;
  final double speed;
  final double delay;
  final double size;
  _Drip({required this.xPct, required this.speed, required this.delay, required this.size});
}

class _DripPainter extends CustomPainter {
  final List<_Drip> drips;
  final double progress;
  final bool active;

  _DripPainter({required this.drips, required this.progress, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    
    final paint = Paint()
      ..color = const Color(0xFF29B6F6).withAlpha(160)
      ..style = PaintingStyle.fill;

    for (final drip in drips) {
      // Calculate current vertical position based on delay, speed, and progress
      double t = (progress + drip.delay) % 1.0;
      t = (t * drip.speed) % 1.0;

      final x = size.width * drip.xPct;
      final y = size.height * t;

      // Draw drop shape
      final path = Path()
        ..moveTo(x, y - drip.size)
        ..quadraticBezierTo(x - drip.size / 2, y, x, y + drip.size / 2)
        ..quadraticBezierTo(x + drip.size / 2, y, x, y - drip.size)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DripPainter old) => old.progress != progress || old.active != active;
}
