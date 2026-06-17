import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ocean_sprites.dart – Pixel-art CustomPainters para el juego Mar Limpio
// Todos los sprites se dibujan programáticamente con Canvas/Paint
// ─────────────────────────────────────────────────────────────────────────────

// ─── Colores de paleta ────────────────────────────────────────────────────────
const oceanDeep     = Color(0xFF003F5C);
const oceanMid      = Color(0xFF0077B6);
const oceanShallow  = Color(0xFF00B4D8);
const oceanSurface  = Color(0xFF90E0EF);
const sandColor     = Color(0xFFDDB892);
const coralRed      = Color(0xFFE63946);
const coralPink     = Color(0xFFFF6B9D);
const seaweedGreen  = Color(0xFF2DC653);
const fishBlueLight = Color(0xFF48CAE4);
const fishBlueDark  = Color(0xFF0096C7);
const fishGoldLight = Color(0xFFFFD166);
const fishGoldDark  = Color(0xFFEF9C1A);
const trashGrey     = Color(0xFF8D9DB6);
const trashBrown    = Color(0xFF6B4226);
const jellyPurple   = Color(0xFFD4A5F5);
const jellyPink     = Color(0xFFFF85A1);
const octopusPurple = Color(0xFF7B2D8B);
const bubbleBlue    = Color(0xFFADE8F4);

// ─────────────────────────────────────────────────────────────────────────────
// Painter de fondo oceánico (cielo + agua + rayos + fondo marino)
// ─────────────────────────────────────────────────────────────────────────────
class OceanBackgroundPainter extends CustomPainter {
  final double time;
  final double waterY; // Y donde comienza el agua (fracción 0-1)

  OceanBackgroundPainter({required this.time, required this.waterY});

