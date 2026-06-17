import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'plaza_components.dart';

// El widget contenedor que maneja el estado y ciclo de vida de Flame
class RetosPlazaBackground extends StatefulWidget {
  final List<ChallengeType> challenges;
  final ValueNotifier<Set<String>> completedChallengesNotifier;
  final double mapHeight;
  final double screenWidth;
  final Map<String, Offset> nodes;
  final ValueNotifier<double> scrollOffsetNotifier;
  final VoidCallback? onBackgroundTap;

  const RetosPlazaBackground({
    super.key,
    required this.challenges,
    required this.completedChallengesNotifier,
    required this.mapHeight,
    required this.screenWidth,
    required this.nodes,
    required this.scrollOffsetNotifier,
    this.onBackgroundTap,
  });

  @override
  State<RetosPlazaBackground> createState() => _RetosPlazaBackgroundState();
}

class _RetosPlazaBackgroundState extends State<RetosPlazaBackground> {
  RetosPlazaGame? _game;
  double? _lastWidth;
  double? _lastHeight;

  void _initGame() {
    _game = RetosPlazaGame(
      challenges: widget.challenges,
      completedChallengesNotifier: widget.completedChallengesNotifier,
      mapHeight: widget.mapHeight,
      screenWidth: widget.screenWidth,
      nodes: widget.nodes,
      scrollOffsetNotifier: widget.scrollOffsetNotifier,
      onBackgroundTap: widget.onBackgroundTap,
    );
    _lastWidth = widget.screenWidth;
    _lastHeight = widget.mapHeight;
  }

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void didUpdateWidget(RetosPlazaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lastWidth != widget.screenWidth || _lastHeight != widget.mapHeight) {
      _initGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game!);
  }
}

class RetosPlazaGame extends FlameGame with TapCallbacks {
  final List<ChallengeType> challenges;
  final ValueNotifier<Set<String>> completedChallengesNotifier;
  final double mapHeight;
  final double screenWidth;
  final Map<String, Offset> nodes;
  final ValueNotifier<double> scrollOffsetNotifier;
  final VoidCallback? onBackgroundTap;

  final Map<String, Vector2> _nodes = {};
  List<String> _orderedChallengeIds = [];
  Color _bgColor = const Color(0xFF8CD456);

  RetosPlazaGame({
    required this.challenges,
    required this.completedChallengesNotifier,
    required this.mapHeight,
    required this.screenWidth,
    required this.nodes,
    required this.scrollOffsetNotifier,
    this.onBackgroundTap,
  });



  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configurar cámara nativa para scroll
    camera.viewfinder.anchor = Anchor.topLeft;
    scrollOffsetNotifier.addListener(_onScroll);
    _onScroll(); // aplicar posición inicial

    // Escuchar cambio de tema UNA vez, sin reconstruir el GameWidget
    isDarkModeNotifier.addListener(_onThemeChanged);
    _onThemeChanged(); // aplicar estado inicial

    final orderedChallenges = challenges.reversed.toList();
    _orderedChallengeIds = orderedChallenges.map((c) => c.id).toList();

    // 1. Mapear coordenadas calculadas de Flutter (Offset) a Flame (Vector2)
    _nodes.clear();
    nodes.forEach((id, offset) {
      _nodes[id] = Vector2(offset.dx, offset.dy);
    });

    // 2. Fondo de Terreno Orgánico en degradado lime-green de Muro Familiar
    world.add(OrganicTerrainComponent(mapHeight: mapHeight + 80.0));

    // 3. Pintor de Sendero con Adoquines Sombreados 3D
    world.add(
      DetailedPathPainter(
        getNodes: () => _nodes,
        orderedChallengeIds: _orderedChallengeIds,
        mapHeight: mapHeight + 80.0,
      ),
    );



    // 5. Agregar Piedras de Paso principales en cada nodo
    for (final id in _orderedChallengeIds) {
      final pos = _nodes[id]!;
      if (id == 'pesca') {
        world.add(SteppingStoneComponent(position: pos + Vector2(-30, 20)));
      } else {
        world.add(SteppingStoneComponent(position: pos));
      }
    }

    // 6. Generar Árboles, Arbustos, Flores, Rocas y Césped con filtro de lago
    final random = math.Random(1337);

    final List<Vector2> placedObjects = [];

    bool canPlace(Vector2 pos, double minDistance) {
      for (final p in placedObjects) {
        if (p.distanceTo(pos) < minDistance) return false;
      }
      return true;
    }

