import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class PollenParticle {
  Offset position;
  Offset velocity;
  double lifeTime;
  double maxLife;
  Color color;

  PollenParticle({
    required this.position,
    required this.velocity,
    required this.maxLife,
    required this.color,
  }) : lifeTime = 0.0;

  void update(double dt) {
    lifeTime += dt;
    position += Offset(velocity.dx * dt, velocity.dy * dt);
    position = Offset(
      position.dx + math.sin(lifeTime * 6.0) * 15.0 * dt,
      position.dy,
    );
  }

  double get opacity => (1.0 - (lifeTime / maxLife)).clamp(0.0, 1.0);
}

class Firefly {
  Vector2 position;
  double speed;
  double angle;
  double time;
  double pulseSpeed;
  double scale;

  Firefly({
    required this.position,
    required this.speed,
    required this.angle,
    required this.pulseSpeed,
    required this.scale,
  }) : time = 0.0;

  void update(double dt) {
    time += dt;
    position.x += math.cos(angle) * speed * dt;
    position.y += math.sin(angle) * speed * dt;
    angle += (math.sin(time) * 1.5) * dt;
  }
}

class CloudShadow {
  Vector2 position;
  double speed;
  double sizeX;
  double sizeY;

  CloudShadow({
    required this.position,
    required this.speed,
    required this.sizeX,
    required this.sizeY,
  });

  void update(double dt) {
    position.x += speed * dt;
    position.y += speed * 0.35 * dt;
  }
}