  @override
  void paint(Canvas canvas, Size size) {
    final skyH = size.height * waterY;
    final waterH = size.height - skyH;

    // ── Cielo ─────────────────────────────────────────────────────────────────
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF87CEEB), Color(0xFFB0E2FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, skyH));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, skyH), skyPaint);

    // ── Sol ───────────────────────────────────────────────────────────────────
    final sunPaint = Paint()..color = const Color(0xFFFFF176);
    canvas.drawCircle(Offset(size.width * 0.75, skyH * 0.35), 22, sunPaint);
    // rayos del sol
    final rayPaint = Paint()
      ..color = const Color(0x40FFD600)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + time * 0.3;
      final cx = size.width * 0.75;
      final cy = skyH * 0.35;
      canvas.drawLine(
        Offset(cx + cos(angle) * 26, cy + sin(angle) * 26),
        Offset(cx + cos(angle) * 38, cy + sin(angle) * 38),
        rayPaint,
      );
    }

    // ── Nubes ─────────────────────────────────────────────────────────────────
    _drawCloud(canvas, Offset(size.width * 0.2 + sin(time * 0.05) * 3, skyH * 0.3), 40, 18);
    _drawCloud(canvas, Offset(size.width * 0.6 + sin(time * 0.04 + 1) * 2, skyH * 0.2), 55, 22);

    // ── Agua – gradiente ──────────────────────────────────────────────────────
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF00B4D8),
          Color(0xFF0096C7),
          Color(0xFF0077B6),
          Color(0xFF023E8A),
          Color(0xFF03045E),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, skyH, size.width, waterH));
    canvas.drawRect(Rect.fromLTWH(0, skyH, size.width, waterH), waterPaint);

    // ── Rayos de luz bajo el agua ─────────────────────────────────────────────
    final rayCount = 5;
    for (int i = 0; i < rayCount; i++) {
      final xBase = size.width * (i / rayCount) + sin(time * 0.3 + i) * 20;
      final rayWidth = 20.0 + sin(time * 0.5 + i) * 8;
      final rayPath = Path()
        ..moveTo(xBase - rayWidth / 2, skyH)
        ..lineTo(xBase + rayWidth / 2, skyH)
        ..lineTo(xBase + rayWidth * 2, size.height * 0.75)
        ..lineTo(xBase - rayWidth * 1.5, size.height * 0.75)
        ..close();
      canvas.drawPath(
        rayPath,
        Paint()..color = const Color(0x0AFFFFFF),
      );
    }

    // ── Olas (superficie) ─────────────────────────────────────────────────────
    _drawWaves(canvas, size, skyH, time);

    // ── Fondo marino ──────────────────────────────────────────────────────────
    _drawSeaFloor(canvas, size);
  }

  void _drawCloud(Canvas canvas, Offset center, double w, double h) {
    final p = Paint()..color = Colors.white.withAlpha(200);
    canvas.drawOval(Rect.fromCenter(center: center, width: w, height: h), p);
    canvas.drawOval(Rect.fromCenter(center: center.translate(-w * 0.28, h * 0.1), width: w * 0.6, height: h * 0.8), p);
    canvas.drawOval(Rect.fromCenter(center: center.translate(w * 0.28, h * 0.1), width: w * 0.5, height: h * 0.7), p);
  }

  void _drawWaves(Canvas canvas, Size size, double y, double t) {
    // Wave 1 (front, darker)
    final wave1 = Paint()..color = const Color(0xFF48CAE4).withAlpha(180);
    final path1 = Path()..moveTo(0, y);
    for (double x = 0; x <= size.width; x += 2) {
      path1.lineTo(x, y + sin((x / 40) + t * 2) * 5 + cos((x / 25) + t * 1.5) * 3);
    }
    path1.lineTo(size.width, y + 12);
    path1.lineTo(0, y + 12);
    path1.close();
    canvas.drawPath(path1, wave1);

    // Wave 2 (back, lighter)
    final wave2 = Paint()..color = const Color(0xFFADE8F4).withAlpha(120);
    final path2 = Path()..moveTo(0, y - 4);
    for (double x = 0; x <= size.width; x += 2) {
      path2.lineTo(x, y - 4 + sin((x / 35 + 1) + t * 1.7) * 4 + cos((x / 20 + 2) + t) * 2);
    }
    path2.lineTo(size.width, y + 6);
    path2.lineTo(0, y + 6);
    path2.close();
    canvas.drawPath(path2, wave2);
  }

  void _drawSeaFloor(Canvas canvas, Size size) {
    final sandH = size.height * 0.10;
    final sandY = size.height - sandH;

    // Arena
    final sandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [sandColor.withAlpha(180), sandColor],
      ).createShader(Rect.fromLTWH(0, sandY, size.width, sandH));
    canvas.drawRect(Rect.fromLTWH(0, sandY, size.width, sandH), sandPaint);

    // Piedras decorativas
    final stonePaint = Paint()..color = const Color(0xFF8D9DB6);
    for (int i = 0; i < 6; i++) {
      final rx = size.width * (i / 6) + 20;
      canvas.drawOval(Rect.fromCenter(center: Offset(rx, sandY + 8), width: 18 + i * 3.0, height: 10 + i.toDouble()), stonePaint);
    }

    // Algas
    for (int i = 0; i < 5; i++) {
      _drawSeaweed(canvas, Offset(size.width * 0.15 * (i + 0.5), sandY), 25 + i * 5.0);
    }

    // Coral
    _drawCoral(canvas, Offset(size.width * 0.25, sandY));
    _drawCoral(canvas, Offset(size.width * 0.6, sandY));
    _drawCoral(canvas, Offset(size.width * 0.85, sandY));
  }

  void _drawSeaweed(Canvas canvas, Offset base, double height) {
    final p = Paint()
      ..color = seaweedGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(base.dx, base.dy);
    path.cubicTo(
      base.dx + 10, base.dy - height * 0.33,
      base.dx - 10, base.dy - height * 0.66,
      base.dx + 5, base.dy - height,
    );
    canvas.drawPath(path, p);
  }

  void _drawCoral(Canvas canvas, Offset base) {
    final p = Paint()..color = coralPink;
    final stemP = Paint()..color = coralRed..strokeWidth = 4..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(base.dx, base.dy), Offset(base.dx, base.dy - 20), stemP);
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      canvas.drawLine(Offset(base.dx, base.dy - 10), Offset(base.dx + i * 8, base.dy - 20), stemP);
      canvas.drawCircle(Offset(base.dx + i * 8, base.dy - 22), 4, p);
    }
    canvas.drawCircle(Offset(base.dx, base.dy - 23), 5, p);
  }

  @override
  bool shouldRepaint(OceanBackgroundPainter old) => old.time != time;
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter de barca + línea de pesca + gancho
// ─────────────────────────────────────────────────────────────────────────────
class BoatAndHookPainter extends CustomPainter {
  final double boatX;
  final double boatY;
  final double hookY;   // Y absoluta del gancho
  final double time;
  final bool hasItem;   // ¿gancho lleva algo?