    // Manojos de césped
    for (int i = 0; i < 12; i++) {
      final tuftX = 20.0 + random.nextDouble() * (screenWidth - 40.0);
      final tuftY = 40.0 + random.nextDouble() * (mapHeight - 80.0);

      world.add(GrassTuftComponent(position: Vector2(tuftX, tuftY)));
    }

    // Flores: Colores variados
    final flowerColors = [
      const Color(0xFFE57373), // Rojo
      const Color(0xFFF48FB1), // Rosa
      const Color(0xFF64B5F6), // Azul
      const Color(0xFFFFD54F), // Amarillo
    ];

    for (int i = 0; i < orderedChallenges.length; i++) {
      final id = orderedChallenges[i].id;
      final pos = _nodes[id]!;

      // Árbol interactivo geodésico para balancear (lado opuesto del nodo)
      final treeX = (i % 2 == 0)
          ? (screenWidth * 0.75 + (random.nextDouble() - 0.5) * 40.0)
          : (screenWidth * 0.25 + (random.nextDouble() - 0.5) * 40.0);
      final treeY = pos.y + (random.nextDouble() - 0.5) * 30.0;
      final treePos = Vector2(treeX, treeY);

      if (canPlace(treePos, 35.0)) {
        placedObjects.add(treePos);
        world.add(InteractiveTreeComponent(position: treePos));

        // Agregar arbusto acompañando al árbol (agrupación natural)
        final bushPos = Vector2(
          treeX + (random.nextBool() ? 15.0 : -15.0),
          treeY + 6.0,
        );
        if (canPlace(bushPos, 15.0)) {
          placedObjects.add(bushPos);
          world.add(DetailedBushComponent(position: bushPos));
        }
      }

      // Árboles en los costados
      if (random.nextDouble() > 0.4) {
        final edgeTreePos = Vector2(
          random.nextBool() ? 25.0 : (screenWidth - 25.0),
          pos.y - 45.0 - random.nextDouble() * 45.0,
        );
        if (canPlace(edgeTreePos, 35.0)) {
          placedObjects.add(edgeTreePos);
          world.add(InteractiveTreeComponent(position: edgeTreePos));
        }
      }

      // Arbustos adicionales junto al sendero
      if (random.nextDouble() > 0.3) {
        final bushPos = Vector2(
          pos.x +
              (random.nextBool() ? 35.0 : -35.0) +
              (random.nextDouble() - 0.5) * 20.0,
          pos.y + (random.nextDouble() - 0.5) * 20.0,
        );
        if (canPlace(bushPos, 15.0) &&
            bushPos.x > 20 &&
            bushPos.x < screenWidth - 20) {
          placedObjects.add(bushPos);
          world.add(DetailedBushComponent(position: bushPos));
        }
      }

      // Flores silvestres con polen
      for (int k = 0; k < 2; k++) {
        final flowerX = pos.x + (random.nextDouble() - 0.5) * 80.0;
        final flowerY = pos.y + 40.0 + (random.nextDouble() - 0.5) * 30.0;

        final distToNode = Vector2(flowerX, flowerY).distanceTo(pos);
        if (distToNode > 25.0 &&
            flowerX > 20 &&
            flowerX < screenWidth - 20) {
          world.add(
            AnimatedFlowerComponent(
              position: Vector2(flowerX, flowerY),
              petalColor: flowerColors[random.nextInt(flowerColors.length)],
            ),
          );
        }
      }

      // Rocas decorativas
      if (i % 2 == 0) {
        final rockX = pos.x + (random.nextBool() ? 40.0 : -40.0);
        final rockY = pos.y - 30.0;
        if (rockX > 20 &&
            rockX < screenWidth - 20) {
          world.add(DecorativeRockComponent(position: Vector2(rockX, rockY)));
        }
      }
    }

