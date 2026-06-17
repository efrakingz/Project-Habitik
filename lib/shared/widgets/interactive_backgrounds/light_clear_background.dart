import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:habitik/core/theme/theme.dart';
import 'plaza_components.dart';

// El widget contenedor que autodetecta su tamaño y renderiza el fondo interactivo claro
class LightClearBackground extends StatefulWidget {
  const LightClearBackground({super.key});

  @override
  State<LightClearBackground> createState() => _LightClearBackgroundState();
}

class _LightClearBackgroundState extends State<LightClearBackground> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final game = LightClearGame(
              screenWidth: width,
              mapHeight: height,
              isDark: isDark,
            );

            return GameWidget(
              key: ValueKey('light_clear_${isDark}_${width}_$height'),
              game: game,
            );
          },
        );
      },
    );
  }
}

class LightClearGame extends FlameGame {
  final double mapHeight;
  final double screenWidth;
  final bool isDark;

  LightClearGame({
    required this.mapHeight,
    required this.screenWidth,
    required this.isDark,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 1. Terreno con colinas
    add(LightOrganicTerrainComponent());

    // 2. Colocar elementos naturales distribuidos de forma no invasiva
    final random = math.Random(1337);

    // Briznas de césped (12 tufts)
    for (int i = 0; i < 12; i++) {
      final tx = 20.0 + random.nextDouble() * (screenWidth - 40.0);
      final ty = 40.0 + random.nextDouble() * (mapHeight - 80.0);
      add(GrassTuftComponent(position: Vector2(tx, ty)));
    }

    // Flores silvestres (6 unidades)
    final flowerColors = [
      const Color(0xFFF48FB1), // Rosa
      const Color(0xFFFFD54F), // Amarillo
      const Color(0xFF90CAF9), // Celeste
    ];
    for (int i = 0; i < 6; i++) {
      final fx = 25.0 + random.nextDouble() * (screenWidth - 50.0);
      final fy = 40.0 + random.nextDouble() * (mapHeight - 80.0);
      add(
        AnimatedFlowerComponent(
          position: Vector2(fx, fy),
          petalColor: flowerColors[random.nextInt(flowerColors.length)],
        ),
      );
    }

    // Árboles interactivos (6 unidades dispersas) con control de colisión
    final List<Vector2> placedObjects = [];
    bool canPlace(Vector2 pos, double minDistance) {
      for (final p in placedObjects) {
        if (p.distanceTo(pos) < minDistance) return false;
      }
      return true;
    }

    int placedTrees = 0;
    int attempts = 0;
    while (placedTrees < 6 && attempts < 150) {
      attempts++;
      final tx = 40.0 + random.nextDouble() * (screenWidth - 80.0);
      final ty = 60.0 + random.nextDouble() * (mapHeight - 120.0);
      final treePos = Vector2(tx, ty);

      if (canPlace(treePos, 50.0)) {
        placedObjects.add(treePos);
        add(InteractiveTreeComponent(position: treePos));
        placedTrees++;

        // Ocasionalmente un arbusto de acompañamiento
        if (random.nextBool()) {
          final bushPos = Vector2(
            tx + (random.nextBool() ? 12.0 : -12.0),
            ty + 6.0,
          );
          if (canPlace(bushPos, 15.0)) {
            placedObjects.add(bushPos);
            add(DetailedBushComponent(position: bushPos));
          }
        }
      }
    }

    // Arbustos independientes (5 unidades)
    for (int i = 0; i < 5; i++) {
      final bx = 25.0 + random.nextDouble() * (screenWidth - 50.0);
      final by = 40.0 + random.nextDouble() * (mapHeight - 80.0);
      add(DetailedBushComponent(position: Vector2(bx, by)));
    }

    // Rocas cálidas decorativas (3 unidades)
    for (int i = 0; i < 3; i++) {
      final rx = 25.0 + random.nextDouble() * (screenWidth - 50.0);
      final ry = 40.0 + random.nextDouble() * (mapHeight - 80.0);
      add(DecorativeRockComponent(position: Vector2(rx, ry)));
    }

    // 3. Administrador ambiental ligero (luciérnagas tranquilas y sombras suaves)
    add(LightAmbienceManagerComponent());
  }

  @override
  Color backgroundColor() {
    return isDark ? const Color(0xFF09140F) : const Color(0xFF8CD456);
  }
}

// Terreno orgánico de colores muy claros y pastel en modo claro, oscuro en modo nocturno
class LightOrganicTerrainComponent extends PositionComponent
    with HasGameReference {
  LightOrganicTerrainComponent() : super(priority: 0);

  ui.Picture? _cachedPicture;
  bool? _cachedForDark;
  Vector2? _cachedSize;

  void _createCachedPicture(bool isDark) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);

    // Fondo base verde vibrante en modo diurno, verde oscuro en modo nocturno
    canvas.drawRect(
      rect,
      Paint()
        ..color = isDark ? const Color(0xFF09140F) : const Color(0xFF8CD456),
    );

