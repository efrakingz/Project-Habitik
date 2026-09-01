import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../eco_puzzle_game.dart';
import '../models/eco_puzzle_state.dart';
import 'recycle_bin.dart';

class TrashItem extends TextComponent with DragCallbacks, HasGameReference<EcoPuzzleGame> {
  final BinType targetType;
  final String emoji;
  final Vector2 initialPosition;
  
  bool isBeingDragged = false;

  TrashItem({
    required this.targetType,
    required this.emoji,
    required this.initialPosition,
  }) : super(
          text: emoji,
          textRenderer: TextPaint(
            style: const TextStyle(fontSize: 48),
          ),
          anchor: Anchor.center,
          position: initialPosition,
          size: Vector2.all(48),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Pop-in animation
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.4, curve: Curves.elasticOut)));
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (game.gameState != EcoPuzzleState.playing) return;
    
    super.onDragStart(event);
    isBeingDragged = true;
    priority = 100; // Bring to front
    // Apply opacity 0.5 per requirements (using alpha in textRenderer)
    textRenderer = TextPaint(
      style: const TextStyle(fontSize: 48, color: Color(0x80FFFFFF)),
    );
    // Slight scale up while dragging
    add(ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1)));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isBeingDragged) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isBeingDragged) return;
    isBeingDragged = false;
    priority = 0;
    
    // Restore opacity and scale
    textRenderer = TextPaint(
      style: const TextStyle(fontSize: 48),
    );
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)));

    // Check collision with any bin
    final bins = game.children.whereType<RecycleBin>();
    RecycleBin? overlappingBin;
    
    for (final bin in bins) {
      if (bin.toRect().overlaps(toRect())) {
        overlappingBin = bin;
        break;
      }
    }

    game.onTrashDropped(this, overlappingBin);
  }

  void returnToStart() {
    // Shake effect for error
    add(MoveEffect.by(Vector2(8, 0), EffectController(duration: 0.05, alternate: true, repeatCount: 3)));
    // Return to start position smoothly
    add(MoveToEffect(initialPosition, EffectController(duration: 0.3, curve: Curves.easeOut)));
  }

  void poofAndRemove() {
    add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.2, curve: Curves.easeInBack)));
    add(RemoveEffect(delay: 0.2));
  }
}