    // Bosque decorativo superior (Inicio) - Colocar algunos árboles decorativos arriba (antes del primer reto)
    int placedTopTrees = 0;
    int topAttempts = 0;
    while (placedTopTrees < 3 && topAttempts < 100) {
      topAttempts++;
      final topX =
          screenWidth * 0.15 + random.nextDouble() * (screenWidth * 0.7);
      final topY = 40.0 + random.nextDouble() * 140.0;
      final topPos = Vector2(topX, topY);
      if (canPlace(topPos, 35.0)) {
        placedObjects.add(topPos);
        world.add(InteractiveTreeComponent(position: topPos));
        placedTopTrees++;

        final bushPos = Vector2(
          topX + (random.nextBool() ? 12.0 : -12.0),
          topY + 8.0,
        );
        if (canPlace(bushPos, 15.0)) {
          placedObjects.add(bushPos);
          world.add(DetailedBushComponent(position: bushPos));
        }
      }
    }
    // ── BARRERA FINAL: valla y árboles en el fondo ───────────────
    final bottomY = mapHeight + 80.0;
    final fenceY = bottomY - 60.0; 
    final backTreeY = bottomY - 45.0; 
    final frontTreeY = bottomY - 30.0; 

    // 1. Valla delante (Y menor, pero con su prioridad dinámica se dibuja atrás si el Y es menor)
    world.add(
      WoodenFenceComponent(
        start: Vector2(-10.0, fenceY),
        end: Vector2(screenWidth + 10.0, fenceY),
      ),
    );

    // 2. Segunda fila de árboles (más atrás que la delantera, pero delante de la valla)
    for (int t = 0; t < 6; t++) {
      final treeX =
          (screenWidth / 7 * 0.5) +
          t * (screenWidth / 7) +
          (random.nextDouble() - 0.5) * 10.0;
      world.add(
        InteractiveTreeComponent(
          position: Vector2(
            treeX,
            backTreeY + (random.nextDouble() - 0.5) * 10.0,
          ),
        ),
      );
    }

    // 3. Fila delantera de árboles (más adelante que la trasera)
    final frontTreeStep = screenWidth / 7;
    for (int t = 0; t < 8; t++) {
      final treeX = (t * frontTreeStep) + (random.nextDouble() - 0.5) * 12.0;
      world.add(
        InteractiveTreeComponent(
          position: Vector2(
            treeX,
            frontTreeY + (random.nextDouble() - 0.5) * 15.0,
          ),
        ),
      );
    }

