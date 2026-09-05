import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'models/eco_puzzle_state.dart';
import 'components/recycle_bin.dart';
import 'components/trash_item.dart';
import 'components/eco_background_component.dart';

class EcoPuzzleGame extends FlameGame with HasCollisionDetection {
  final VoidCallback? onGameClosed;
  final VoidCallback? onChallengeCompleted;

  EcoPuzzleState _gameState = EcoPuzzleState.loading;
  final ValueNotifier<EcoPuzzleState> gameStateNotifier = ValueNotifier(EcoPuzzleState.loading);

  EcoPuzzleState get gameState => _gameState;
  set gameState(EcoPuzzleState newState) {
    if (_gameState == newState) return;
    final oldState = _gameState;
    _gameState = newState;
    gameStateNotifier.value = newState;

    // Sincronizar automáticamente los overlays de Flame
    overlays.remove(oldState.name);
    overlays.add(newState.name);
  }

  int errors = 0;
  int correctlyClassified = 0;
  double timeLeft = 59.0;
  final int maxErrors = 3;
  final int itemsToClassify = 10;

  EcoPuzzleGame({
    this.onGameClosed,
    this.onChallengeCompleted,
  });

  @override
  Color backgroundColor() => const Color(0xFFE8F8F5); // Fondo natural claro

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Añadir fondo ilustrado y texturizado con partículas ambientales
    add(EcoBackgroundComponent());

    // Mostrar overlay de carga
    overlays.add(EcoPuzzleState.loading.name);

    // Transición suave de carga hacia la pantalla de inicio con reglas (2.4s)
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (gameState == EcoPuzzleState.loading) {
        gameState = EcoPuzzleState.start;
      }
    });
  }

  void startGame() {
    errors = 0;
    correctlyClassified = 0;
    timeLeft = 59.0;
    
    // Limpiar componentes de partidas anteriores
    removeAll(children.where((c) => c is RecycleBin || c is TrashItem));

    _spawnBins();
    _spawnTrashItems();

    // Cambiar estado a jugando (activa HUD automáticamente)
    gameState = EcoPuzzleState.playing;
  }

  void _spawnBins() {
    final binWidth = size.x / 3.4;
    final spacing = (size.x - (binWidth * 3)) / 4;
    final binY = size.y - 130; // Posición inferior óptima para interacción táctil

    // Orgánico (Verde)
    add(RecycleBin(
      type: BinType.organic,
      position: Vector2(spacing + binWidth / 2, binY),
      size: Vector2(binWidth, 120),
    ));

    // Reciclable (Amarillo/Ámbar)
    add(RecycleBin(
      type: BinType.recyclable,
      position: Vector2(spacing * 2 + binWidth * 1.5, binY),
      size: Vector2(binWidth, 120),
    ));

    // Inorgánico (Gris/Cian)
    add(RecycleBin(
      type: BinType.inorganic,
      position: Vector2(spacing * 3 + binWidth * 2.5, binY),
      size: Vector2(binWidth, 120),
    ));
  }

  void _spawnTrashItems() {
    final random = Random();

    final organicItems = ['🍎', '🍌', '🍉', '🥑', '🥕', '🥦'];
    final recyclableItems = ['🍾', '🥫', '📦', '📰', '🧃'];
    final inorganicItems = ['🔋', '💡', '🛍️', '🧴', '🧻'];

    final allTrashToSpawn = <TrashItem>[];

    for (int i = 0; i < itemsToClassify; i++) {
      final typeChoice = random.nextInt(3);
      BinType type;
      String emoji;

      if (typeChoice == 0) {
        type = BinType.organic;
        emoji = organicItems[random.nextInt(organicItems.length)];
      } else if (typeChoice == 1) {
        type = BinType.recyclable;
        emoji = recyclableItems[random.nextInt(recyclableItems.length)];
      } else {
        type = BinType.inorganic;
        emoji = inorganicItems[random.nextInt(inorganicItems.length)];
      }

      final padding = 45.0;
      final rx = padding + random.nextDouble() * (size.x - padding * 2);
      final ry = padding * 1.8 + random.nextDouble() * (size.y * 0.44 - padding);

      allTrashToSpawn.add(TrashItem(
        targetType: type,
        emoji: emoji,
        targetPosition: Vector2(rx, ry),
        dropDelay: i * 0.15, // Descenso escalonado y fluido
      ));
    }

    addAll(allTrashToSpawn);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameState == EcoPuzzleState.playing) {
      timeLeft -= dt;
      
      if (timeLeft <= 0) {
        timeLeft = 0;
        _setGameOver(false);
      }
    }
  }

  void onTrashDropped(TrashItem item, RecycleBin? bin) {
    if (bin == null) {
      item.returnToStart();
      return;
    }

    if (bin.type == item.targetType) {
      // Acierto
      correctlyClassified++;
      item.poofAndRemove(Vector2(bin.position.x, bin.position.y - bin.size.y * 0.35));
      bin.flashGreen();
      
      if (correctlyClassified >= itemsToClassify) {
        _setGameOver(true);
      }
    } else {
      // Error
      errors++;
      item.returnToStart();
      bin.flashRed();
      
      if (errors >= maxErrors) {
        _setGameOver(false);
      }
    }
  }

  void _setGameOver(bool isWin) {
    gameState = isWin ? EcoPuzzleState.success : EcoPuzzleState.failure;
  }

  void retry() {
    startGame();
  }

  void completeChallenge() {
    onChallengeCompleted?.call();
    onGameClosed?.call();
  }

  void closeGame() {
    onGameClosed?.call();
  }
}
