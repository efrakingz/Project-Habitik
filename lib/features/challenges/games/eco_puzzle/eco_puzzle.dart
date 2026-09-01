import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'game/eco_puzzle_game.dart';
import 'game/models/eco_puzzle_state.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/start_overlay.dart';
import 'widgets/loading_overlay.dart';
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
      backgroundColor: const Color(0xFFE8F8F5),
      body: SafeArea(
        child: GameWidget<EcoPuzzleGame>(
          game: _game,
          overlayBuilderMap: {
            EcoPuzzleState.loading.name: (context, game) => LoadingOverlay(game: game),
            EcoPuzzleState.start.name: (context, game) => StartOverlay(game: game),
            EcoPuzzleState.playing.name: (context, game) => HudOverlay(game: game),
            EcoPuzzleState.success.name: (context, game) => VictoryOverlay(game: game),
            EcoPuzzleState.failure.name: (context, game) => FailureOverlay(game: game),
          },
        ),
      ),
    );
  }
}
