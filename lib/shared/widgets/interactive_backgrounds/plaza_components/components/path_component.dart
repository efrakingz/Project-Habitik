import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:habitik/core/theme/theme.dart';

class _StoneInfo {
  final double x, y, rx, ry, angle;
  final int colorIndex;
  _StoneInfo(this.x, this.y, this.rx, this.ry, this.angle, this.colorIndex);
}

class DetailedPathPainter extends PositionComponent with HasGameReference {
  final Map<String, Vector2> Function() getNodes;
  final List<String> orderedChallengeIds;
  final double mapHeight;

  final Paint _stonePaint = Paint()..style = PaintingStyle.fill;
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.12);
  final Paint _highlightPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _sandPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final Paint _sandBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final ui.Path _sandPathCache = ui.Path();
  final List<_StoneInfo> _stonesCache = [];

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;
  Vector2? _cachedSize;

  DetailedPathPainter({
    required this.getNodes,
    required this.orderedChallengeIds,
    required this.mapHeight,
  }) : super(priority: 1);

  void _buildCache(Map<String, Vector2> nodes) {
    _sandPathCache.reset();
    _stonesCache.clear();

    if (nodes.isEmpty) return;

    double minY = mapHeight;
    double maxY = 0;
    for (final node in nodes.values) {
      if (node.y < minY) minY = node.y;
      if (node.y > maxY) maxY = node.y;
    }

    final centerX = game.size.x * 0.5;

    // Camino principal vertical y ondulado en el centro del parque
    _sandPathCache.moveTo(centerX, mapHeight + 50);
    _sandPathCache.lineTo(centerX, maxY);
    _sandPathCache.quadraticBezierTo(
      centerX - 20,
      (maxY + minY) / 2,
      centerX,
      minY - 100,
    );

    // Conectar cada nodo hacia el camino principal central
    for (final id in nodes.keys) {
      final node = nodes[id]!;
      _sandPathCache.moveTo(node.x, node.y);
      _sandPathCache.quadraticBezierTo(
        (node.x + centerX) / 2,
        node.y + 30,
        centerX,
        node.y + 10,
      );
    }

    // Calcular la posición de algunas piedras dispersas a lo largo de los senderos
    final math.Random random = math.Random(888);
    final pathMetrics = _sandPathCache.computeMetrics();

    for (final metric in pathMetrics) {
      final length = metric.length;
      final numStones = (length / 50).toInt(); // Piedras esparcidas, una cada ~50px

      for (int i = 0; i < numStones; i++) {
        final dist = (i + random.nextDouble()) * (length / numStones);
        final tangent = metric.getTangentForOffset(dist);
        if (tangent == null) continue;

        final pt = tangent.position;

        // Aleatorizar la posición lateral de la piedra respecto al centro del camino
        final offsetDist = (random.nextDouble() - 0.5) * 24.0;
        final offsetX = tangent.vector.dy * offsetDist;
        final offsetY = -tangent.vector.dx * offsetDist;

        final stoneX = pt.dx + offsetX;
        final stoneY = pt.dy + offsetY;

        final colorIndex = random.nextInt(5);
        final rx = 4.0 + random.nextDouble() * 5.0;
        final ry = 3.0 + random.nextDouble() * 3.5;
        final angle = random.nextDouble() * math.pi;

        _stonesCache.add(_StoneInfo(stoneX, stoneY, rx, ry, angle, colorIndex));
      }
    }
  }

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    _borderPaint.color = isDark
        ? const Color(0x251C1E20)
        : const Color(0x253E2723);
    _sandPaint.color = isDark
        ? const Color(0xFF4E342E)
        : const Color(0xFFE6D6C3);
    _sandBorderPaint.color = isDark
        ? const Color(0x401C1E20)
        : const Color(0x30A1887F);

    _sandPaint.strokeWidth = 30.0;
    _sandBorderPaint.strokeWidth = 36.0;

    canvas.drawPath(_sandPathCache, _sandBorderPaint);
    canvas.drawPath(_sandPathCache, _sandPaint);

    final stoneColors = isDark
        ? [
            const Color(0xFF2E3436),
            const Color(0xFF242729),
            const Color(0xFF1C1E20),
            const Color(0xFF34383C),
            const Color(0xFF1F2224),
          ]
        : [
            const Color(0xFFE5DDD3),
            const Color(0xFFDCD3C9),
            const Color(0xFFCFD6D8),
            const Color(0xFFC4B6AB),
            const Color(0xFFB9C5C7),
          ];

    // Dibujar las piedras decorativas encima de la arena
    for (final stone in _stonesCache) {
      _stonePaint.color = stoneColors[stone.colorIndex];

      canvas.save();
      canvas.translate(stone.x, stone.y);
      canvas.rotate(stone.angle);

      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(1, 1.5),
          width: stone.rx * 2,
          height: stone.ry * 2,
        ),
        _shadowPaint,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: stone.rx * 2,
          height: stone.ry * 2,
        ),
        _stonePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: stone.rx * 2,
          height: stone.ry * 2,
        ),
        _borderPaint,
      );

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset.zero,
          width: stone.rx * 1.5,
          height: stone.ry * 1.5,
        ),
        math.pi,
        math.pi * 0.5,
        false,
        _highlightPaint,
      );

      canvas.restore();
    }

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
    _cachedSize = game.size.clone();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _buildCache(getNodes());
    _cachedPicture = null;
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
}
