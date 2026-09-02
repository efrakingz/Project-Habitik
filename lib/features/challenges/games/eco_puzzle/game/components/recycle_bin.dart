import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'success_sparkle_component.dart';
import 'error_feedback_component.dart';

enum BinType { organic, recyclable, inorganic }

/// Contenedor de reciclaje con estética Cartoon 3D amigable, cálida y limpia (estilo Habitik).
/// Cuerpo redondeado vibrante, capucha amigable, insignia blanca nítida y físicas elásticas.
class RecycleBin extends PositionComponent with HasGameReference {
  final BinType type;

  late final Color _mainColor;
  late final Color _lightColor;
  late final Color _darkColor;
  late final Color _accentColor;
  late final String _labelStr;

  double _flashTimer = 0.0;
  Color? _flashColor;
  bool isHovered = false;

  RecycleBin({
    required this.type,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    switch (type) {
      case BinType.organic:
        _mainColor = const Color(0xFF10B981); // Verde esmeralda alegre
        _lightColor = const Color(0xFF34D399); // Verde menta brillante
        _darkColor = const Color(0xFF047857); // Sombra verde
        _accentColor = const Color(0xFF059669);
        _labelStr = 'Orgánico';
        break;
      case BinType.recyclable:
        _mainColor = const Color(0xFFF59E0B); // Amarillo sol vibrante
        _lightColor = const Color(0xFFFBBF24); // Dorado brillante
        _darkColor = const Color(0xFFB45309); // Sombra ámbar
        _accentColor = const Color(0xFFD97706);
        _labelStr = 'Reciclable';
        break;
      case BinType.inorganic:
        _mainColor = const Color(0xFF3B82F6); // Azul cielo amigable
        _lightColor = const Color(0xFF60A5FA); // Azul claro
        _darkColor = const Color(0xFF1D4ED8); // Sombra azul
        _accentColor = const Color(0xFF2563EB);
        _labelStr = 'Inorgánico';
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _flashColor = null;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // ── 1. Sombra Suave y Esponjosa en el Césped ──
    final shadowPaint = Paint()
      ..color = const Color(0xFF2E5A44).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h - 2), width: w * 0.95, height: 16),
      shadowPaint,
    );

