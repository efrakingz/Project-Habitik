import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ErrorParticle {
  Vector2 position;
  Vector2 velocity;
  double size;
  double alpha;
  Color color;

  ErrorParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.alpha,
    required this.color,
  });
}

/// Componente de partículas de error y texto flotante ("¡Aquí no! ❌")
/// al soltar un residuo en el contenedor equivocado.
class ErrorFeedbackComponent extends PositionComponent {
  final String text;
  final List<ErrorParticle> _particles = [];
  double _lifeTimer = 0.0;
  final double _maxLife = 0.85;

  late final TextPainter _textPainter;

  ErrorFeedbackComponent({
    required Vector2 position,
    required this.text,
  }) : super(position: position, priority: 150);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final rand = math.Random();
    final colors = [
      const Color(0xFFEF4444), // Rojo error
      const Color(0xFFF87171), // Rojo suave
      const Color(0xFFFDA4AF), // Rosa alerta
      Colors.white,
    ];

    // Generar partículas de nube / polvo de rechazo
    for (int i = 0; i < 10; i++) {
      final angle = (rand.nextDouble() * math.pi * 2);
      final speed = 40.0 + rand.nextDouble() * 50.0;

      _particles.add(
        ErrorParticle(
          position: Vector2.zero(),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 20),
          size: 4.0 + rand.nextDouble() * 5.0,
          alpha: 1.0,
          color: colors[rand.nextInt(colors.length)],
        ),
      );
    }

    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 15,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: 6,
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
    for (final p in _particles) {
      p.position += p.velocity * dt;
      p.velocity.y += 40.0 * dt; // Gravedad suave
      p.alpha = (1.0 - progress).clamp(0.0, 1.0);
    }

    if (_lifeTimer >= _maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _lifeTimer / _maxLife;

    // ── 1. Dibujar Partículas de Rechazo ──
    for (final p in _particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size, paint);
    }

    // ── 2. Dibujar Píldora Flotante ("¡Aquí no! ❌") ──
    final textAlpha = (1.0 - progress * 1.2).clamp(0.0, 1.0);
    final textOffsetY = -20.0 - progress * 30.0;

    canvas.save();
    canvas.translate(-_textPainter.width / 2, textOffsetY);

    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-8, -3, _textPainter.width + 16, _textPainter.height + 6),
      const Radius.circular(10),
    );

    // Sombra suave
    final shadowPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: textAlpha * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(bgRRect.shift(const Offset(0, 2)), shadowPaint);

    // Fondo blanco con borde rojo
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: textAlpha * 0.96);
    canvas.drawRRect(bgRRect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: textAlpha * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bgRRect, borderPaint);

    _textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
