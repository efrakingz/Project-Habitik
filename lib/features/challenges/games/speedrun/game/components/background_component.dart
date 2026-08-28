import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../speedrun_game.dart';

class BackgroundComponent extends PositionComponent with HasGameReference<SpeedrunGame> {
  final List<_WaterBubble> _bubbles = [];
  final math.Random _random = math.Random();
  
  late final Paint _bgPaint;
  
  BackgroundComponent() : super(priority: -10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
    
    _bgPaint = Paint();
    
    // Generar burbujas iniciales distribuidas por toda la pantalla
    for (int i = 0; i < 30; i++) {
      _bubbles.add(
        _WaterBubble(
          x: _random.nextDouble() * size.x,
          y: _random.nextDouble() * size.y,
          radius: 3.0 + _random.nextDouble() * 5.0,
          speed: 15.0 + _random.nextDouble() * 25.0,
          swaySpeed: 1.0 + _random.nextDouble() * 2.0,
          swayWidth: 2.0 + _random.nextDouble() * 4.0,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    for (final bubble in _bubbles) {
      bubble.update(dt);
      
      // Si la burbuja se sale por arriba, reaparece abajo
      if (bubble.y < -20) {
        bubble.y = size.y + 20;
        bubble.x = _random.nextDouble() * size.x;
        bubble.speed = 15.0 + _random.nextDouble() * 25.0;
        bubble.radius = 3.0 + _random.nextDouble() * 5.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final showerTime = game.elapsedShowerSeconds;
    // Factor de calidez 0.0 (inicio) a 1.0 (4+ mins / 240s)
    final heatFactor = (showerTime / 240.0).clamp(0.0, 1.0);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Interpolación de colores del gradiente térmico reactivo al tiempo de ducha
    final topColor = Color.lerp(const Color(0xFFE0F7FA), const Color(0xFFFFF3E0), heatFactor)!;
    final midColor1 = Color.lerp(const Color(0xFF80DEEA), const Color(0xFFFFCC80), heatFactor)!;
    final midColor2 = Color.lerp(const Color(0xFF26C6DA), const Color(0xFFFFA726), heatFactor)!;
    final botColor = Color.lerp(const Color(0xFF00ACC1), const Color(0xFFE65100), heatFactor)!;

    _bgPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, midColor1, midColor2, botColor],
      stops: const [0.0, 0.4, 0.75, 1.0],
    ).createShader(rect);
    
    canvas.drawRect(rect, _bgPaint);

    // Dibujar burbujas flotantes
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final bubble in _bubbles) {
      final offsetX = bubble.x + math.sin(bubble.time * bubble.swaySpeed) * bubble.swayWidth;
      final center = Offset(offsetX.clamp(0.0, size.x), bubble.y);
      
      // Dibujar cuerpo de la burbuja
      canvas.drawCircle(center, bubble.radius, bubblePaint);
      
      // Dibujar borde brillante
      canvas.drawCircle(center, bubble.radius, borderPaint);

      // Pequeño reflejo brillante en la burbuja para realismo
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(center.dx - bubble.radius * 0.3, center.dy - bubble.radius * 0.3),
        bubble.radius * 0.2,
        highlightPaint,
      );
    }

    // Dibujar viñeta de condensación y vapor transparente en bordes a partir de 45 segundos
    if (showerTime > 45.0) {
      final steamAlpha = ((showerTime - 45.0) / 195.0).clamp(0.0, 0.45);
      final radius = math.min(size.x, size.y) * 0.65;
      final steamPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.x / 2, size.y / 2),
          radius,
          [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: steamAlpha),
          ],
          [0.45, 1.0],
        );
      canvas.drawRect(rect, steamPaint);
    }
  }
}

class _WaterBubble {
  double x;
  double y;
  double radius;
  double speed;
  double time;
  double swaySpeed;
  double swayWidth;

  _WaterBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.swaySpeed,
    required this.swayWidth,
  }) : time = math.Random().nextDouble() * 100;

  void update(double dt) {
    time += dt;
    y -= speed * dt;
  }
}