  const BoatAndHookPainter({
    required this.boatX,
    required this.boatY,
    required this.hookY,
    required this.time,
    this.hasItem = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBoat(canvas, Offset(boatX, boatY));
    _drawLine(canvas, Offset(boatX + 18, boatY - 15), Offset(boatX + 18, hookY));
    _drawHook(canvas, Offset(boatX + 18, hookY));
  }

  void _drawBoat(Canvas canvas, Offset pos) {
    // Rock animation
    final rockAngle = sin(time * 1.5) * 0.04;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(rockAngle);

    // Casco
    final hullPaint = Paint()..color = const Color(0xFF8B4513);
    final hullPath = Path()
      ..moveTo(-32, 0)
      ..lineTo(32, 0)
      ..lineTo(26, 12)
      ..lineTo(-26, 12)
      ..close();
    canvas.drawPath(hullPath, hullPaint);

    // Borde casco
    final rimPaint = Paint()..color = const Color(0xFF5C2E00)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawPath(hullPath, rimPaint);

    // Cubierta
    final deckPaint = Paint()..color = const Color(0xFFA0522D);
    canvas.drawRect(const Rect.fromLTWH(-28, -4, 56, 4), deckPaint);

    // Cabina
    final cabinPaint = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawRRect(
      RRect.fromRectAndCorners(const Rect.fromLTWH(-12, -18, 20, 14), topLeft: const Radius.circular(4), topRight: const Radius.circular(4)),
      cabinPaint,
    );
    // Ventana cabina
    canvas.drawRRect(
      RRect.fromRectAndCorners(const Rect.fromLTWH(-7, -15, 8, 7), topLeft: const Radius.circular(2), topRight: const Radius.circular(2)),
      Paint()..color = const Color(0xFF90E0EF),
    );

    // Caña de pescar
    final rodPaint = Paint()..color = const Color(0xFF4E342E)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(10, -3), const Offset(18, -20), rodPaint);

    canvas.restore();
  }

  void _drawLine(Canvas canvas, Offset top, Offset bottom) {
    final linePaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.5;
    canvas.drawLine(top, bottom, linePaint);
  }

  void _drawHook(Canvas canvas, Offset pos) {
    final hookPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hookPath = Path()
      ..moveTo(pos.dx, pos.dy - 6)
      ..lineTo(pos.dx, pos.dy + 4)
      ..arcToPoint(
        Offset(pos.dx + 6, pos.dy + 4),
        radius: const Radius.circular(5),
        clockwise: false,
      )
      ..lineTo(pos.dx + 6, pos.dy + 1);

    canvas.drawPath(hookPath, hookPaint);

    // Destello si lleva presa
    if (hasItem) {
      canvas.drawCircle(pos, 8, Paint()..color = const Color(0x40FFD600));
    }
  }

  @override
  bool shouldRepaint(BoatAndHookPainter old) =>
      old.hookY != hookY || old.time != time || old.hasItem != hasItem;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprite: Pez (azul o dorado)
// ─────────────────────────────────────────────────────────────────────────────
class FishPainter extends CustomPainter {
  final Color bodyColor;
  final Color accentColor;
  final bool facingRight;
  final double scale;