    // ── 2. Cuerpo Redondeado Tipo Cartoon con Curvatura Suave ──
    final bodyRect = Rect.fromLTWH(4, 20, w - 8, h - 26);
    final bodyRRect = RRect.fromRectAndCorners(
      bodyRect,
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: const Radius.circular(24),
      bottomRight: const Radius.circular(24),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lightColor,
          _mainColor,
          _darkColor,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(bodyRect);

    canvas.drawRRect(bodyRRect, bodyPaint);

    // Borde blanco suave de ilustración
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: isHovered ? 0.9 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 3.5 : 2.5;
    canvas.drawRRect(bodyRRect, strokePaint);

    // ── 3. Tapa / Capucha Arqueada 3D Superior ──
    final lidRect = Rect.fromLTWH(0, 4, w, 26);
    final lidRRect = RRect.fromRectAndRadius(lidRect, const Radius.circular(13));

    final lidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _lightColor,
          _mainColor,
        ],
      ).createShader(lidRect);

    canvas.drawRRect(lidRRect, lidPaint);

    // Borde de la tapa
    canvas.drawRRect(
      lidRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Reflejo de brillo curvado en la tapa
    canvas.drawLine(
      Offset(w * 0.15, 8),
      Offset(w * 0.85, 8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2,
    );

    // ── 4. Boca / Tolva de Entrada de Basura (Deep Arched Slot) ──
    final mouthRect = Rect.fromLTWH(w * 0.14, 11, w * 0.72, 12);
    final mouthRRect = RRect.fromRectAndRadius(mouthRect, const Radius.circular(6));

    final mouthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _darkColor,
          const Color(0xFF03140C),
        ],
      ).createShader(mouthRect);

    canvas.drawRRect(mouthRRect, mouthPaint);

    // ── 5. Insignia Frontal Circular Blanca (Clean Badge con Relieve) ──
    final badgeCenter = Offset(w / 2, h * 0.51);
    final badgeRadius = math.min(w, h) * 0.22;

    // Sombra suave del escudo
    final badgeShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(badgeCenter + const Offset(0, 2.5), badgeRadius, badgeShadow);

    // Fondo blanco perla del escudo
    final badgeBg = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.2, -0.3),
        colors: [
          Colors.white,
          Color(0xFFF8FAFC),
        ],
      ).createShader(Rect.fromCircle(center: badgeCenter, radius: badgeRadius));
    canvas.drawCircle(badgeCenter, badgeRadius, badgeBg);

    // Borde con color de acento
    final badgeBorder = Paint()
      ..color = _lightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;
    canvas.drawCircle(badgeCenter, badgeRadius, badgeBorder);

    // Dibujo del Icono Simpático en la insignia
    _drawCuteIcon(canvas, badgeCenter, badgeRadius * 0.65);

    // ── 6. Píldora de Texto Inferior (Clean Pill Label) ──
    final pillRect = Rect.fromLTWH(w * 0.08, h - 28, w * 0.84, 20);
    final pillRRect = RRect.fromRectAndRadius(pillRect, const Radius.circular(10));

    // Sombra de la píldora
    final pillShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(pillRRect.shift(const Offset(0, 1.5)), pillShadow);

    // Fondo blanco de la píldora
    final pillPaint = Paint()..color = Colors.white;
    canvas.drawRRect(pillRRect, pillPaint);

    final pillBorder = Paint()
      ..color = _mainColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(pillRRect, pillBorder);

    final labelPainter = TextPainter(
      text: TextSpan(
        text: _labelStr,
        style: TextStyle(
          color: _darkColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(
      canvas,
      Offset(w / 2 - labelPainter.width / 2, pillRect.top + (pillRect.height - labelPainter.height) / 2),
    );

    // ── 7. Destello Suave de Acierto / Error ──
    if (_flashColor != null) {
      final flashPaint = Paint()
        ..color = _flashColor!.withValues(alpha: (_flashTimer / 0.35).clamp(0.0, 0.65))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(bodyRRect, flashPaint);
    }
  }

  /// Dibuja iconos limpios, tiernos y reconocibles para cada categoría
  void _drawCuteIcon(Canvas canvas, Offset center, double size) {
    final iconPaint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case BinType.organic:
        // Brote verde tierno (dos hojitas)
        final leaf1 = Path()
          ..moveTo(center.dx, center.dy + size * 0.6)
          ..quadraticBezierTo(center.dx - size * 0.8, center.dy - size * 0.1, center.dx - size * 0.1, center.dy - size * 0.7)
          ..quadraticBezierTo(center.dx + size * 0.2, center.dy - size * 0.1, center.dx, center.dy + size * 0.6)
          ..close();
        canvas.drawPath(leaf1, iconPaint);

        final leaf2 = Path()
          ..moveTo(center.dx, center.dy + size * 0.4)
          ..quadraticBezierTo(center.dx + size * 0.8, center.dy, center.dx + size * 0.7, center.dy - size * 0.5)
          ..quadraticBezierTo(center.dx + size * 0.1, center.dy - size * 0.2, center.dx, center.dy + size * 0.4)
          ..close();
        canvas.drawPath(leaf2, Paint()..color = _lightColor);
        break;

      case BinType.recyclable:
        // Símbolo de reciclaje 3 flechas clásico
        final double r = size * 0.72;
        for (int i = 0; i < 3; i++) {
          final double angle = (i * 2 * math.pi / 3) - (math.pi / 2);
          final double nextAngle = ((i + 1) * 2 * math.pi / 3) - (math.pi / 2);

          final p1 = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
          final p2 = Offset(center.dx + r * math.cos(nextAngle - 0.35), center.dy + r * math.sin(nextAngle - 0.35));

          final arrowPath = Path()
            ..moveTo(p1.dx, p1.dy)
            ..quadraticBezierTo(center.dx, center.dy, p2.dx, p2.dy);
          canvas.drawPath(arrowPath, strokePaint);

          // Punta de flecha
          final tip = p2;
          final tipPath = Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo(tip.dx + 4.5 * math.cos(nextAngle + 1.2), tip.dy + 4.5 * math.sin(nextAngle + 1.2))
            ..lineTo(tip.dx + 4.5 * math.cos(nextAngle - 1.2), tip.dy + 4.5 * math.sin(nextAngle - 1.2))
            ..close();
          canvas.drawPath(tipPath, iconPaint);
        }
        break;

      case BinType.inorganic:
        // Icono tierno de contenedor de basura
        final binBody = Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.15), width: size * 1.0, height: size * 1.1);
        final binRRect = RRect.fromRectAndRadius(binBody, const Radius.circular(4));
        canvas.drawRRect(binRRect, iconPaint);

        // Tapa del tachito
        final binLid = Rect.fromCenter(center: Offset(center.dx, center.dy - size * 0.45), width: size * 1.2, height: size * 0.3);
        canvas.drawRRect(RRect.fromRectAndRadius(binLid, const Radius.circular(3)), iconPaint);

        // Rayitas verticales del tachito
        final linePaint = Paint()..color = Colors.white..strokeWidth = 1.8..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(center.dx - size * 0.25, center.dy - size * 0.2), Offset(center.dx - size * 0.25, center.dy + size * 0.5), linePaint);
        canvas.drawLine(Offset(center.dx + size * 0.25, center.dy - size * 0.2), Offset(center.dx + size * 0.25, center.dy + size * 0.5), linePaint);
        break;
    }
  }

  /// Acción ejecutada cuando un residuo cae correctamente en este tacho
  void flashGreen() {
    _flashColor = const Color(0xFF34D399);
    _flashTimer = 0.35;

    // 1. Animación Bouncy Squash & Stretch (Rebote de alegría)
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2(1.18, 0.86),
          EffectController(duration: 0.10, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2(0.92, 1.14),
          EffectController(duration: 0.12, curve: Curves.easeInOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.18, curve: Curves.elasticOut),
        ),
      ]),
    );

    // 2. Disparar partículas de chispas y estrellas festivas
    final praises = ["¡Genial! ✨", "+1 ¡Bien! 🌿", "¡Excelente! 🎯", "¡Perfecto! ♻️"];
    final randomPraise = praises[math.Random().nextInt(praises.length)];

    game.add(
      SuccessSparkleComponent(
        position: Vector2(position.x, position.y - size.y * 0.45),
        text: randomPraise,
        themeColor: _lightColor,
      ),
    );
  }

  /// Acción ejecutada cuando se equivoca de tacho
  void flashRed() {
    _flashColor = const Color(0xFFEF4444);
    _flashTimer = 0.35;

    // 1. Sacudida enérgica de negación
    add(
      MoveEffect.by(
        Vector2(8, 0),
        EffectController(duration: 0.045, alternate: true, repeatCount: 4),
      ),
    );

    // 2. Disparar aviso visual flotante de error
    final warnings = ["¡Aquí no! ❌", "¡Incorrecto! 🚫", "¡Ups! 💔"];
    final randomWarning = warnings[math.Random().nextInt(warnings.length)];

    game.add(
      ErrorFeedbackComponent(
        position: Vector2(position.x, position.y - size.y * 0.45),
        text: randomWarning,
      ),
    );
  }
}
