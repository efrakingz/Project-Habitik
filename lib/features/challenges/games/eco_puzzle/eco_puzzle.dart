import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'game/eco_puzzle_game.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/start_overlay.dart';
import 'widgets/victory_overlay.dart';
import 'widgets/failure_overlay.dart';

class EcoPuzzleScreen extends StatefulWidget {
  final VoidCallback? onChallengeCompleted;

  const EcoPuzzleScreen({super.key, this.onChallengeCompleted});

  @override
  State<EcoPuzzleScreen> createState() => _EcoPuzzleScreenState();
}

class _EcoPuzzleScreenState extends State<EcoPuzzleScreen> {
  late final EcoPuzzleGame _game;

  @override
  void initState() {
    super.initState();
    _game = EcoPuzzleGame(
      onGameClosed: () {
        Navigator.maybePop(context);
      },
      onChallengeCompleted: () {
        widget.onChallengeCompleted?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameWidget(
          game: _game,
          overlayBuilderMap: {
            'HUD': (context, EcoPuzzleGame game) => HudOverlay(game: game),
            'Start': (context, EcoPuzzleGame game) => StartOverlay(game: game),
            'Victory': (context, EcoPuzzleGame game) => VictoryOverlay(game: game),
            'Failure': (context, EcoPuzzleGame game) => FailureOverlay(game: game),
          },
          initialActiveOverlays: const ['Start'],
        ),
      ),
    );
  }
}