    final hillPaint = Paint()..style = PaintingStyle.fill;

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
  void render(Canvas canvas) {
    final isDark = (game as LightClearGame).isDark;
    if (_cachedPicture == null || _cachedForDark != isDark || _cachedSize != game.size) {
      _createCachedPicture(isDark);
    }
    canvas.drawPicture(_cachedPicture!);
  }

  Path _createHillPath(
    double startYRatio,
    double endYRatio,
    double controlYRatio,
  ) {
    final path = Path();
    final startY = startYRatio * game.size.y;
    final endY = endYRatio * game.size.y;
    final controlY = controlYRatio * game.size.y;

    path.moveTo(-50, startY);
    path.quadraticBezierTo(game.size.x * 0.5, controlY, game.size.x + 50, endY);
    path.lineTo(game.size.x + 50, game.size.y + 50);
    path.lineTo(-50, game.size.y + 50);
    path.close();
    return path;
  }
}

// Administrador ambiental ligero: pocas luciérnagas y nubes muy transparentes
class LightAmbienceManagerComponent extends PositionComponent
    with HasGameReference {
  final List<Firefly> _fireflies = [];
  final List<CloudShadow> _clouds = [];
  final math.Random _random = math.Random();
  double _cloudTimer = 0.0;

  bool _initialized = false;

  LightAmbienceManagerComponent() : super(priority: 5);

  void _initializeAmbience() {
    final isDark = (game as LightClearGame).isDark;
    // 20 luciérnagas de noche, 0 de día
    final fireflyCount = isDark ? 20 : 0;
    for (int i = 0; i < fireflyCount; i++) {
      _fireflies.add(
        Firefly(
          position: Vector2(
            _random.nextDouble() * game.size.x,
            _random.nextDouble() * game.size.y,
          ),
          speed: 10.0 + _random.nextDouble() * 15.0,
          angle: _random.nextDouble() * math.pi * 2,
          pulseSpeed: 1.5 + _random.nextDouble() * 2.0,
          scale: 0.7 + _random.nextDouble() * 0.6,
        ),
      );
    }

    // 1 nube
    _clouds.add(
      CloudShadow(
        position: Vector2(-200, _random.nextDouble() * game.size.y * 0.5),
        speed: 6.0 + _random.nextDouble() * 4.0,
        sizeX: 250 + _random.nextDouble() * 120,
        sizeY: 120 + _random.nextDouble() * 60,
      ),
    );

    // Mariposas tanto de día como de noche
    for (int i = 0; i < 2; i++) {
      game.add(
        ButterflyComponent(
          position: Vector2(
            60 + _random.nextDouble() * (game.size.x - 120),
            100 + _random.nextDouble() * (game.size.y - 200),
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_initialized && game.size.x > 0 && game.size.y > 0) {
      _initialized = true;
      _initializeAmbience();
    }

    for (final f in _fireflies) {
      f.update(dt);
      if (f.position.x < 0) f.position.x = game.size.x;
      if (f.position.x > game.size.x) f.position.x = 0;
      if (f.position.y < 0) f.position.y = game.size.y;
      if (f.position.y > game.size.y) f.position.y = 0;
    }

    for (int i = _clouds.length - 1; i >= 0; i--) {
      _clouds[i].update(dt);
      if (_clouds[i].position.x > game.size.x + 250 ||
          _clouds[i].position.y > game.size.y + 200) {
        _clouds.removeAt(i);
      }
    }

    _cloudTimer += dt;
    if (_cloudTimer > 45.0) {
      _cloudTimer = 0.0;
      _clouds.add(
        CloudShadow(
          position: Vector2(
            -350,
            -100 + _random.nextDouble() * game.size.y * 0.4,
          ),
          speed: 5.0 + _random.nextDouble() * 4.0,
          sizeX: 280 + _random.nextDouble() * 150,
          sizeY: 130 + _random.nextDouble() * 80,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    // Nubes sumamente transparentes (alpha: 0.015 en lugar de 0.03)
    final cloudPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.015)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

    for (final c in _clouds) {
      canvas.drawOval(
        Rect.fromLTWH(c.position.x, c.position.y, c.sizeX, c.sizeY),
        cloudPaint,
      );
    }

    for (final f in _fireflies) {
      final glowAlpha = 0.3 + math.sin(f.time * f.pulseSpeed) * 0.3;

      final outerPaint = Paint()
        ..color = const Color(0xFFC8E6C9).withValues(alpha: glowAlpha * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(
        Offset(f.position.x, f.position.y),
        5.0 * f.scale,
        outerPaint,
      );

      final corePaint = Paint()
        ..color = const Color(
          0xFFFFF59D,
        ).withValues(alpha: (glowAlpha + 0.25).clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(f.position.x, f.position.y),
        1.5 * f.scale,
        corePaint,
      );
    }
  }
}
