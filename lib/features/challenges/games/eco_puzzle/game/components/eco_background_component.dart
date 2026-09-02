import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Hoja o semilla que flota suavemente por el patio familiar
class FloatingGardenLeaf {
  double x;
  double y;
  double size;
  double speedY;
  double swaySpeed;
  double swayAmount;
  double rotation;
  double rotationSpeed;
  Color color;

  FloatingGardenLeaf({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.swaySpeed,
    required this.swayAmount,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

/// Mariposa animada que aletea por el jardín
class GardenButterfly {
  double x;
  double y;
  double targetX;
  double targetY;
  double speed;
  Color color;
  double wingFlapTime;

  GardenButterfly({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.color,
    required this.wingFlapTime,
  });
}

/// Fondo temático "El Jardín y Patio del Eco-Hogar" con cielo azul celeste fresco y soleado.
/// Incluye cielo celeste luminoso con nubes suaves, sol brillante, cerca blanca de madera,
/// macetas con plantas, arbustos con flores, césped cuidado y mariposas aleteando.
class EcoBackgroundComponent extends Component with HasGameReference {
  final List<FloatingGardenLeaf> _leaves = [];
  final List<GardenButterfly> _butterflies = [];
  double _time = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final rand = math.Random();
    final leafColors = [
      const Color(0xFF81C784),
      const Color(0xFFA5D6A7),
      const Color(0xFF4CAF50),
      const Color(0xFFFFE082),
    ];

    for (int i = 0; i < 16; i++) {
      _leaves.add(
        FloatingGardenLeaf(
          x: rand.nextDouble() * 400,
          y: rand.nextDouble() * 800,
          size: 7.0 + rand.nextDouble() * 8.0,
          speedY: 14.0 + rand.nextDouble() * 20.0,
          swaySpeed: 1.2 + rand.nextDouble() * 1.8,
          swayAmount: 18.0 + rand.nextDouble() * 26.0,
          rotation: rand.nextDouble() * math.pi * 2,
          rotationSpeed: (rand.nextDouble() - 0.5) * 1.6,
          color: leafColors[rand.nextInt(leafColors.length)],
        ),
      );
    }

    _butterflies.add(
      GardenButterfly(
        x: 60,
        y: 180,
        targetX: 280,
        targetY: 240,
        speed: 28,
        color: const Color(0xFFFBBF24),
        wingFlapTime: 0.0,
      ),
    );

    _butterflies.add(
      GardenButterfly(
        x: 320,
        y: 260,
        targetX: 80,
        targetY: 200,
        speed: 24,
        color: const Color(0xFFF472B6), // Mariposa rosada tierna
        wingFlapTime: 1.5,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    final h = game.size.y;
    final w = game.size.x;

    for (final leaf in _leaves) {
      leaf.y += leaf.speedY * dt;
      leaf.rotation += leaf.rotationSpeed * dt;

      if (leaf.y > h + 20) {
        leaf.y = -20;
        leaf.x = math.Random().nextDouble() * w;
      }
    }

    for (final b in _butterflies) {
      b.wingFlapTime += dt * 14.0;

      final dx = b.targetX - b.x;
      final dy = b.targetY - b.y;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist < 10) {
        final rand = math.Random();
        b.targetX = 40 + rand.nextDouble() * (w - 80);
        b.targetY = 140 + rand.nextDouble() * (h * 0.40);
      } else {
        b.x += (dx / dist) * b.speed * dt;
        b.y += (dy / dist) * b.speed * dt;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;

    // ── 1. Cielo Azul Celeste Fresco y Luminoso ──
    final skyRect = Rect.fromLTWH(0, 0, w, h);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF60A5FA), // Azul cielo vivo arriba
          Color(0xFF93C5FD), // Celeste claro intermedio
          Color(0xFFBAE6FD), // Celeste pastel suave
          Color(0xFFE0F2FE), // Celeste luminoso horizonte
          Color(0xFFDCFCE7), // Transición a verde césped
        ],
        stops: [0.0, 0.25, 0.50, 0.65, 1.0],
      ).createShader(skyRect);

    canvas.drawRect(skyRect, skyPaint);

    // ── 2. Nubes Blancas Esponjosas en el Cielo ──
    _drawPuffyClouds(canvas, w, h);

    // ── 3. Sol Radiante en la Esquina Superior Derecha ──
    final sunCenter = Offset(w * 0.84, h * 0.12);

    final sunAuraPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(sunCenter, 44, sunAuraPaint);

    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFBEB),
          Color(0xFFFBBF24),
          Color(0xFFF59E0B),
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 28));
    canvas.drawCircle(sunCenter, 28, sunPaint);

