import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:habitik/core/theme/theme.dart';

class OrganicTerrainComponent extends PositionComponent with HasGameReference {
  final double mapHeight;
  OrganicTerrainComponent({required this.mapHeight}) : super(priority: 0);

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;
  Vector2? _cachedSize;

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final rect = ui.Rect.fromLTWH(0, 0, game.size.x, mapHeight);

    // Fondo verde limón/pasto cálido base de Muro Familiar
    canvas.drawRect(
      rect,
      ui.Paint()
        ..color = isDark ? const Color(0xFF09140F) : const Color(0xFF8CD456),
    );

    final hillPaint = ui.Paint()..style = ui.PaintingStyle.fill;

    // Tres colinas superpuestas con curvas fluidas
    final hillPaths = [
      _createHillPath(0.08, 0.32, 0.18),
      _createHillPath(0.38, 0.62, 0.48),
      _createHillPath(0.68, 0.92, 0.78),
    ];

    final gradients = isDark
        ? [
            const LinearGradient(
              colors: [Color(0xFF11261B), Color(0xFF0C1B13)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            const LinearGradient(
              colors: [Color(0xFF0C1B13), Color(0xFF08130E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            const LinearGradient(
              colors: [Color(0xFF08130E), Color(0xFF050B08)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ]
        : [
            const LinearGradient(
              colors: [Color(0xFF8CD456), Color(0xFF9CE569)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            const LinearGradient(
              colors: [Color(0xFF9CE569), Color(0xFF7DCC46)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            const LinearGradient(
              colors: [Color(0xFF7DCC46), Color(0xFF5BA626)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ];

    for (int i = 0; i < hillPaths.length; i++) {
      hillPaint.shader = gradients[i].createShader(rect);
      canvas.drawPath(hillPaths[i], hillPaint);
    }

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
    _cachedSize = game.size.clone();
  }

  @override
  void render(ui.Canvas canvas) {
    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null ||
        _cachedForDark != isDark ||
        _cachedSize == null ||
        _cachedSize!.x != game.size.x ||
        _cachedSize!.y != game.size.y) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);
  }

  ui.Path _createHillPath(
    double startYRatio,
    double endYRatio,
    double controlYRatio,
  ) {
    final path = ui.Path();
    final startY = startYRatio * mapHeight;
    final endY = endYRatio * mapHeight;
    final controlY = controlYRatio * mapHeight;

    path.moveTo(-50, startY);
    path.quadraticBezierTo(game.size.x * 0.5, controlY, game.size.x + 50, endY);
    path.lineTo(game.size.x + 50, mapHeight + 50);
    path.lineTo(-50, mapHeight + 50);
    path.close();
    return path;
  }
}
