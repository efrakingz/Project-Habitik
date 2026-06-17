import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:habitik/core/theme/theme.dart';
import '../models/geometry_3d.dart';

class InteractiveLeafComponent extends PositionComponent {
  final math.Random _random = math.Random();

  double _swayTime = 0.0;
  late double _swaySpeed;
  late double _swayAmplitude;

  final Vector2 _velocity = Vector2.zero();
  bool _isFloatingAway = false;
  double _fadeOpacity = 1.0;
  late Vector2 _initialPosition;

  late Color _leafColor;
  late ui.Path _leafPath;

  // Pre-allocated paint objects to avoid allocations in render loop
  late final Paint _paint = Paint()..style = PaintingStyle.fill;
  late final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  InteractiveLeafComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(14, 14),
        anchor: Anchor.center,
        priority: 3,
      ) {
    _initialPosition = position.clone();
    _swaySpeed = 1.0 + _random.nextDouble() * 2.0;
    _swayAmplitude = 0.06 + _random.nextDouble() * 0.08;

    final leafColors = [
      HabitikColors.green300,
      HabitikColors.green400,
      const Color(0xFF81C784),
      const Color(0xCC66BB6A),
    ];
    _leafColor = leafColors[_random.nextInt(leafColors.length)];

    _leafPath = ui.Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(5, -5, 10, 0)
      ..quadraticBezierTo(5, 5, 0, 0)
      ..close();
  }

  void triggerFlyaway() {
    _isFloatingAway = true;
    _fadeOpacity = 1.0;
    final speedY = 40.0 + _random.nextDouble() * 50.0;
    final speedX = (_random.nextDouble() - 0.5) * 60.0;
    _velocity.setValues(speedX, speedY);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isFloatingAway) {
      angle += 9.0 * dt;
      position += _velocity * dt;
      _fadeOpacity -= 1.4 * dt;

      if (_fadeOpacity <= 0.0) {
        if (_velocity.y > 0) {
          removeFromParent();
        } else {
          position.setFrom(_initialPosition);
          angle = 0.0;
          _fadeOpacity = 1.0;
          _isFloatingAway = false;
          _velocity.setZero();
        }
      }
    } else {
      _swayTime += dt;
      angle = math.sin(_swayTime * _swaySpeed) * _swayAmplitude;

      position.x -= 3.0 * dt;
      position.y += 1.5 * dt;

      final distToOrigin = position.distanceTo(_initialPosition);
      if (distToOrigin > 45) {
        final direction = (_initialPosition - position).normalized();
        position += direction * (4.0 * dt);
      }
    }
  }

  @override
  void render(ui.Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    _paint.color = _leafColor.withValues(alpha: _fadeOpacity * _leafColor.a);
    _linePaint.color = Colors.white.withValues(alpha: _fadeOpacity * 0.4);

    canvas.drawPath(_leafPath, _paint);
    canvas.drawLine(const Offset(0, 0), const Offset(10, 0), _linePaint);

    canvas.restore();
  }
}

class InteractiveTreeComponent extends PositionComponent with TapCallbacks {
  double _shakeTime = 0.0;
  bool _isShaking = false;
  double _swayTime = 0.0;
  late double _swaySpeed;
  late double _swayOffset;

  late final TreeType _treeType;
  late final double _pitch;
  late final double _yaw;
  late final double _crownRadius;

  // Optimized rotated vertices list and tree instance GeodesicSphere (Option B)
  late final GeodesicSphere _sphereInstance;
  late final List<Vertex3D> _rotatedVertices;

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;

