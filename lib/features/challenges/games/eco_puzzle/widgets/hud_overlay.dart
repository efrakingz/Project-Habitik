import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import '../game/eco_puzzle_game.dart';
import '../game/models/eco_puzzle_state.dart';

class HudOverlay extends StatefulWidget {
  final EcoPuzzleGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late final Timer _rebuildTimer;

  @override
  void initState() {
    super.initState();
    // Rebuild the UI 10 times a second to keep the timer smooth
    _rebuildTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _rebuildTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcoPuzzleState>(
      valueListenable: widget.game.gameStateNotifier,
      builder: (context, _, __) {
        if (widget.game.gameState != EcoPuzzleState.playing) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: HabitikColors.green600),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.game.timeLeft.ceil()}s',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: HabitikColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Error counter (Hearts)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: List.generate(widget.game.maxErrors, (index) {
                    return Icon(
                      index < (widget.game.maxErrors - widget.game.errors)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 28,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
