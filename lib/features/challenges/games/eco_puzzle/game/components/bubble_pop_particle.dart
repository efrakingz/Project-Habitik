import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Droplet {
  Vector2 position;
  Vector2 velocity;
  double radius;
  double alpha;
  Color color;

  Droplet({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.alpha,
    required this.color,
  });
}

/// Partículas de estallido de burbuja (Bubble Pop Splash) con gotitas translúcidas
class BubblePopParticleComponent extends PositionComponent {
  final List<Droplet> _droplets = [];
  double _lifeTimer = 0.0;
  final double _maxLife = 0.45;

  BubblePopParticleComponent({
    required Vector2 position,
    Color tintColor = const Color(0xFF67E8F9),
  }) : super(position: position, priority: 140) {
    final rand = math.Random();
    for (int i = 0; i < 12; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 60.0 + rand.nextDouble() * 80.0;

      _droplets.add(
        Droplet(
          position: Vector2.zero(),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          radius: 3.0 + rand.nextDouble() * 4.0,
          alpha: 0.9,
          color: i % 2 == 0 ? Colors.white : tintColor,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer += dt;

    final progress = _lifeTimer / _maxLife;
    for (final d in _droplets) {
      d.position += d.velocity * dt;
      d.velocity.y += 80.0 * dt; // Gravedad suave
      d.alpha = (1.0 - progress).clamp(0.0, 1.0);
    }

    if (_lifeTimer >= _maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final d in _droplets) {
      final paint = Paint()
        ..color = d.color.withValues(alpha: d.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(d.position.x, d.position.y), d.radius, paint);

      // Brillo en la gotita
      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: d.alpha * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(d.position.x - d.radius * 0.3, d.position.y - d.radius * 0.3), d.radius * 0.35, highlight);
    }
  }
}
