import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Sparkle {
  Vector2 position;
  Vector2 velocity;
  double size;
  double alpha;
  Color color;
  double rotation;
  double rotationSpeed;

  Sparkle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.alpha,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

/// Componente de partículas de celebración y texto flotante al acertar un residuo en el tacho
class SuccessSparkleComponent extends PositionComponent {
  final String text;
  final Color themeColor;
  final List<Sparkle> _sparkles = [];
  double _lifeTimer = 0.0;
  final double _maxLife = 0.85;

  late final TextPainter _textPainter;

  SuccessSparkleComponent({
    required Vector2 position,
    required this.text,
    required this.themeColor,
  }) : super(position: position, priority: 150);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final rand = math.Random();
    final colors = [
      themeColor,
      const Color(0xFFFFD54F), // Oro brillante
      const Color(0xFF10B981), // Verde
      Colors.white,
    ];

    // Generar 14 chispas/estrellas que explotan hacia arriba
    for (int i = 0; i < 14; i++) {
      final angle = -math.pi / 2 + (rand.nextDouble() - 0.5) * 1.8;
      final speed = 70.0 + rand.nextDouble() * 90.0;

      _sparkles.add(
        Sparkle(
          position: Vector2.zero(),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          size: 5.0 + rand.nextDouble() * 6.0,
          alpha: 1.0,
          color: colors[rand.nextInt(colors.length)],
          rotation: rand.nextDouble() * math.pi * 2,
          rotationSpeed: (rand.nextDouble() - 0.5) * 6.0,
        ),
      );
    }

    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF047857),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: 8,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer += dt;

    final progress = _lifeTimer / _maxLife;
    for (final s in _sparkles) {
      s.position += s.velocity * dt;
      s.velocity.y += 120.0 * dt; // Gravedad suave
      s.rotation += s.rotationSpeed * dt;
      s.alpha = (1.0 - progress).clamp(0.0, 1.0);
    }

    if (_lifeTimer >= _maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _lifeTimer / _maxLife;

    // ── 1. Dibujar Chispas y Estrellitas ──
    for (final s in _sparkles) {
      final paint = Paint()
        ..color = s.color.withValues(alpha: s.alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(s.position.x, s.position.y);
      canvas.rotate(s.rotation);

      // Dibujar estrella de 4 puntas
      final starPath = Path()
        ..moveTo(0, -s.size)
        ..quadraticBezierTo(0, 0, s.size, 0)
        ..quadraticBezierTo(0, 0, 0, s.size)
        ..quadraticBezierTo(0, 0, -s.size, 0)
        ..quadraticBezierTo(0, 0, 0, -s.size)
        ..close();

      canvas.drawPath(starPath, paint);
      canvas.restore();
    }

    // ── 2. Dibujar Texto Flotante ("¡Genial! ✨") ──
    final textAlpha = (1.0 - progress * 1.2).clamp(0.0, 1.0);
    final textOffsetY = -24.0 - progress * 35.0; // Sube flotando

    canvas.save();
    canvas.translate(-_textPainter.width / 2, textOffsetY);

    // Fondo cápsula blanco para el texto
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-8, -3, _textPainter.width + 16, _textPainter.height + 6),
      const Radius.circular(10),
    );
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: textAlpha * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(bgRRect.shift(const Offset(0, 2)), shadowPaint);

    final bgPaint = Paint()..color = Colors.white.withValues(alpha: textAlpha * 0.95);
    canvas.drawRRect(bgRRect, bgPaint);

    _textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