  // Pre-allocated paints to avoid allocations in render loop
  final Paint _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.12);

  InteractiveTreeComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(52, 74),
        anchor: Anchor.bottomCenter,
        priority: 10 + position.y.toInt(),
      ) {
    final seed = position.x.toInt() ^ position.y.toInt();
    final random = math.Random(seed);
    _swaySpeed = 0.6 + random.nextDouble() * 0.8;
    _swayOffset = random.nextDouble() * math.pi;

    final randPalette = random.nextDouble();
    if (randPalette < 0.35) {
      _treeType = TreeType.lime;
    } else if (randPalette < 0.7) {
      _treeType = TreeType.grass;
    } else {
      _treeType = TreeType.forest;
    }

    _pitch = random.nextDouble() * math.pi * 2;
    _yaw = random.nextDouble() * math.pi * 2;
    _crownRadius = 19.0 + random.nextDouble() * 5.5;

    // Create unique instance of subdivided geodesic sphere for each tree (thread safety)
    _sphereInstance = GeodesicSphere.createIcosahedron().subdivide();
    // Precalculate rotated vertices (optimize CPU performance)
    _rotatedVertices = _sphereInstance.getRotatedVertices(_pitch, _yaw);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _swayTime += dt;

    if (_isShaking) {
      _shakeTime += dt;
      if (_shakeTime > 1.2) {
        _isShaking = false;
        _shakeTime = 0.0;
      }
    }
  }

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final center = size / 2;

    // Tronco de madera en 3D Facetado (Cilindro cónico con 3 caras planas)
    final trunkWidthTop = 4.5;
    final trunkWidthBottom = 7.5;
    final trunkHeight = 21.0 + (_crownRadius - 19.0) * 0.5;
    final tx = center.x;
    final ty = size.y - 4;

    final pathLeft = ui.Path()
      ..moveTo(tx - trunkWidthTop / 2, ty - trunkHeight)
      ..lineTo(tx - trunkWidthTop / 6, ty - trunkHeight)
      ..lineTo(tx - trunkWidthBottom / 6, ty)
      ..lineTo(tx - trunkWidthBottom / 2, ty)
      ..close();

    final pathCenter = ui.Path()
      ..moveTo(tx - trunkWidthTop / 6, ty - trunkHeight)
      ..lineTo(tx + trunkWidthTop / 6, ty - trunkHeight)
      ..lineTo(tx + trunkWidthBottom / 6, ty)
      ..lineTo(tx - trunkWidthBottom / 6, ty)
      ..close();

    final pathRight = ui.Path()
      ..moveTo(tx + trunkWidthTop / 6, ty - trunkHeight)
      ..lineTo(tx + trunkWidthTop / 2, ty - trunkHeight)
      ..lineTo(tx + trunkWidthBottom / 2, ty)
      ..lineTo(tx + trunkWidthBottom / 6, ty)
      ..close();

    final trunkLight = Paint()
      ..color = isDark ? const Color(0xFF3E2723) : const Color(0xFF8D6E63);
    final trunkMid = Paint()
      ..color = isDark ? const Color(0xFF2E1C16) : const Color(0xFF735240);
    final trunkDark = Paint()
      ..color = isDark ? const Color(0xFF1F110E) : const Color(0xFF5D4037);

    canvas.drawPath(pathLeft, trunkLight);
    canvas.drawPath(pathCenter, trunkMid);
    canvas.drawPath(pathRight, trunkDark);

    // Copa Geodésica en 3D Low-Poly
    final sphereCenter = Offset(
      center.x,
      size.y - trunkHeight - (_crownRadius * 0.8),
    );
    final darkBorder = Paint()
      ..color = isDark ? const Color(0x0D06100B) : const Color(0x0D0D2B1D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final TreePalette palette;
    switch (_treeType) {
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

    _sphereInstance.renderGeodesicSphere(
      canvas,
      sphereCenter,
      _crownRadius,
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

    // Sombra del árbol en el suelo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.x + 2, size.y - 2),
        width: _crownRadius * 1.6,
        height: _crownRadius * 0.45,
      ),
      _shadowPaint,
    );

    // Balanceo de rotación física desde el pie
    canvas.translate(center.x, size.y - 4);
    double rotAngle = math.sin(_swayTime * _swaySpeed + _swayOffset) * 0.02;
    if (_isShaking) {
      rotAngle +=
          math.sin(_shakeTime * 45) * 0.12 * math.exp(-_shakeTime * 3.5);
    }
    canvas.rotate(rotAngle);
    canvas.translate(-center.x, -(size.y - 4));

    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null || _cachedForDark != isDark) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _isShaking = true;
    _shakeTime = 0.0;

    final parentComponent = parent;
    if (parentComponent == null) return;

    // Limit maximum active leaf components to 15 to prevent performance drops
    final activeLeaves = parentComponent.children
        .whereType<InteractiveLeafComponent>()
        .length;
    if (activeLeaves > 15) return;

    final random = math.Random();
    final treeGlobalTopPos = position + Vector2(0, -size.y * 0.6);

    for (int i = 0; i < 3; i++) {
      final leafOffset = Vector2(
        (random.nextDouble() - 0.5) * 28.0,
        (random.nextDouble() - 0.5) * 16.0,
      );
      final fallingLeaf = InteractiveLeafComponent(
        position: treeGlobalTopPos + leafOffset,
      );
      fallingLeaf.triggerFlyaway();
      parentComponent.add(fallingLeaf);
    }
  }
}