    // ── 4. Arbustos Frondosos y Flores al Fondo ──
    _drawBushesAndFlowers(canvas, w, h);

    // ── 5. Cerca Blanca de Madera del Patio ──
    _drawPicketFence(canvas, w, h);

    // ── 6. Macetas de Barro con Plantas ──
    _drawFlowerPots(canvas, w, h);

    // ── 7. Suelo del Jardín / Terraza Verde ──
    _drawPatioFloor(canvas, w, h);

    // ── 8. Hojitas Flotando ──
    for (final leaf in _leaves) {
      final swayX = math.sin(_time * leaf.swaySpeed + leaf.y * 0.05) * leaf.swayAmount;
      final currentX = leaf.x + swayX;

      canvas.save();
      canvas.translate(currentX, leaf.y);
      canvas.rotate(leaf.rotation);

      final leafPaint = Paint()
        ..color = leaf.color.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;

      final leafPath = Path()
        ..moveTo(0, -leaf.size)
        ..quadraticBezierTo(leaf.size * 0.5, 0, 0, leaf.size)
        ..quadraticBezierTo(-leaf.size * 0.5, 0, 0, -leaf.size)
        ..close();

      canvas.drawPath(leafPath, leafPaint);
      canvas.restore();
    }

    // ── 9. Mariposas Animadas ──
    for (final b in _butterflies) {
      _drawButterfly(canvas, b);
    }
  }

  void _drawPuffyClouds(Canvas canvas, double w, double h) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

    // Nube izquierda que se mueve lentamente
    final cloud1X = ((_time * 8.0) % (w + 140)) - 70;
    _drawSingleCloud(canvas, Offset(cloud1X, h * 0.18), 34, cloudPaint);

    // Nube derecha
    final cloud2X = ((_time * 6.0 + 200) % (w + 140)) - 70;
    _drawSingleCloud(canvas, Offset(cloud2X, h * 0.28), 28, Paint()..color = Colors.white.withValues(alpha: 0.70));
  }

  void _drawSingleCloud(Canvas canvas, Offset center, double baseR, Paint paint) {
    canvas.drawCircle(center, baseR, paint);
    canvas.drawCircle(center + Offset(-baseR * 0.7, baseR * 0.2), baseR * 0.65, paint);
    canvas.drawCircle(center + Offset(baseR * 0.7, baseR * 0.2), baseR * 0.65, paint);
    canvas.drawCircle(center + Offset(0, baseR * 0.3), baseR * 0.7, paint);
  }

  void _drawBushesAndFlowers(Canvas canvas, double w, double h) {
    final bushY = h * 0.52;

    // Arbusto verde profundo detrás
    final darkBushPaint = Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.85);
    canvas.drawCircle(Offset(w * 0.15, bushY - 20), 55, darkBushPaint);
    canvas.drawCircle(Offset(w * 0.45, bushY - 30), 65, darkBushPaint);
    canvas.drawCircle(Offset(w * 0.82, bushY - 15), 50, darkBushPaint);

    // Arbusto verde menta delante
    final lightBushPaint = Paint()..color = const Color(0xFF6EE7B7).withValues(alpha: 0.95);
    canvas.drawCircle(Offset(w * 0.28, bushY), 50, lightBushPaint);
    canvas.drawCircle(Offset(w * 0.65, bushY - 10), 60, lightBushPaint);
    canvas.drawCircle(Offset(w * 0.95, bushY + 10), 45, lightBushPaint);

    // Flores en los arbustos
    final flowerPoints = [
      Offset(w * 0.18, bushY - 25),
      Offset(w * 0.42, bushY - 35),
      Offset(w * 0.68, bushY - 18),
      Offset(w * 0.85, bushY - 20),
    ];

    for (final p in flowerPoints) {
      final petalPaint = Paint()..color = Colors.white;
      canvas.drawCircle(p + const Offset(-3, 0), 3.5, petalPaint);
      canvas.drawCircle(p + const Offset(3, 0), 3.5, petalPaint);
      canvas.drawCircle(p + const Offset(0, -3), 3.5, petalPaint);
      canvas.drawCircle(p + const Offset(0, 3), 3.5, petalPaint);
      canvas.drawCircle(p, 2.5, Paint()..color = const Color(0xFFFBBF24));
    }
  }

  void _drawPicketFence(Canvas canvas, double w, double h) {
    final fenceY = h * 0.54;
    final picketWidth = 14.0;
    final picketSpacing = 28.0;
    final picketHeight = 52.0;

    final railPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, fenceY + 14), Offset(w, fenceY + 14), railPaint);
    canvas.drawLine(Offset(0, fenceY + 36), Offset(w, fenceY + 36), railPaint);

    final picketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final picketShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (double x = 6; x < w + picketWidth; x += picketSpacing) {
      final path = Path()
        ..moveTo(x, fenceY + picketHeight)
        ..lineTo(x + picketWidth, fenceY + picketHeight)
        ..lineTo(x + picketWidth, fenceY + 10)
        ..lineTo(x + picketWidth / 2, fenceY)
        ..lineTo(x, fenceY + 10)
        ..close();

      canvas.drawPath(path.shift(const Offset(1, 2)), picketShadow);
      canvas.drawPath(path, picketPaint);
    }
  }

  void _drawFlowerPots(Canvas canvas, double w, double h) {
    final potPositions = [
      Offset(w * 0.10, h * 0.60),
      Offset(w * 0.90, h * 0.60),
    ];

    for (final pos in potPositions) {
      final potPaint = Paint()..color = const Color(0xFFE07A5F);
      final potRim = Paint()..color = const Color(0xFFD4694E);

      final potPath = Path()
        ..moveTo(pos.dx - 12, pos.dy + 8)
        ..lineTo(pos.dx + 12, pos.dy + 8)
        ..lineTo(pos.dx + 9, pos.dy + 26)
        ..lineTo(pos.dx - 9, pos.dy + 26)
        ..close();
      canvas.drawPath(potPath, potPaint);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(pos.dx, pos.dy + 7), width: 28, height: 6),
          const Radius.circular(3),
        ),
        potRim,
      );

      final sproutPaint = Paint()..color = const Color(0xFF059669)..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(pos.dx - 4, pos.dy), width: 8, height: 12), sproutPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(pos.dx + 4, pos.dy - 2), width: 9, height: 13), sproutPaint);
    }
  }

  void _drawPatioFloor(Canvas canvas, double w, double h) {
    final floorY = h * 0.64;

    final floorRect = Rect.fromLTWH(0, floorY, w, h - floorY);
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF86EFAC), // Verde césped fresco
          Color(0xFF4ADE80), // Verde pradera viva
          Color(0xFF22C55E), // Base sólida
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(floorRect);

    canvas.drawRect(floorRect, floorPaint);

    canvas.drawLine(
      Offset(0, floorY),
      Offset(w, floorY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 3.0,
    );
  }

  void _drawButterfly(Canvas canvas, GardenButterfly b) {
    canvas.save();
    canvas.translate(b.x, b.y);

    final wingScale = math.sin(b.wingFlapTime).abs() * 0.8 + 0.2;

    final wingPaint = Paint()
      ..color = b.color.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.scale(wingScale, 1.0);
    final leftWing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-10, -10, -8, 0)
      ..quadraticBezierTo(-10, 8, 0, 0);
    canvas.drawPath(leftWing, wingPaint);
    canvas.restore();

    canvas.save();
    canvas.scale(wingScale, 1.0);
    final rightWing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(10, -10, 8, 0)
      ..quadraticBezierTo(10, 8, 0, 0);
    canvas.drawPath(rightWing, wingPaint);
    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 2.5, height: 7),
      Paint()..color = const Color(0xFF1E293B),
    );

    canvas.restore();
  }
}
