import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';
import 'ocean_sprites.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mar Limpio – Juego Bono 2D Pixel Art
// ─────────────────────────────────────────────────────────────────────────────

// ── Tipos de entidades en el océano ──────────────────────────────────────────
enum OceanEntityType { trashBottle, trashBag, trashCan, trashShoe, fishBlue, fishGold, jellyfish, octopus }

// ── Datos de una entidad ──────────────────────────────────────────────────────
class OceanEntity {
  final int id;
  OceanEntityType type;
  Offset pos;        // posición actual
  Offset basePos;    // posición base para oscilación
  double speedX;     // velocidad horizontal (peces)
  double speedY;     // velocidad vertical (medusa sube, entidades caen)
  double phase;      // fase para sin()
  bool facingRight;
  bool alive;

  OceanEntity({
    required this.id,
    required this.type,
    required this.pos,
    required this.speedX,
    this.speedY = 0,
    this.phase = 0,
    this.facingRight = true,
    this.alive = true,
  }) : basePos = pos;

  // Tamaño visual de cada entidad
  Size get size {
    switch (type) {
      case OceanEntityType.fishBlue:   return const Size(52, 32);
      case OceanEntityType.fishGold:   return const Size(46, 28);
      case OceanEntityType.jellyfish:  return const Size(44, 60);
      case OceanEntityType.octopus:    return const Size(54, 56);
      default:                          return const Size(34, 46); // trash
    }
  }

  Rect get rect => Rect.fromCenter(center: pos, width: size.width * 0.7, height: size.height * 0.7);
}

// ── Estado del gancho ─────────────────────────────────────────────────────────
enum HookState { idle, casting, retracting }

// ── Feedback flotante ─────────────────────────────────────────────────────────
class _Feedback {
  final int id;
  final String text;
  final Color color;
  Offset pos;
  double opacity;
  double dy; // cuánto se ha movido hacia arriba

  _Feedback({required this.id, required this.text, required this.color, required this.pos})
      : opacity = 1.0, dy = 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────────────────────
class OceanCleanupChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const OceanCleanupChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<OceanCleanupChallenge> createState() => _OceanCleanupChallengeState();
}

class _OceanCleanupChallengeState extends State<OceanCleanupChallenge> with SingleTickerProviderStateMixin {
  // ── Game loop ──────────────────────────────────────────────────────────────
  late Ticker _ticker;
  double _time = 0; // tiempo absoluto en segundos
  double _lastDt = 0;

  // ── Screen & layout ────────────────────────────────────────────────────────
  double _screenW = 360;
  double _screenH = 600;
  double get _waterY => _screenH * 0.22; // Y donde comienza el agua
  double get _floorY => _screenH * 0.92; // Y del fondo marino

  // ── Barca ─────────────────────────────────────────────────────────────────
  double get _boatX => _screenW / 2;
  double get _boatY => _waterY - 8;

  // ── Gancho ────────────────────────────────────────────────────────────────
  HookState _hookState = HookState.idle;
  double _hookY = 0; // Y del gancho
  static const double _hookSpeed = 200.0;  // px/seg bajando
  static const double _retractSpeed = 280.0; // px/seg subiendo
  OceanEntity? _caughtEntity; // entidad atrapada (sube con el gancho)

  // ── Entidades ─────────────────────────────────────────────────────────────
  final List<OceanEntity> _entities = [];
  final List<_Feedback> _feedbacks = [];
  int _nextEntityId = 0;
  int _nextFeedbackId = 0;

  // ── Spawn timers ──────────────────────────────────────────────────────────
  double _nextTrashSpawn = 2.0;
  double _nextFishSpawn = 3.0;
  double _nextJellySpawn = 7.0;
  double _nextOctopusSpawn = 20.0;
  double _nextGoldFishSpawn = 15.0;

  // ── Burbujas ──────────────────────────────────────────────────────────────
  final List<_Bubble> _bubbles = [];

  // ── Puntuación & tiempo ───────────────────────────────────────────────────
  int _timeLeft = 30;
  int _trashCaught = 0;
  int _xpEarned = 0;
  int _coinsEarned = 0;
  bool _gameStarted = false;
  bool _gameOver = false;
  double _timeSinceLastSecond = 0;

