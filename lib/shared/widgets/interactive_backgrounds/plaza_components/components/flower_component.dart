import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../models/particle_models.dart';
import '../mixins/visibility_aware_update.dart';

class AnimatedFlowerComponent extends PositionComponent with VisibilityAwareUpdate {
  final Color petalColor;
  double _swayTime = 0.0;
  late double _swaySpeed;
  late double _swayAmplitude;

  ui.Picture? _cachedPicture;
  final List<PollenParticle> _particles = [];
  final math.Random _random = math.Random();
  double _particleTimer = 0.0;

  AnimatedFlowerComponent({required Vector2 position, required this.petalColor})
    : super(
        position: position,
        size: Vector2(14, 20),
        anchor: Anchor.bottomCenter,
        priority: 10 + position.y.toInt(),
      ) {
    final seed = position.x.toInt() ^ position.y.toInt();
    final random = math.Random(seed);
    _swaySpeed = 1.3 + random.nextDouble() * 1.8;
    _swayAmplitude = 0.04 + random.nextDouble() * 0.03;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _swayTime += dt;

    // Update existing particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (_particles[i].lifeTime >= _particles[i].maxLife) {
        _particles.removeAt(i);
      }
    }

    // Emit new particles
    _particleTimer += dt;
    if (_particleTimer > 1.0 + _random.nextDouble() * 1.5) {
      _particleTimer = 0.0;
      if (_particles.length < 4) {
        _particles.add(
          PollenParticle(
            position: Offset(size.x / 2, size.y - 13),
            velocity: Offset(
              (_random.nextDouble() - 0.5) * 12.0,
              -8.0 - _random.nextDouble() * 12.0,
            ),
            maxLife: 2.0 + _random.nextDouble() * 2.0,
            color: const Color(0xFFFFD54F).withValues(alpha: 0.8), // Warm pollen gold/yellow
          ),
        );
      }
    }
  }

  void _createCachedPicture() {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Tallo
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.x / 2, size.y),
      Offset(size.x / 2, size.y - 11),
      stemPaint,
    );

    // Hojas pequeñas
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawOval(
      Rect.fromLTWH(size.x / 2 - 4.5, size.y - 7, 3.5, 2.5),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.x / 2 + 1, size.y - 5.5, 3.5, 2.5),
      leafPaint,
    );

    // Pétalos de colores
    final petalPaint = Paint()..color = petalColor;
    final centerPaint = Paint()..color = const Color(0xFFFFD54F);
    final petalR = 2.4;
    final flowerCenter = Offset(size.x / 2, size.y - 13);

    canvas.drawCircle(
      flowerCenter + Offset(-petalR * 0.75, 0),
      petalR,
      petalPaint,
    );
    canvas.drawCircle(
      flowerCenter + Offset(petalR * 0.75, 0),
      petalR,
      petalPaint,
    );
    canvas.drawCircle(
      flowerCenter + Offset(0, -petalR * 0.75),
      petalR,
      petalPaint,
    );
    canvas.drawCircle(
      flowerCenter + Offset(0, petalR * 0.75),
      petalR,
      petalPaint,
    );

    canvas.drawCircle(flowerCenter, 1.8, centerPaint);

    _cachedPicture = recorder.endRecording();
  }

  @override
  void render(ui.Canvas canvas) {
    if (_cachedPicture == null) {
      _createCachedPicture();
    }

    canvas.save();

    canvas.translate(size.x / 2, size.y);
    final angle = math.sin(_swayTime * _swaySpeed) * _swayAmplitude;
    canvas.rotate(angle);
    canvas.translate(-size.x / 2, -size.y);

    canvas.drawPicture(_cachedPicture!);

    canvas.restore();

    // Render particles (glowing core and outer glow)
    final corePaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;
    for (final p in _particles) {
      final currentOpacity = p.opacity * p.color.a;
      
      // Outer glow
      glowPaint.color = p.color.withValues(alpha: currentOpacity * 0.4);
      canvas.drawCircle(p.position, 3.2, glowPaint);
      
      // Core
      corePaint.color = const Color(0xFFFFF59D).withValues(alpha: currentOpacity);
      canvas.drawCircle(p.position, 1.4, corePaint);
    }
  }
}
