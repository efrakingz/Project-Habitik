import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:habitik/core/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GrassTuftComponent - Briznas de césped decorativas (Triángulos realistas de pasto)
// ─────────────────────────────────────────────────────────────────────────────
class GrassTuftComponent extends PositionComponent {
  late final ui.Path _bladeLeft;
  late final ui.Path _bladeCenter;
  late final ui.Path _bladeRight;

  static final Paint _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.05);
  static final Paint _paint = Paint()..style = PaintingStyle.fill;

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;

  GrassTuftComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(12, 10),
        anchor: Anchor.bottomCenter,
        priority: 1,
      ) {
    _bladeLeft = ui.Path()
      ..moveTo(2, 9)
      ..quadraticBezierTo(1, 5, 0, 2)
      ..quadraticBezierTo(3, 4, 4, 9)
      ..close();

    _bladeCenter = ui.Path()
      ..moveTo(4, 9)
      ..quadraticBezierTo(5.5, 3, 6, 0)
      ..quadraticBezierTo(6.5, 3, 8, 9)
      ..close();

    _bladeRight = ui.Path()
      ..moveTo(8, 9)
      ..quadraticBezierTo(9, 4, 12, 2)
      ..quadraticBezierTo(11, 5, 10, 9)
      ..close();
  }

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawOval(const Rect.fromLTWH(1, 7, 10, 3), _shadowPaint);

    _paint.color = (isDark ? const Color(0xFF133C26) : const Color(0xFF7CB342))
        .withValues(alpha: 0.95);

    canvas.drawPath(_bladeLeft, _paint);
    canvas.drawPath(_bladeCenter, _paint);
    canvas.drawPath(_bladeRight, _paint);

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
  }

  @override
  void render(Canvas canvas) {
    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null || _cachedForDark != isDark) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SteppingStoneComponent - Nodos principales de paso
// ─────────────────────────────────────────────────────────────────────────────
class SteppingStoneComponent extends PositionComponent {
  ui.Picture? _cachedPicture;
  bool? _cachedForDark;

  SteppingStoneComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(24, 16),
        anchor: Anchor.center,
        priority: 10 + position.y.toInt(),
      );

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final stonePaint = Paint();
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    stonePaint.color = isDark
        ? const Color(0xFF4E3D30)
        : const Color(0xFFBCAAA4);
    borderPaint.color = isDark
        ? const Color(0x401F1510)
        : const Color(0x408D6E63);

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(1, 2),
        width: size.x,
        height: size.y,
      ),
      shadowPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
      stonePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
      borderPaint,
    );

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
  }

  @override
  void render(Canvas canvas) {
    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null || _cachedForDark != isDark) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DecorativeRockComponent - Rocas facetadas tridimensionales
// ─────────────────────────────────────────────────────────────────────────────
class DecorativeRockComponent extends PositionComponent {
  ui.Picture? _cachedPicture;
  bool? _cachedForDark;

  DecorativeRockComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(26, 18),
        anchor: Anchor.center,
        priority: 10 + position.y.toInt(),
      );

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final w = size.x;
    final h = size.y;

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(1.5, 2.5), width: w, height: h),
      shadowPaint,
    );

    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFF1C1E20) : const Color(0xFF8B877E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final pathMain = ui.Path()
      ..moveTo(w * 0.12, h * 0.8)
      ..lineTo(w * 0.5, h * 0.92)
      ..lineTo(w * 0.88, h * 0.78)
      ..lineTo(w * 0.72, h * 0.22)
      ..lineTo(w * 0.32, h * 0.12)
      ..close();
    canvas.drawPath(
      pathMain,
      Paint()
        ..color = isDark ? const Color(0xFF2C2F30) : const Color(0xFFD4D0C5),
    );

    final pathShadow = ui.Path()
      ..moveTo(w * 0.5, h * 0.92)
      ..lineTo(w * 0.88, h * 0.78)
      ..lineTo(w * 0.72, h * 0.22)
      ..lineTo(w * 0.52, h * 0.48)
      ..close();
    canvas.drawPath(
      pathShadow,
      Paint()
        ..color = isDark ? const Color(0xFF1A1C1E) : const Color(0xFFABA69C),
    );

    final pathHighlight = ui.Path()
      ..moveTo(w * 0.12, h * 0.8)
      ..lineTo(w * 0.32, h * 0.12)
      ..lineTo(w * 0.52, h * 0.48)
      ..lineTo(w * 0.28, h * 0.58)
      ..close();
    canvas.drawPath(
      pathHighlight,
      Paint()
        ..color = isDark ? const Color(0xFF3E4345) : const Color(0xFFECEAE4),
    );

    canvas.drawPath(pathMain, borderPaint);

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
  }

  @override
  void render(Canvas canvas) {
    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null || _cachedForDark != isDark) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WoodenFenceComponent - Cercas o vallas de campo facetadas 3D
