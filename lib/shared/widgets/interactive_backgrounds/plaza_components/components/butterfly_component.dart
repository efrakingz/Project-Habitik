import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ButterflyComponent - Mariposas revoloteando
// ─────────────────────────────────────────────────────────────────────────────
class ButterflyComponent extends PositionComponent with HasGameReference {
  final math.Random _random = math.Random();
  double _time = 0.0;
  Vector2 _velocity = Vector2.zero();
  double _directionChangeTimer = 0.0;
  late final Color _wingColor;

  // Pre-allocated paint objects to avoid allocations in render loop
  late final Paint _bodyPaint = Paint()..color = const Color(0xFF3E2723);
  late final Paint _wingPaint;
  late final Paint _wingOutline = Paint()
    ..color = const Color(0xFF1A2E1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  final double? mapWidth;
  final double? mapHeight;

  ButterflyComponent({required Vector2 position, this.mapWidth, this.mapHeight})
    : super(
        position: position,
        size: Vector2(10, 10),
        anchor: Anchor.center,
        priority: 5,
      ) {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFFFFD54F),
      const Color(0xFFBA68C8),
      const Color(0xFF4FC3F7),
    ];
    _wingColor = colors[_random.nextInt(colors.length)];
    _wingPaint = Paint()..color = _wingColor;
    _velocity = Vector2(
      (_random.nextDouble() - 0.5) * 35.0,
      (_random.nextDouble() - 0.5) * 35.0,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    _directionChangeTimer += dt;
    if (_directionChangeTimer > 1.0) {
      _directionChangeTimer = 0.0;
      _velocity = Vector2(
        (_random.nextDouble() - 0.5) * 45.0,
        (_random.nextDouble() - 0.5) * 45.0,
      );
    }

    position += _velocity * dt;
    position.y += math.sin(_time * 14.0) * 0.4;

    // Wrap position to stay within bounds
    final limitX = mapWidth ?? game.size.x;
    final limitY = mapHeight ?? game.size.y;
    if (limitX > 0 && limitY > 0) {
      if (position.x < -20) position.x = limitX + 20;
      if (position.x > limitX + 20) position.x = -20;
      if (position.y < -20) position.y = limitY + 20;
      if (position.y > limitY + 20) position.y = -20;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 2, height: 8),
      _bodyPaint,
    );

    // Flapping is simulated by changing the wing width relative to the body edges at x = -1.0 and 1.0
    final wingWidth = 3.5 + math.sin(_time * 24.0) * 2.5;

    // Left wings
    canvas.drawOval(Rect.fromLTWH(-1.0 - wingWidth, -4, wingWidth, 5), _wingPaint);
    canvas.drawOval(Rect.fromLTWH(-1.0 - wingWidth, -4, wingWidth, 5), _wingOutline);
    canvas.drawOval(Rect.fromLTWH(-1.0 - wingWidth * 0.8, 0, wingWidth * 0.8, 4), _wingPaint);
    canvas.drawOval(Rect.fromLTWH(-1.0 - wingWidth * 0.8, 0, wingWidth * 0.8, 4), _wingOutline);

    // Right wings
    canvas.drawOval(Rect.fromLTWH(1.0, -4, wingWidth, 5), _wingPaint);
    canvas.drawOval(Rect.fromLTWH(1.0, -4, wingWidth, 5), _wingOutline);
    canvas.drawOval(Rect.fromLTWH(1.0, 0, wingWidth * 0.8, 4), _wingPaint);
    canvas.drawOval(Rect.fromLTWH(1.0, 0, wingWidth * 0.8, 4), _wingOutline);

    canvas.restore();
  }
}
