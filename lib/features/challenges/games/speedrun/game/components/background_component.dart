import 'dart:math' as math;
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
    for (int i = 0; i < 25; i++) {
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
    // Dibujar degradado líquido premium de fondo
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    _bgPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFE0F7FA), // Cyan muy claro (agua arriba)
        Color(0xFF80DEEA), // Cyan claro
        Color(0xFF26C6DA), // Cyan medio
        Color(0xFF00ACC1), // Cyan oscuro (profundo abajo)
      ],
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
  }) : time = 0.0;

  void update(double dt) {
    y -= speed * dt;
    time += dt;
  }
}
