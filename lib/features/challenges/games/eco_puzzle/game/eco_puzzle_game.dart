import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'models/eco_puzzle_state.dart';
import 'models/waste_item.dart';
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

    // Transición suave de carga hacia la pantalla de inicio con reglas (2.2s)
    Future.delayed(const Duration(milliseconds: 2200), () {
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
    final binWidth = math.min(size.x / 3.4, 115.0);
    final spacing = (size.x - (binWidth * 3)) / 4;
    final binHeight = math.min(125.0, size.y * 0.22);
    final binY = size.y - (binHeight / 2) - 18.0;

    // Orgánico (Verde)
    add(RecycleBin(
      type: BinType.organic,
      position: Vector2(spacing + binWidth / 2, binY),
      size: Vector2(binWidth, binHeight),
    ));

    // Reciclable (Amarillo/Ámbar)
    add(RecycleBin(
      type: BinType.recyclable,
      position: Vector2(spacing * 2 + binWidth * 1.5, binY),
      size: Vector2(binWidth, binHeight),
    ));

    // Inorgánico (Azul)
    add(RecycleBin(
      type: BinType.inorganic,
      position: Vector2(spacing * 3 + binWidth * 2.5, binY),
      size: Vector2(binWidth, binHeight),
    ));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _repositionBins();
  }

  void _repositionBins() {
    final bins = children.whereType<RecycleBin>().toList();
    if (bins.isEmpty) return;

    final binWidth = math.min(size.x / 3.4, 115.0);
    final spacing = (size.x - (binWidth * 3)) / 4;
    final binHeight = math.min(125.0, size.y * 0.22);
    final binY = size.y - (binHeight / 2) - 18.0;

    for (final bin in bins) {
      bin.size = Vector2(binWidth, binHeight);
      switch (bin.type) {
        case BinType.organic:
          bin.position = Vector2(spacing + binWidth / 2, binY);
          break;
        case BinType.recyclable:
          bin.position = Vector2(spacing * 2 + binWidth * 1.5, binY);
          break;
        case BinType.inorganic:
          bin.position = Vector2(spacing * 3 + binWidth * 2.5, binY);
          break;
      }
    }
  }

  void _spawnTrashItems() {
    final random = math.Random();

    // Barajamos todos los residuos con emojis disponibles
    final shuffled = List<WasteItem>.from(WasteItem.allItems)..shuffle(random);
    final selectedItems = shuffled.take(itemsToClassify).toList();

    final allTrashToSpawn = <TrashItem>[];
    final positions = <Vector2>[];

    const minDistance = 76.0; // Distancia mínima para evitar solapamientos
    const padding = 45.0;
    const topOffset = 76.0; // Debajo del HUD superior
    final bottomLimit = math.max(topOffset + 180.0, size.y * 0.50); // Arriba de la cerca
    final availableWidth = size.x - padding * 2;
    final availableHeight = bottomLimit - topOffset;

    for (int i = 0; i < selectedItems.length; i++) {
      final itemDef = selectedItems[i];

      // Búsqueda de posición no superpuesta mediante muestreo de rechazo
      Vector2 bestPos = Vector2(
        padding + ((i % 3) + 0.5) * (availableWidth / 3),
        topOffset + ((i ~/ 3) + 0.5) * (availableHeight / 4),
      );
      double bestMinDist = 0;

      for (int attempt = 0; attempt < 80; attempt++) {
        final rx = padding + random.nextDouble() * availableWidth;
        final ry = topOffset + random.nextDouble() * availableHeight;
        final candidate = Vector2(rx, ry);

        if (positions.isEmpty) {
          bestPos = candidate;
          break;
        }

        double minDist = double.infinity;
        for (final p in positions) {
          final d = p.distanceTo(candidate);
          if (d < minDist) minDist = d;
        }

        if (minDist >= minDistance) {
          bestPos = candidate;
          break;
        }

        if (minDist > bestMinDist) {
          bestMinDist = minDist;
          bestPos = candidate;
        }
      }

      positions.add(bestPos);

      allTrashToSpawn.add(TrashItem(
        targetType: itemDef.targetType,
        emoji: itemDef.emoji,
        targetPosition: bestPos,
        dropDelay: i * 0.11, // Descenso escalonado y fluido
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
