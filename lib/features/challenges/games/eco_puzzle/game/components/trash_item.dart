import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../eco_puzzle_game.dart';
import '../models/eco_puzzle_state.dart';
import 'recycle_bin.dart';
import 'bubble_pop_particle.dart';

/// Residuo interactivo dentro de una Burbuja Ecológica Translúcida.
/// Entra cayendo suavemente desde arriba flotando con la brisa del parque,
/// con balanceo orgánico, física gelatinosa al arrastrar y efecto "POP" al acertar.
class TrashItem extends PositionComponent with DragCallbacks, HasGameReference<EcoPuzzleGame> {
  final BinType targetType;
  final String emoji;
  final Vector2 targetPosition;
  final double dropDelay;

  bool isBeingDragged = false;
  bool isDescending = true;
  double _timeAlive = 0.0;
  final double _floatSeed = math.Random().nextDouble() * math.pi * 2;
  final double _swayAmount = 10.0 + math.Random().nextDouble() * 12.0;

  late final TextPainter _textPainter;

  TrashItem({
    required this.targetType,
    required this.emoji,
    required this.targetPosition,
    this.dropDelay = 0.0,
  }) : super(
          position: Vector2(targetPosition.x, -80), // Inicia arriba fuera de pantalla
          size: Vector2.all(68),
          anchor: Anchor.center,
          priority: 25,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(
          fontSize: 34,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Animación de descenso suave con la brisa
    add(
      MoveToEffect(
        targetPosition,
        EffectController(
          duration: 1.4,
          startDelay: dropDelay,
          curve: Curves.easeOutQuad,
        ),
        onComplete: () {
          isDescending = false;
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isBeingDragged) {
      _timeAlive += dt;

      if (isDescending) {
        // Balanceo suave de izquierda a derecha durante la caída
        final swayX = math.sin(_timeAlive * 3.2 + _floatSeed) * _swayAmount * 0.4;
        position.x = targetPosition.x + swayX;
      } else {
        // Flotación en su lugar de reposo
        final floatOffsetY = math.sin(_timeAlive * 2.2 + _floatSeed) * 4.5;
        final floatOffsetX = math.cos(_timeAlive * 1.5 + _floatSeed) * 2.5;
        position.y = targetPosition.y + floatOffsetY;
        position.x = targetPosition.x + floatOffsetX;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.44;

    // Si aún está esperando su turno para caer arriba, no dibujamos sombra fuera
    if (position.y > 0) {
      // ── 1. Sombra Suave Proyectada en el Suelo ──
      final shadowOffsetY = isBeingDragged ? 24.0 : 16.0;
      final shadowScale = isBeingDragged ? 1.3 : (isDescending ? 0.8 : 1.0);
      final shadowAlpha = isBeingDragged ? 0.20 : (isDescending ? 0.15 : 0.30);

      final shadowPaint = Paint()
        ..color = const Color(0xFF1E3A2F).withValues(alpha: shadowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + shadowOffsetY),
          width: (radius * 1.6) * shadowScale,
          height: (radius * 0.55) * shadowScale,
        ),
        shadowPaint,
      );
    }

    // ── 2. Cuerpo de la Burbuja Translúcida ──
    Color tintColor;
    switch (targetType) {
      case BinType.organic:
        tintColor = const Color(0xFF34D399); // Verde menta
        break;
      case BinType.recyclable:
        tintColor = const Color(0xFFFBBF24); // Amarillo sol
        break;
      case BinType.inorganic:
        tintColor = const Color(0xFF60A5FA); // Azul cielo
        break;
    }

    final bubbleRect = Rect.fromCircle(center: center, radius: radius);

    final bubblePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.95,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          tintColor.withValues(alpha: 0.25),
          tintColor.withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0.50),
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
      ).createShader(bubbleRect);

    canvas.drawCircle(center, radius, bubblePaint);

    // ── 3. Borde Fino Iridiscente de Burbuja ──
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: isBeingDragged ? 0.95 : 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBeingDragged ? 2.5 : 1.8;

    canvas.drawCircle(center, radius, rimPaint);

    // ── 4. Reflejos de Cristal (Highlights de Brillo) ──
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.82),
      -2.4,
      1.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Pequeño punto brillante secundario
    canvas.drawCircle(
      Offset(center.dx - radius * 0.45, center.dy - radius * 0.45),
      2.8,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // Reflejo suave inferior
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.84),
      0.7,
      1.1,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // ── 5. Residuo Limpio en el Centro de la Burbuja ──
    _textPainter.paint(
      canvas,
      Offset(center.dx - _textPainter.width / 2, center.dy - _textPainter.height / 2),
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (game.gameState != EcoPuzzleState.playing) return;

    super.onDragStart(event);
    isBeingDragged = true;
    isDescending = false; // Cancela la caída si el usuario la atrapa en el aire
    priority = 100;

    add(ScaleEffect.to(Vector2.all(1.24), EffectController(duration: 0.12, curve: Curves.easeOutBack)));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isBeingDragged) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isBeingDragged) return;
    isBeingDragged = false;
    priority = 25;

    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.12)));

    final bins = game.children.whereType<RecycleBin>();
    RecycleBin? overlappingBin;

    for (final bin in bins) {
      if (bin.toRect().overlaps(toRect())) {
        overlappingBin = bin;
        break;
      }
    }

    game.onTrashDropped(this, overlappingBin);
  }

  void returnToStart() {
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2(1.2, 0.85), EffectController(duration: 0.08, curve: Curves.easeOut)),
        ScaleEffect.to(Vector2(0.9, 1.15), EffectController(duration: 0.08, curve: Curves.easeIn)),
        ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.15, curve: Curves.elasticOut)),
      ]),
    );
    add(MoveToEffect(targetPosition, EffectController(duration: 0.38, curve: Curves.easeOutBack)));
  }

  void poofAndRemove([Vector2? targetMouthPos]) {
    // Estallido POP con gotitas
    game.add(
      BubblePopParticleComponent(
        position: position.clone(),
        tintColor: targetType == BinType.organic
            ? const Color(0xFF34D399)
            : targetType == BinType.recyclable
                ? const Color(0xFFFBBF24)
                : const Color(0xFF60A5FA),
      ),
    );

    if (targetMouthPos != null) {
      add(MoveToEffect(targetMouthPos, EffectController(duration: 0.22, curve: Curves.easeIn)));
    }
    add(RotateEffect.by(math.pi * 1.5, EffectController(duration: 0.22, curve: Curves.easeIn)));
    add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.22, curve: Curves.easeInBack)));
    add(RemoveEffect(delay: 0.22));
  }
}