// ─────────────────────────────────────────────────────────────────────────────
class WoodenFenceComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;
  Vector2? _cachedStart;
  Vector2? _cachedEnd;

  WoodenFenceComponent({required this.start, required this.end})
    : super(priority: 5 + ((start.y + end.y) / 2).toInt());

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final postColor = isDark
        ? const Color(0xFF3E2723)
        : const Color(0xFF7D5C4C);
    final postShadowColor = isDark
        ? const Color(0xFF21100E)
        : const Color(0xFF5D4037);
    final postHighlightColor = isDark
        ? const Color(0xFF5D4037)
        : const Color(0xFF9E7E6E);

    final railColor = isDark
        ? const Color(0xFF331E1A)
        : const Color(0xFF6D4C41);
    final railHighlightColor = isDark
        ? const Color(0xFF4E342E)
        : const Color(0xFF8D6E63);

    final diff = end - start;
    final length = diff.length;

    // Un poste cada ~24px
    final numPosts = (length / 24.0).ceil() + 1;
    final stepX = length / (numPosts - 1);

    // 1. Dibujar rieles horizontales (2 barras de madera)
    final railPaint = Paint()..color = railColor;
    final railHighlightPaint = Paint()..color = railHighlightColor;

    // Riel superior
    canvas.drawRect(Rect.fromLTWH(0, -18, length, 3.5), railPaint);
    canvas.drawRect(Rect.fromLTWH(0, -18, length, 1.2), railHighlightPaint);

    // Riel inferior
    canvas.drawRect(Rect.fromLTWH(0, -10, length, 3.5), railPaint);
    canvas.drawRect(Rect.fromLTWH(0, -10, length, 1.2), railHighlightPaint);

    // 2. Dibujar postes verticales
    final postPaint = Paint()..color = postColor;
    final postShadowPaint = Paint()..color = postShadowColor;
    final postHighlightPaint = Paint()..color = postHighlightColor;
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.12);

    for (int i = 0; i < numPosts; i++) {
      final px = i * stepX;

      // Sombra del poste en el pasto
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px + 1, 1), width: 5.5, height: 1.8),
        shadowPaint,
      );

      // Poste 3D facetado
      final w = 4.5;
      final h = 23.0;

      // Rectángulo principal
      canvas.drawRect(Rect.fromLTWH(px - w / 2, -h, w, h), postPaint);

      // Faceta de sombra (lado derecho)
      canvas.drawRect(Rect.fromLTWH(px, -h, w / 2, h), postShadowPaint);

      // Faceta de brillo (lado izquierdo)
      canvas.drawRect(
        Rect.fromLTWH(px - w / 2, -h, w / 4, h),
        postHighlightPaint,
      );

      // Punta superior de la estaca (triángulo 3D)
      final tipPathLeft = ui.Path()
        ..moveTo(px - w / 2, -h)
        ..lineTo(px, -h - 3.5)
        ..lineTo(px, -h)
        ..close();
      final tipPathRight = ui.Path()
        ..moveTo(px, -h)
        ..lineTo(px, -h - 3.5)
        ..lineTo(px + w / 2, -h)
        ..close();

      canvas.drawPath(tipPathLeft, postHighlightPaint);
      canvas.drawPath(tipPathRight, postShadowPaint);
    }

    _cachedPicture = recorder.endRecording();
    _cachedForDark = isDark;
  }

  @override
  void render(Canvas canvas) {
    final isDark = isDarkModeNotifier.value;
    if (_cachedPicture == null ||
        _cachedForDark != isDark ||
        _cachedStart == null ||
        _cachedStart!.x != start.x ||
        _cachedStart!.y != start.y ||
        _cachedEnd == null ||
        _cachedEnd!.x != end.x ||
        _cachedEnd!.y != end.y) {
      _createCachedPicture(isDark);
      _cachedStart = start.clone();
      _cachedEnd = end.clone();
    }

    final diff = end - start;
    final angle = math.atan2(diff.y, diff.x);

    canvas.save();
    canvas.translate(start.x, start.y);
    canvas.rotate(angle);
    canvas.drawPicture(_cachedPicture!);
    canvas.restore();
  }
}

// Extensiones útiles para degradar y aclarar colores
extension ColorDarken on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
