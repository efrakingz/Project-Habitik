import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../models/geometry_3d.dart';
import '../mixins/visibility_aware_update.dart';
import 'package:habitik/core/theme/theme.dart';

class DetailedBushComponent extends PositionComponent with VisibilityAwareUpdate {
  double _swayTime = 0.0;
  late double _swaySpeed;
  late double _swayOffset;

  late final TreeType _bushType;
  late final double _pitch;
  late final double _yaw;
  late final double _bushRadius;

  // Optimized pre-rotated vertices list and unique GeodesicSphere instance (Option B)
  late final GeodesicSphere _sphereInstance;
  late final List<Vertex3D> _rotatedVertices;

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;

  // Pre-allocated paints to avoid allocations in render loop
  final Paint _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.12);

  DetailedBushComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(30, 24),
        anchor: Anchor.bottomCenter,
        priority: 10 + position.y.toInt(),
      ) {
    final seed = position.x.toInt() ^ position.y.toInt();
    final random = math.Random(seed);
    _swaySpeed = 1.0 + random.nextDouble() * 0.8;
    _swayOffset = random.nextDouble() * math.pi;

    final randPalette = random.nextDouble();
    if (randPalette < 0.45) {
      _bushType = TreeType.lime;
    } else if (randPalette < 0.8) {
      _bushType = TreeType.grass;
    } else {
      _bushType = TreeType.forest;
    }

    _pitch = random.nextDouble() * math.pi * 2;
    _yaw = random.nextDouble() * math.pi * 2;
    _bushRadius = 11.0 + random.nextDouble() * 4.0;

    // Create unique instance of basic geodesic sphere for each bush (thread safety)
    _sphereInstance = GeodesicSphere.createIcosahedron();
    // Precalculate rotated vertices (optimize CPU performance)
    _rotatedVertices = _sphereInstance.getRotatedVertices(_pitch, _yaw);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _swayTime += dt;
  }

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final center = size / 2;
    final darkBorder = Paint()
      ..color = isDark ? const Color(0x0D06100B) : const Color(0x0D0D2B1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final TreePalette palette;
    switch (_bushType) {
      case TreeType.lime:
        palette = isDark ? TreePalette.limeNight : TreePalette.lime;
        break;
      case TreeType.grass:
        palette = isDark ? TreePalette.grassNight : TreePalette.grass;
        break;
      case TreeType.forest:
        palette = isDark ? TreePalette.forestNight : TreePalette.forest;
        break;
    }

    // Dibuja arbusto como una esfera geodésica low-poly pequeña (unsubdivided icosahedron)
    final sphereCenter = Offset(center.x, size.y - _bushRadius * 0.7);
    _sphereInstance.renderGeodesicSphere(
      canvas,
      sphereCenter,
      _bushRadius,
      _rotatedVertices,
      palette,
      darkBorder,
    );

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
  }

  @override
  void render(ui.Canvas canvas) {
    final center = size / 2;
    canvas.save();

    // Sombra del arbusto
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.x + 1, size.y - 1),
        width: _bushRadius * 1.7,
        height: _bushRadius * 0.45,
      ),
      _shadowPaint,
    );

    // Balanceo y rebote físico
    canvas.translate(center.x, size.y - 2);
    double rotAngle = math.sin(_swayTime * _swaySpeed + _swayOffset) * 0.025;
    canvas.rotate(rotAngle);
    canvas.translate(-center.x, -(size.y - 2));

    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null || _cachedForDark != isDark) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);

    canvas.restore();
  }
}