  // ── Flash de pantalla ─────────────────────────────────────────────────────
  Color? _flashColor;
  double _flashOpacity = 0;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _hookY = _waterY + 20;
    _spawnInitialBubbles();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ── Game loop principal ───────────────────────────────────────────────────
  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = (elapsed.inMicroseconds / 1e6) - _time;
    _time = elapsed.inMicroseconds / 1e6;
    _lastDt = dt.clamp(0, 0.05); // cap a 50ms para evitar glitches

    if (!_gameStarted || _gameOver) {
      setState(() {}); // solo para animar fondo
      return;
    }

    // Timer
    _timeSinceLastSecond += _lastDt;
    if (_timeSinceLastSecond >= 1.0) {
      _timeSinceLastSecond -= 1.0;
      _timeLeft--;
      if (_timeLeft <= 0) {
        _timeLeft = 0;
        _gameOver = true;
      }
    }

    _updateHook();
    _updateEntities();
    _updateBubbles();
    _updateFeedbacks();
    _spawnEntities();
    _updateFlash();
    if (mounted) setState(() {});
  }

  // ── Actualizar gancho ──────────────────────────────────────────────────────
  void _updateHook() {
    if (_hookState == HookState.casting) {
      _hookY += _hookSpeed * _lastDt;

      // Mover entidad atrapada con el gancho
      if (_caughtEntity != null) {
        _caughtEntity!.pos = Offset(_boatX, _hookY);
      }

      // Comprobar colisión con entidades
      if (_caughtEntity == null) {
        for (final e in _entities) {
          if (!e.alive) continue;
          final hookRect = Rect.fromCenter(center: Offset(_boatX, _hookY), width: 14, height: 14);
          if (hookRect.overlaps(e.rect)) {
            _catchEntity(e);
            break;
          }
        }
      }

      // Llegar al fondo
      if (_hookY >= _floorY - 20) {
        _hookState = HookState.retracting;
      }
    } else if (_hookState == HookState.retracting) {
      _hookY -= _retractSpeed * _lastDt;

      if (_caughtEntity != null) {
        _caughtEntity!.pos = Offset(_boatX, _hookY);
      }

      // Llegar a la barca
      if (_hookY <= _boatY - 10) {
        _hookY = _boatY - 10;
        _hookState = HookState.idle;
        if (_caughtEntity != null) {
          _caughtEntity!.alive = false;
          _caughtEntity = null;
        }
      }
    }
  }

  // ── Atrapar entidad ────────────────────────────────────────────────────────
  void _catchEntity(OceanEntity e) {
    HapticFeedback.mediumImpact();
    _caughtEntity = e;
    _hookState = HookState.retracting;

    String feedText = '';
    Color feedColor = Colors.green;

    switch (e.type) {
      case OceanEntityType.trashBottle:
      case OceanEntityType.trashBag:
      case OceanEntityType.trashCan:
      case OceanEntityType.trashShoe:
        _trashCaught++;
        _xpEarned += 10;
        _timeLeft = (_timeLeft + 5).clamp(0, 90);
        feedText = '+10 XP  +5⏱';
        feedColor = HabitikColors.green500;
        break;
      case OceanEntityType.fishBlue:
        _xpEarned += 15;
        feedText = '+15 XP 🐟';
        feedColor = const Color(0xFF0096C7);
        break;
      case OceanEntityType.fishGold:
        _coinsEarned += 10;
        feedText = '+10 🪙';
        feedColor = const Color(0xFFFFD600);
        break;
      case OceanEntityType.jellyfish:
        _timeLeft = (_timeLeft - 3).clamp(0, 90);
        feedText = '-3⏱ ⚠️';
        feedColor = Colors.red;
        _triggerFlash(Colors.red);
        HapticFeedback.heavyImpact();
        break;
      case OceanEntityType.octopus:
        _xpEarned += 20;
        feedText = '+20 XP 🐙';
        feedColor = const Color(0xFF9C27B0);
        break;
    }

    _feedbacks.add(_Feedback(
      id: _nextFeedbackId++,
      text: feedText,
      color: feedColor,
      pos: Offset(e.pos.dx, e.pos.dy - 10),
    ));
  }

  // ── Actualizar entidades ───────────────────────────────────────────────────
  void _updateEntities() {
    for (final e in _entities) {
      if (!e.alive) continue;
      if (e == _caughtEntity) continue; // el gancho la mueve

      switch (e.type) {
        case OceanEntityType.fishBlue:
        case OceanEntityType.fishGold:
          // Nadan horizontalmente, rebotan en paredes
          e.pos = Offset(e.pos.dx + e.speedX * _lastDt, e.basePos.dy + sin(_time * 0.8 + e.phase) * 12);
          if (e.pos.dx < 20 || e.pos.dx > _screenW - 20) {
            e.speedX *= -1;
            e.facingRight = e.speedX > 0;
          }
          break;

        case OceanEntityType.trashBottle:
        case OceanEntityType.trashBag:
        case OceanEntityType.trashCan:
        case OceanEntityType.trashShoe:
          // Basura: oscila suavemente
          e.pos = Offset(
            e.basePos.dx + sin(_time * 0.6 + e.phase) * 10,
            e.basePos.dy + sin(_time * 1.1 + e.phase + 1) * 6,
          );
          break;

        case OceanEntityType.jellyfish:
          // Sube lentamente, reaparece abajo al llegar arriba
          e.pos = Offset(
            e.basePos.dx + sin(_time * 0.4 + e.phase) * 15,
            e.pos.dy - 18 * _lastDt,
          );
          if (e.pos.dy < _waterY + 20) {
            e.pos = Offset(e.pos.dx, _floorY - 30);
            e.basePos = e.pos;
          }
          break;

        case OceanEntityType.octopus:
          // Sube y baja suavemente en el fondo
          e.pos = Offset(
            e.basePos.dx + sin(_time * 0.3 + e.phase) * 20,
            e.basePos.dy + sin(_time * 0.5 + e.phase) * 40,
          );
          break;
      }
    }

    // Limpiar entidades muertas (límite de acumulación)
    _entities.removeWhere((e) => !e.alive);
  }

  // ── Burbujas ───────────────────────────────────────────────────────────────
  void _updateBubbles() {
    for (final b in _bubbles) {
      b.y -= b.speed * _lastDt;
      if (b.y < _waterY) {
        b.y = _floorY - _rng.nextDouble() * 80;
        b.x = 20 + _rng.nextDouble() * (_screenW - 40);
      }
    }
  }

  void _spawnInitialBubbles() {
    for (int i = 0; i < 12; i++) {
      _bubbles.add(_Bubble(
        x: 20 + _rng.nextDouble() * 320,
        y: 200 + _rng.nextDouble() * 400,
        size: 3 + _rng.nextDouble() * 5,
        speed: 20 + _rng.nextDouble() * 30,
      ));
    }
  }

  // ── Feedback flotante ──────────────────────────────────────────────────────
  void _updateFeedbacks() {
    for (final f in _feedbacks) {
      f.dy += 50 * _lastDt;
      f.opacity = (1.0 - f.dy / 60).clamp(0, 1);
    }
    _feedbacks.removeWhere((f) => f.opacity <= 0);
  }

  // ── Flash de pantalla ──────────────────────────────────────────────────────
  void _triggerFlash(Color color) {
    _flashColor = color;
    _flashOpacity = 0.35;
  }

  void _updateFlash() {
    if (_flashOpacity > 0) {
      _flashOpacity -= _lastDt * 2;
      if (_flashOpacity < 0) _flashOpacity = 0;
    }
  }

  // ── Spawn de entidades ─────────────────────────────────────────────────────
  void _spawnEntities() {
    final livingEntities = _entities.length;

    // Basura
    if (_time >= _nextTrashSpawn && livingEntities < 15) {
      _spawnTrash();
      _nextTrashSpawn = _time + 2.5 + _rng.nextDouble() * 1.5;
    }

    // Pez azul
    if (_time >= _nextFishSpawn && livingEntities < 15) {
      _spawnFish(OceanEntityType.fishBlue);
      _nextFishSpawn = _time + 3.5 + _rng.nextDouble() * 2.0;
    }

    // Pez dorado (raro)
    if (_time >= _nextGoldFishSpawn) {
      _spawnFish(OceanEntityType.fishGold);
      _nextGoldFishSpawn = _time + 14 + _rng.nextDouble() * 6.0;
    }

    // Medusa
    if (_time >= _nextJellySpawn && livingEntities < 15) {
      _spawnJellyfish();
      _nextJellySpawn = _time + 8 + _rng.nextDouble() * 4.0;
    }

    // Pulpo (muy raro)
    if (_time >= _nextOctopusSpawn) {
      _spawnOctopus();
      _nextOctopusSpawn = _time + 25 + _rng.nextDouble() * 10.0;
    }
  }

  void _spawnTrash() {
    final types = [OceanEntityType.trashBottle, OceanEntityType.trashBag, OceanEntityType.trashCan, OceanEntityType.trashShoe];
    final type = types[_rng.nextInt(types.length)];
    final x = 30.0 + _rng.nextDouble() * (_screenW - 60);
    final y = _waterY + 40 + _rng.nextDouble() * (_floorY - _waterY - 120);
    _entities.add(OceanEntity(
      id: _nextEntityId++, type: type,
      pos: Offset(x, y), speedX: 0, phase: _rng.nextDouble() * 2 * pi,
    ));
  }

  void _spawnFish(OceanEntityType type) {
    final fromLeft = _rng.nextBool();
    final x = fromLeft ? -20.0 : _screenW + 20.0;
    final y = _waterY + 40 + _rng.nextDouble() * (_floorY - _waterY - 160);
    final speed = (type == OceanEntityType.fishGold ? 70 : 50) + _rng.nextDouble() * 30;
    _entities.add(OceanEntity(
      id: _nextEntityId++, type: type,
      pos: Offset(x, y),
      speedX: fromLeft ? speed : -speed,
      facingRight: fromLeft,
      phase: _rng.nextDouble() * 2 * pi,
    ));
  }

  void _spawnJellyfish() {
    final x = 30.0 + _rng.nextDouble() * (_screenW - 60);
    _entities.add(OceanEntity(
      id: _nextEntityId++, type: OceanEntityType.jellyfish,
      pos: Offset(x, _floorY - 40),
      speedX: 0, phase: _rng.nextDouble() * 2 * pi,
    ));
  }

  void _spawnOctopus() {
    final x = 30.0 + _rng.nextDouble() * (_screenW - 60);
    _entities.add(OceanEntity(
      id: _nextEntityId++, type: OceanEntityType.octopus,
      pos: Offset(x, _floorY - 60),
      speedX: 0, phase: _rng.nextDouble() * 2 * pi,
    ));
  }

  // ── Interacción del jugador ────────────────────────────────────────────────
  void _onTap() {
    if (_gameOver) return;
    if (!_gameStarted) {
      setState(() => _gameStarted = true);
      return;
    }
    if (_hookState == HookState.idle) {
      setState(() {
        _hookY = _boatY;
        _hookState = HookState.casting;
      });
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showExitDialog(context);
        if (shouldExit && context.mounted) widget.onBack();
      },
      child: Scaffold(
        backgroundColor: oceanDeep,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _screenW = constraints.maxWidth;
              _screenH = constraints.maxHeight;

              return Stack(
                children: [
                  // ── Fondo oceánico ────────────────────────────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: OceanBackgroundPainter(time: _time, waterY: 0.22),
                    ),
                  ),

                  // ── Entidades ─────────────────────────────────────────────
                  ..._entities.where((e) => e.alive).map((e) => _buildEntity(e)),

                  // ── Burbujas ──────────────────────────────────────────────
                  ..._bubbles.map((b) => Positioned(
                    left: b.x - b.size / 2,
                    top: b.y - b.size / 2,
                    child: CustomPaint(
                      size: Size(b.size, b.size),
                      painter: BubblePainter(opacity: 0.5 + sin(_time * 2 + b.x) * 0.2),
                    ),
                  )),

                  // ── Barca + Línea + Gancho ────────────────────────────────
                  if (_gameStarted)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BoatAndHookPainter(
                          boatX: _boatX,
                          boatY: _boatY,
                          hookY: _hookState == HookState.idle ? _boatY - 15 : _hookY,
                          time: _time,
                          hasItem: _caughtEntity != null,
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BoatAndHookPainter(
                          boatX: _boatX,
                          boatY: _boatY,
                          hookY: _boatY - 15,
                          time: _time,
                        ),
                      ),
                    ),

                  // ── Flash de pantalla ─────────────────────────────────────
                  if (_flashOpacity > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: (_flashColor ?? Colors.red).withAlpha((_flashOpacity * 255).toInt()),
                        ),
                      ),
                    ),

                  // ── Feedback flotante ─────────────────────────────────────
                  ..._feedbacks.map((f) => Positioned(
                    left: f.pos.dx - 50,
                    top: f.pos.dy - f.dy,
                    child: Opacity(
                      opacity: f.opacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: f.color.withAlpha(200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(f.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                  )),

                  // ── HUD ───────────────────────────────────────────────────
                  if (_gameStarted && !_gameOver)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: _buildHud(),
                    ),

                  // ── Pantalla de inicio ─────────────────────────────────────
                  if (!_gameStarted)
                    Positioned.fill(child: _buildStartScreen()),

                  // ── Game Over ─────────────────────────────────────────────
                  if (_gameOver)
                    Positioned.fill(child: _buildGameOver()),

                  // ── Área táctil ───────────────────────────────────────────
                  if (!_gameOver)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _onTap,
                        behavior: HitTestBehavior.translucent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEntity(OceanEntity e) {
    final s = e.size;
    Widget painter;

    switch (e.type) {
      case OceanEntityType.fishBlue:
        painter = CustomPaint(
          size: s,
          painter: FishPainter(bodyColor: fishBlueLight, accentColor: fishBlueDark, facingRight: e.facingRight),
        );
        break;
      case OceanEntityType.fishGold:
        painter = Stack(children: [
          CustomPaint(size: s, painter: FishPainter(bodyColor: fishGoldLight, accentColor: fishGoldDark, facingRight: e.facingRight)),
          // Destellos dorados
          ...List.generate(3, (i) => Positioned(
            left: s.width * (0.3 + i * 0.2) + sin(_time * 3 + i) * 4,
            top: s.height * 0.2 + cos(_time * 2 + i) * 4,
            child: Container(width: 4, height: 4, decoration: BoxDecoration(color: const Color(0xFFFFD600).withAlpha(200), shape: BoxShape.circle)),
          )),
        ]);
        break;
      case OceanEntityType.jellyfish:
        painter = CustomPaint(size: s, painter: JellyfishPainter(time: _time, pulse: (sin(_time * 2 + e.phase) + 1) / 2));
        break;
      case OceanEntityType.octopus:
        painter = CustomPaint(size: s, painter: OctopusPainter(time: _time));
        break;
      case OceanEntityType.trashBottle:
        painter = CustomPaint(size: s, painter: TrashPainter(type: TrashType.bottle));
        break;
      case OceanEntityType.trashBag:
        painter = CustomPaint(size: s, painter: TrashPainter(type: TrashType.bag));
        break;
      case OceanEntityType.trashCan:
        painter = CustomPaint(size: s, painter: TrashPainter(type: TrashType.can));
        break;
      case OceanEntityType.trashShoe:
        painter = CustomPaint(size: s, painter: TrashPainter(type: TrashType.shoe));
        break;
    }

    return Positioned(
      left: e.pos.dx - s.width / 2,
      top: e.pos.dy - s.height / 2,
      child: SizedBox(width: s.width, height: s.height, child: painter),
    );
  }

  Widget _buildHud() {
    final timeUrgent = _timeLeft <= 10;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cerrar
          GestureDetector(
            onTap: () async {
              _ticker.stop();
              final shouldExit = await showExitDialog(context);
              if (shouldExit && mounted) {
                widget.onBack();
              } else if (mounted) {
                _ticker.start();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),

          // Timer
          AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: timeUrgent ? Colors.red.withAlpha(200) : Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: timeUrgent ? Colors.red : Colors.white24, width: 1.5),
            ),
            child: Text(
              '⏱ $_timeLeft s',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                shadows: timeUrgent ? [const Shadow(color: Colors.red, blurRadius: 8)] : [],
              ),
            ),
          ),

          // Stats
          Row(
            children: [
              _HudPill('🗑️ $_trashCaught'),
              const SizedBox(width: 6),
              _HudPill('⚡ $_xpEarned'),
              const SizedBox(width: 6),
              _HudPill('🪙 $_coinsEarned'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌊', style: TextStyle(fontSize: 60))
                .animate().scale(begin: const Offset(0.7, 0.7), duration: 800.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text(
              'Mar Limpio',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Limpia el océano de basura\ny cuida la fauna marina',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _InfoCard(icon: '🗑️', text: 'Basura = +10 XP +5⏱'),
            _InfoCard(icon: '🐡', text: 'Pez dorado = +10 🪙'),
            _InfoCard(icon: '🐟', text: 'Pez azul = +15 XP'),
            _InfoCard(icon: '🪼', text: 'Medusa = -3⏱ ¡Cuidado!'),
            _InfoCard(icon: '🐙', text: 'Pulpo = +20 XP (raro)'),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0096C7), Color(0xFF023E8A)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: const Color(0xFF0096C7).withAlpha(100), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: const Text('🎣 ¡Empezar!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ).animate().scale(begin: const Offset(0.9, 0.9), duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onBack,
              child: const Text('← Volver', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final won = _trashCaught >= 3;
    return Container(
      color: Colors.black.withAlpha(178),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF023E8A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: oceanShallow, width: 2.5),
            boxShadow: [BoxShadow(color: oceanMid.withAlpha(80), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(won ? '🏆' : '🌊', style: const TextStyle(fontSize: 56))
                  .animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text(
                won ? '¡Océano más limpio!' : 'El tiempo terminó',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Recolectaste $_trashCaught piezas de basura',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Stats
              _StatRow(icon: '🗑️', label: 'Basura recolectada', value: '$_trashCaught'),
              _StatRow(icon: '⚡', label: 'XP ganado', value: '+$_xpEarned'),
              _StatRow(icon: '🪙', label: 'Monedas', value: '+$_coinsEarned'),

              const SizedBox(height: 20),

              if (won) ...[
                GameCompleteBanner(
                  won: true,
                  titleWon: '🌊 ¡Limpieza exitosa!',
                  chips: [
                    ('+$_xpEarned XP', HabitikColors.amber400),
                    if (_coinsEarned > 0) ('+$_coinsEarned 🪙', HabitikColors.amber300),
                  ],
                ),
                const SizedBox(height: 12),
                GameActionButton(
                  label: 'Reclamar Recompensa',
                  gradient: HabitikColors.xpGold,
                  onTap: widget.onComplete,
                ),
              ] else ...[
                const Text(
                  '¡Necesitas atrapar al menos 3 basuras!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                GameActionButton(
                  label: '🔄 Intentar de nuevo',
                  gradient: const LinearGradient(colors: [Color(0xFF0096C7), Color(0xFF023E8A)]),
                  onTap: () => setState(() {
                    _gameOver = false;
                    _gameStarted = false;
                    _time = 0;
                    _timeLeft = 30;
                    _trashCaught = 0;
                    _xpEarned = 0;
                    _coinsEarned = 0;
                    _entities.clear();
                    _feedbacks.clear();
                    _hookState = HookState.idle;
                    _hookY = _waterY + 20;
                    _caughtEntity = null;
                    _flashOpacity = 0;
                    _nextTrashSpawn = 2;
                    _nextFishSpawn = 3;
                    _nextJellySpawn = 7;
                    _nextOctopusSpawn = 20;
                    _nextGoldFishSpawn = 15;
                    _timeSinceLastSecond = 0;
                  }),
                ),
                const SizedBox(height: 8),
                GameActionButton(
                  label: 'Volver',
                  gradient: const LinearGradient(colors: [Color(0xFF455A64), Color(0xFF263238)]),
                  onTap: widget.onBack,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers locales
// ─────────────────────────────────────────────────────────────────────────────

class _Bubble {
  double x, y, size, speed;
  _Bubble({required this.x, required this.y, required this.size, required this.speed});
}

class _HudPill extends StatelessWidget {
  final String text;
  const _HudPill(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
  );
}

class _InfoCard extends StatelessWidget {
  final String icon, text;
  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _StatRow extends StatelessWidget {
  final String icon, label, value;
  const _StatRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    ),
  );
}