  const FishPainter({
    required this.bodyColor,
    required this.accentColor,
    this.facingRight = true,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale, scale);
    final w = size.width / scale;
    final h = size.height / scale;

    if (!facingRight) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    final bodyPaint = Paint()..color = bodyColor;
    final accentPaint = Paint()..color = accentColor;

    // Cola (triángulo)
    final tailPath = Path()
      ..moveTo(w * 0.15, h * 0.2)
      ..lineTo(0, h * 0.1)
      ..lineTo(0, h * 0.9)
      ..lineTo(w * 0.15, h * 0.8)
      ..close();
    canvas.drawPath(tailPath, accentPaint);

    // Cuerpo (ovalado)
    final bodyRect = Rect.fromLTWH(w * 0.1, h * 0.15, w * 0.75, h * 0.7);
    canvas.drawOval(bodyRect, bodyPaint);

    // Raya lateral
    canvas.drawLine(
      Offset(w * 0.25, h * 0.5),
      Offset(w * 0.75, h * 0.5),
      Paint()..color = accentColor.withAlpha(150)..strokeWidth = 1.5,
    );

    // Aleta dorsal
    final finPath = Path()
      ..moveTo(w * 0.35, h * 0.18)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.65, h * 0.18);
    canvas.drawPath(finPath, Paint()..color = accentColor..strokeWidth = 2..style = PaintingStyle.stroke);

    // Ojo
    canvas.drawCircle(Offset(w * 0.72, h * 0.38), h * 0.12, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.73, h * 0.38), h * 0.07, Paint()..color = Colors.black87);

