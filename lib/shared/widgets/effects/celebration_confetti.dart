import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Componente modular y reutilizable para celebrar victorias y recompensas con confeti.
///
/// Modos de uso:
/// 1. Declarativo (Drop-in):
///    ```dart
///    const CelebrationConfetti() // Se reproduce automáticamente al montarse
///    ```
/// 2. Con controlador personalizado:
///    ```dart
///    CelebrationConfetti(controller: _miController)
///    ```
/// 3. Programático estático (sin tocar el árbol de widgets):
///    ```dart
///    CelebrationConfetti.show(context);
///    ```
class CelebrationConfetti extends StatefulWidget {
  final ConfettiController? controller;
  final bool autoPlay;
  final Duration duration;
  final Alignment alignment;
  final int numberOfParticles;
  final BlastDirectionality blastDirectionality;
  final List<Color>? colors;

  static const List<Color> defaultColors = [
    Color(0xFF10B981), // Emerald 500
    Color(0xFF059669), // Emerald 600
    Color(0xFF34D399), // Emerald 400
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFFBBF24), // Amber 400
    Color(0xFF00E5FF), // Cyan Accent
    Color(0xFF3B82F6), // Blue 500
    Color(0xFFEC4899), // Pink 500
  ];

  const CelebrationConfetti({
    super.key,
    this.controller,
    this.autoPlay = true,
    this.duration = const Duration(seconds: 4),
    this.alignment = Alignment.topCenter,
    this.numberOfParticles = 30,
    this.blastDirectionality = BlastDirectionality.explosive,
    this.colors,
  });

  /// Muestra una lluvia de confeti flotante sobre la pantalla actual usando el [Overlay].
  static void show(
    BuildContext context, {
    Duration duration = const Duration(seconds: 3),
    List<Color>? colors,
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final controller = ConfettiController(duration: duration);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            child: ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 35,
              gravity: 0.15,
              colors: colors ?? defaultColors,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    controller.play();

    Future.delayed(duration + const Duration(seconds: 1), () {
      controller.dispose();
      entry.remove();
    });
  }

  @override
  State<CelebrationConfetti> createState() => _CelebrationConfettiState();
}

class _CelebrationConfettiState extends State<CelebrationConfetti> {
  ConfettiController? _internalController;

  ConfettiController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = ConfettiController(duration: widget.duration);
      if (widget.autoPlay) {
        _internalController!.play();
      }
    } else if (widget.autoPlay) {
      widget.controller!.play();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: widget.alignment,
        child: RepaintBoundary(
          child: ConfettiWidget(
            confettiController: _effectiveController,
            blastDirectionality: widget.blastDirectionality,
            shouldLoop: false,
            numberOfParticles: widget.numberOfParticles,
            gravity: 0.15,
            colors: widget.colors ?? CelebrationConfetti.defaultColors,
          ),
        ),
      ),
    );
  }
}
