import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'models/eco_puzzle_state.dart';
import 'components/recycle_bin.dart';
import 'components/trash_item.dart';

class EcoPuzzleGame extends FlameGame with HasCollisionDetection {
  final VoidCallback? onGameClosed;
  final VoidCallback? onChallengeCompleted;

  final ValueNotifier<EcoPuzzleState> gameStateNotifier = ValueNotifier(EcoPuzzleState.start);

  EcoPuzzleState get gameState => gameStateNotifier.value;
  set gameState(EcoPuzzleState state) => gameStateNotifier.value = state;

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
  Color backgroundColor() => const Color(0xFFF1F8E9); // Habitik green bg

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Bins and items will be spawned when state changes to playing.
  }

  void startGame() {
    gameState = EcoPuzzleState.playing;
    errors = 0;
    correctlyClassified = 0;
    timeLeft = 59.0;
    
    // Clear old components if any
    removeAll(children.where((c) => c is RecycleBin || c is TrashItem));

    _spawnBins();
    _spawnTrashItems();
  }

  void _spawnBins() {
    final binWidth = size.x / 3.5;
    final spacing = (size.x - (binWidth * 3)) / 4;
    final binY = size.y - 120; // Bottom of the screen

    // Draw Conveyor Belt
    add(RectangleComponent(
      position: Vector2(0, binY + 50),
      size: Vector2(size.x, 70),
      paint: Paint()..color = const Color(0xFF212121), // beltDark
    ));
    add(RectangleComponent(
      position: Vector2(0, binY + 60),
      size: Vector2(size.x, 10),
      paint: Paint()..color = const Color(0xFFFFD54F), // beltYellowStripe
    ));

    // Orgánico (Verde)
    add(RecycleBin(
      type: BinType.organic,
      position: Vector2(spacing + binWidth / 2, binY),
      size: Vector2(binWidth, 100),
    ));

    // Reciclable (Amarillo/Azul)
    add(RecycleBin(
      type: BinType.recyclable,
      position: Vector2(spacing * 2 + binWidth * 1.5, binY),
      size: Vector2(binWidth, 100),
    ));

    // Inorgánico (Gris)
    add(RecycleBin(
      type: BinType.inorganic,
      position: Vector2(spacing * 3 + binWidth * 2.5, binY),
      size: Vector2(binWidth, 100),
    ));
  }

  void _spawnTrashItems() {
    final random = Random();
    
    // Lista de emojis
    final organicEmojis = ['🍎', '🍌', '🍉', '🥦'];
    final recyclableEmojis = ['📰', '📦', '🍾', '🥫'];
    final inorganicEmojis = ['🔋', '💡', '🧻', '🛍️'];

    final allTrashToSpawn = <TrashItem>[];

    // Pick a mix of 10 items
    for (int i = 0; i < itemsToClassify; i++) {
      final typeChoice = random.nextInt(3);
      BinType type;
      String emoji;
      
      if (typeChoice == 0) {
        type = BinType.organic;
        emoji = organicEmojis[random.nextInt(organicEmojis.length)];
      } else if (typeChoice == 1) {
        type = BinType.recyclable;
        emoji = recyclableEmojis[random.nextInt(recyclableEmojis.length)];
      } else {
        type = BinType.inorganic;
        emoji = inorganicEmojis[random.nextInt(inorganicEmojis.length)];
      }

      // Random position in the upper half of the screen
      final padding = 40.0;
      final rx = padding + random.nextDouble() * (size.x - padding * 2);
      final ry = padding * 2 + random.nextDouble() * (size.y / 2 - padding);

      allTrashToSpawn.add(TrashItem(
        targetType: type,
        emoji: emoji,
        initialPosition: Vector2(rx, ry),
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
      // Correct!
      correctlyClassified++;
      item.poofAndRemove();
      bin.flashGreen();
      
      if (correctlyClassified >= itemsToClassify) {
        _setGameOver(true);
      }
    } else {
      // Incorrect
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
    overlays.remove('HUD');
    if (isWin) {
      overlays.add('Victory');
    } else {
      overlays.add('Failure');
    }
  }

  void retry() {
    overlays.remove('Failure');
    overlays.add('HUD');
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