    // Boca
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.85, h * 0.55), width: h * 0.2, height: h * 0.15),
      0, pi / 2, false,
      Paint()..color = accentColor..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );

    // Brillo dorado extra si pez dorado
    if (accentColor == fishGoldDark) {
      canvas.drawCircle(
        Offset(w * 0.55, h * 0.3),
        h * 0.08,
        Paint()..color = Colors.white.withAlpha(120),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(FishPainter old) => old.facingRight != facingRight || old.scale != scale;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprite: Medusa
// ─────────────────────────────────────────────────────────────────────────────
class JellyfishPainter extends CustomPainter {
  final double time;
  final double pulse; // 0-1

  const JellyfishPainter({required this.time, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pulseScale = 1.0 + pulse * 0.12;

    canvas.save();
    canvas.translate(w / 2, h * 0.35);
    canvas.scale(pulseScale, pulseScale);
    canvas.translate(-w / 2, -h * 0.35);

    // Cúpula
    final domeRect = Rect.fromLTWH(w * 0.1, 0, w * 0.8, h * 0.45);
    final domeGrad = Paint()
      ..shader = RadialGradient(
        colors: [jellyPink.withAlpha(220), jellyPurple.withAlpha(180), jellyPurple.withAlpha(80)],
      ).createShader(domeRect);

    final domePath = Path()
      ..addArc(domeRect, pi, pi);
    domePath.close();
    canvas.drawPath(domePath, domeGrad);

    // Interior translúcido
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.2), width: w * 0.4, height: h * 0.18),
      Paint()..color = Colors.white.withAlpha(40),
    );

    // Tentáculos
    final tentPaint = Paint()
      ..color = jellyPurple.withAlpha(180)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 7; i++) {
      final tx = w * (0.15 + i * 0.12);
      final phase = time * 2 + i * 0.7;
      final tentPath = Path()..moveTo(tx, h * 0.43);
      for (double t = 0; t <= 1; t += 0.1) {
        final ty = h * 0.43 + t * h * 0.55;
        final tx2 = tx + sin(phase + t * 3) * 6;
        tentPath.lineTo(tx2, ty);
      }
      canvas.drawPath(tentPath, tentPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(JellyfishPainter old) => old.time != time || old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprite: Pulpo
// ─────────────────────────────────────────────────────────────────────────────
class OctopusPainter extends CustomPainter {
  final double time;

  const OctopusPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyPaint = Paint()..color = octopusPurple;
    final accentPaint = Paint()..color = const Color(0xFF9C27B0);

    // Tentáculos (8)
    final tentPaint = Paint()
      ..color = octopusPurple
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final baseAngle = (i / 8) * 2 * pi;
      final startX = w * 0.5 + cos(baseAngle) * w * 0.22;
      final startY = h * 0.55 + sin(baseAngle) * h * 0.1;
      final endX = w * 0.5 + cos(baseAngle) * w * 0.48;
      final endY = h * 0.55 + sin(baseAngle + time * 1.5) * h * 0.3;

      final path = Path()..moveTo(startX, startY);
      path.quadraticBezierTo(
        w * 0.5 + cos(baseAngle + 0.3) * w * 0.35,
        h * 0.55 + sin(baseAngle + time + i) * h * 0.25,
        endX, endY,
      );
      canvas.drawPath(path, tentPaint);
    }

    // Cabeza
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: w * 0.55, height: h * 0.5),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.35), width: w * 0.42, height: h * 0.3),
      accentPaint,
    );

    // Ojos
    _drawEye(canvas, Offset(w * 0.37, h * 0.32), w * 0.1);
    _drawEye(canvas, Offset(w * 0.63, h * 0.32), w * 0.1);
  }

  void _drawEye(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center, r, Paint()..color = Colors.white);
    canvas.drawCircle(center, r * 0.55, Paint()..color = Colors.black87);
    canvas.drawCircle(center.translate(r * 0.25, -r * 0.2), r * 0.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(OctopusPainter old) => old.time != time;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprite: Basura (botella, bolsa, lata, zapato)
// ─────────────────────────────────────────────────────────────────────────────
enum TrashType { bottle, bag, can, shoe }

class TrashPainter extends CustomPainter {
  final TrashType type;

  const TrashPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case TrashType.bottle: _drawBottle(canvas, size); break;
      case TrashType.bag:    _drawBag(canvas, size); break;
      case TrashType.can:    _drawCan(canvas, size); break;
      case TrashType.shoe:   _drawShoe(canvas, size); break;
    }
  }

  void _drawBottle(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final paint = Paint()..color = const Color(0xFF80CBC4).withAlpha(200);
    final dark = Paint()..color = const Color(0xFF00897B);

    // Cuerpo
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.25, h*0.3, w*0.5, h*0.6), const Radius.circular(5)), paint);
    // Cuello
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.35, h*0.12, w*0.3, h*0.2), const Radius.circular(3)), paint);
    // Tapa
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.33, h*0.06, w*0.34, h*0.08), const Radius.circular(2)), dark);
    // Brillo
    canvas.drawLine(Offset(w*0.35, h*0.35), Offset(w*0.35, h*0.8), Paint()..color=Colors.white.withAlpha(80)..strokeWidth=2);
    // Etiqueta
    canvas.drawRect(Rect.fromLTWH(w*0.28, h*0.5, w*0.44, h*0.2), Paint()..color=Colors.white.withAlpha(150));
    canvas.drawLine(Offset(w*0.28, h*0.58), Offset(w*0.72, h*0.58), Paint()..color=Colors.red.withAlpha(150)..strokeWidth=2);
  }

  void _drawBag(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final paint = Paint()..color = const Color(0xFFFFFFFF).withAlpha(200);
    final dark = Paint()..color = const Color(0xFFBDBDBD);

    // Bolsa inflada
    final bagPath = Path()
      ..moveTo(w*0.3, h*0.1)
      ..quadraticBezierTo(w*0.1, h*0.3, w*0.05, h*0.6)
      ..quadraticBezierTo(w*0.1, h*0.95, w*0.5, h*0.95)
      ..quadraticBezierTo(w*0.9, h*0.95, w*0.95, h*0.6)
      ..quadraticBezierTo(w*0.9, h*0.3, w*0.7, h*0.1)
      ..close();
    canvas.drawPath(bagPath, paint);
    canvas.drawPath(bagPath, dark..style=PaintingStyle.stroke..strokeWidth=1.5);
    // Nudo
    canvas.drawCircle(Offset(w*0.5, h*0.12), 5, dark..style=PaintingStyle.fill);
    // Asas
    canvas.drawArc(Rect.fromCenter(center: Offset(w*0.38, h*0.08), width:14, height:10), pi, pi, false, dark..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawArc(Rect.fromCenter(center: Offset(w*0.62, h*0.08), width:14, height:10), pi, pi, false, dark);
  }

  void _drawCan(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    // Cuerpo aluminio
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.2, h*0.12, w*0.6, h*0.78), const Radius.circular(6)), Paint()..color=trashGrey);
    // Tapa superior
    canvas.drawOval(Rect.fromLTWH(w*0.2, h*0.08, w*0.6, h*0.1), Paint()..color=const Color(0xFFBDBDBD));
    // Tapa inferior
    canvas.drawOval(Rect.fromLTWH(w*0.2, h*0.80, w*0.6, h*0.1), Paint()..color=const Color(0xFF9E9E9E));
    // Líneas metálicas
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(w*0.2, h*(0.12+i*0.2)), Offset(w*0.8, h*(0.12+i*0.2)), Paint()..color=Colors.white.withAlpha(60)..strokeWidth=1);
    }
    // Etiqueta de color
    canvas.drawRect(Rect.fromLTWH(w*0.22, h*0.25, w*0.56, h*0.4), Paint()..color=coralRed.withAlpha(200));
    // Texto "ECO"
    canvas.drawLine(Offset(w*0.38, h*0.38), Offset(w*0.38, h*0.52), Paint()..color=Colors.white..strokeWidth=2);
  }

  void _drawShoe(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final paint = Paint()..color = trashBrown;
    final solePaint = Paint()..color = const Color(0xFF5D4037);

    // Suela
    final solePath = Path()
      ..moveTo(w*0.05, h*0.7)
      ..quadraticBezierTo(w*0.1, h*0.85, w*0.5, h*0.88)
      ..quadraticBezierTo(w*0.9, h*0.85, w*0.95, h*0.7)
      ..close();
    canvas.drawPath(solePath, solePaint);

    // Zapato
    final shoePath = Path()
      ..moveTo(w*0.05, h*0.7)
      ..quadraticBezierTo(w*0.05, h*0.35, w*0.3, h*0.3)
      ..quadraticBezierTo(w*0.5, h*0.25, w*0.85, h*0.5)
      ..lineTo(w*0.95, h*0.7)
      ..close();
    canvas.drawPath(shoePath, paint);
    // Lengüeta
    canvas.drawRect(Rect.fromLTWH(w*0.3, h*0.3, w*0.2, h*0.25), Paint()..color=trashBrown.withAlpha(200));
    // Cordones
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(w*0.28, h*(0.35+i*0.06)), Offset(w*0.52, h*(0.35+i*0.06)), Paint()..color=Colors.white.withAlpha(180)..strokeWidth=1.5);
    }
  }

  @override
  bool shouldRepaint(TrashPainter old) => old.type != type;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprite: Burbuja simple
// ─────────────────────────────────────────────────────────────────────────────
class BubblePainter extends CustomPainter {
  final double opacity;

  const BubblePainter({this.opacity = 0.6});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    canvas.drawCircle(
      Offset(r, r),
      r,
      Paint()..color = bubbleBlue.withAlpha((opacity * 120).toInt()),
    );
    canvas.drawCircle(
      Offset(r, r),
      r,
      Paint()
        ..color = Colors.white.withAlpha((opacity * 80).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Brillo
    canvas.drawCircle(Offset(r * 0.65, r * 0.55), r * 0.25, Paint()..color = Colors.white.withAlpha((opacity * 100).toInt()));
  }

  @override
  bool shouldRepaint(BubblePainter old) => old.opacity != opacity;
}