    // 7. Administrador ambiental para luciérnagas y nubes (mariposas se inician aquí)
    add(AmbienceManagerComponent());
  }

  void _onScroll() {
    camera.viewfinder.position = Vector2(0, scrollOffsetNotifier.value);
  }

  void _onThemeChanged() {
    _bgColor = isDarkModeNotifier.value
        ? const Color(0xFF09140F)
        : const Color(0xFF8CD456);
  }

  @override
  void onRemove() {
    scrollOffsetNotifier.removeListener(_onScroll);
    isDarkModeNotifier.removeListener(_onThemeChanged);
    super.onRemove();
  }

  @override
  Color backgroundColor() => _bgColor;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!event.handled) {
      onBackgroundTap?.call();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AmbienceManagerComponent - Luciérnagas y nubes
// ─────────────────────────────────────────────────────────────────────────────
/// Nota: Este componente gestiona efectos de ambiente a nivel de pantalla.
/// Las mariposas se añaden a `game` (y no a `world`) de forma intencional
/// para que permanezcan en el viewport del usuario en pantalla fija
/// mientras se hace scroll en el mapa de desafíos.
class AmbienceManagerComponent extends PositionComponent with HasGameReference<RetosPlazaGame> {
  final List<Firefly> _fireflies = [];
  final List<CloudShadow> _clouds = [];
  final math.Random _random = math.Random();
  double _cloudTimer = 0.0;

  // Pre-allocated paint objects to avoid allocations in render loop
  final Paint _cloudPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.03)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22.0);

  final Paint _outerPaint = Paint()..color = const Color(0xFFC8E6C9);
  final Paint _corePaint = Paint()..color = const Color(0xFFFFF59D);

  bool _initialized = false;

  AmbienceManagerComponent() : super(priority: 5);

  @override
  void onMount() {
    super.onMount();
    isDarkModeNotifier.addListener(_onThemeChanged);
  }

  @override
  void onRemove() {
    isDarkModeNotifier.removeListener(_onThemeChanged);
    
    // Limpieza de mariposas activas
    final activeButterflies = game.world.children.whereType<ButterflyComponent>().toList();
    for (final b in activeButterflies) {
      b.removeFromParent();
    }
    
    super.onRemove();
  }

  void _onThemeChanged() {
    if (!isMounted) return;
    if (game.size.x == 0 || game.size.y == 0) return;
    final isDark = isDarkModeNotifier.value;

    // 1. Ajustar cantidad de luciérnagas dinámicamente (solo de noche)
    final targetCount = isDark ? 65 : 0;
    if (_fireflies.length < targetCount) {
      final toAdd = targetCount - _fireflies.length;
      for (int i = 0; i < toAdd; i++) {
        _fireflies.add(
          Firefly(
            position: Vector2(
              _random.nextDouble() * game.size.x,
              _random.nextDouble() * game.size.y,
            ),
            speed: 12.0 + _random.nextDouble() * 18.0,
            angle: _random.nextDouble() * math.pi * 2,
            pulseSpeed: 1.8 + _random.nextDouble() * 2.5,
            scale: 0.75 + _random.nextDouble() * 0.75,
          ),
        );
      }
    } else if (_fireflies.length > targetCount) {
      _fireflies.removeRange(targetCount, _fireflies.length);
    }

    // 2. Ajustar presencia de mariposas dinámicamente (mariposas solo de día)
    final activeButterflies = game.world.children.whereType<ButterflyComponent>().toList();
    if (isDark) {
      // De noche se ocultan/eliminan las mariposas
      for (final b in activeButterflies) {
        b.removeFromParent();
      }
    } else {
      // De día se añaden las mariposas si están vacías en la plaza
      if (activeButterflies.isEmpty) {
        final totalHeight = game.mapHeight + 80.0;
        for (int i = 0; i < 4; i++) {
          game.world.add(
            ButterflyComponent(
              position: Vector2(
                60 + _random.nextDouble() * (game.screenWidth - 120),
                100 + _random.nextDouble() * (totalHeight - 200),
              ),
              mapWidth: game.screenWidth,
              mapHeight: totalHeight,
            ),
          );
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_initialized && game.size.x > 0 && game.size.y > 0) {
      _initialized = true;
      // Nube inicial
      _clouds.add(
        CloudShadow(
          position: Vector2(-250, _random.nextDouble() * game.size.y * 0.6),
          speed: 8.0 + _random.nextDouble() * 6.0,
          sizeX: 300 + _random.nextDouble() * 180,
          sizeY: 150 + _random.nextDouble() * 90,
        ),
      );
      _onThemeChanged();
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
    if (_cloudTimer > 40.0) {
      _cloudTimer = 0.0;
      _clouds.add(
        CloudShadow(
          position: Vector2(
            -450,
            -150 + _random.nextDouble() * game.size.y * 0.5,
          ),
          speed: 7.0 + _random.nextDouble() * 6.0,
          sizeX: 350 + _random.nextDouble() * 200,
          sizeY: 170 + _random.nextDouble() * 100,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    for (final c in _clouds) {
      canvas.drawOval(
        Rect.fromLTWH(c.position.x, c.position.y, c.sizeX, c.sizeY),
        _cloudPaint,
      );
    }

    if (_fireflies.isNotEmpty) {
      // Calcular el bounding rect de las luciérnagas activas para evitar saveLayer(null)
      double minX = double.infinity, minY = double.infinity;
      double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
      for (final f in _fireflies) {
        final r = 5.5 * f.scale;
        if (f.position.x - r < minX) minX = f.position.x - r;
        if (f.position.y - r < minY) minY = f.position.y - r;
        if (f.position.x + r > maxX) maxX = f.position.x + r;
        if (f.position.y + r > maxY) maxY = f.position.y + r;
      }

      // Save a single layer within tight bounds to apply the blur once across all fireflies outer glows
      canvas.saveLayer(
        Rect.fromLTRB(minX - 8.0, minY - 8.0, maxX + 8.0, maxY + 8.0),
        Paint()
          ..imageFilter = ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      );
      for (final f in _fireflies) {
        final glowAlpha = 0.35 + math.sin(f.time * f.pulseSpeed) * 0.35;
        _outerPaint.color = const Color(0xFFC8E6C9).withValues(alpha: glowAlpha * 0.35);
        canvas.drawCircle(
          Offset(f.position.x, f.position.y),
          5.5 * f.scale,
          _outerPaint,
        );
      }
      canvas.restore();

      // Draw sharp cores
      for (final f in _fireflies) {
        final glowAlpha = 0.35 + math.sin(f.time * f.pulseSpeed) * 0.35;
        _corePaint.color = const Color(0xFFFFF59D).withValues(alpha: (glowAlpha + 0.3).clamp(0.0, 1.0));
        canvas.drawCircle(
          Offset(f.position.x, f.position.y),
          1.8 * f.scale,
          _corePaint,
        );
      }
    }
  }
}
