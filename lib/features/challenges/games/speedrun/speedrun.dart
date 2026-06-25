import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/speedrun_game.dart';
import 'game/models/speedrun_state.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/start_overlay.dart';
import 'widgets/confirmation_overlay.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/victory_overlay.dart';
import 'widgets/failure_overlay.dart';

class SpeedrunScreen extends StatefulWidget {
  final VoidCallback? onChallengeCompleted;
  final void Function(bool)? onGameModeChanged;

  const SpeedrunScreen({
    super.key,
    this.onChallengeCompleted,
    this.onGameModeChanged,
  });

  @override
  State<SpeedrunScreen> createState() => _SpeedrunScreenState();
}

class _SpeedrunScreenState extends State<SpeedrunScreen> {
  late final SpeedrunGame _game;

  @override
  void initState() {
    super.initState();
    // Ocultar la barra de navegación del shell al iniciar el juego
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onGameModeChanged?.call(true);
      }
    });

    _game = SpeedrunGame(
      onGameClosed: () {
        Navigator.maybePop(context);
      },
      onChallengeCompleted: () {
        widget.onChallengeCompleted?.call();
      },
    );
  }

  @override
  void dispose() {
    // Restaurar la barra de navegación al salir del juego de forma segura en el siguiente frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onGameModeChanged?.call(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final state = _game.gameState;
        if (state == SpeedrunState.playing || state == SpeedrunState.preparing) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("¿Seguro quieres salir?"),
              content: const Text("Se perderá tu progreso de la ducha."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Salir"),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2B48),
        body: GameWidget<SpeedrunGame>(
          game: _game,
          overlayBuilderMap: {
            SpeedrunState.loading.name: (context, game) => LoadingOverlay(game: game),
            SpeedrunState.start.name: (context, game) => StartOverlay(game: game),
            SpeedrunState.confirming.name: (context, game) => ConfirmationOverlay(game: game),
            SpeedrunState.preparing.name: (context, game) => HudOverlay(game: game),
            SpeedrunState.playing.name: (context, game) => HudOverlay(game: game),
            SpeedrunState.success.name: (context, game) => VictoryOverlay(game: game),
            SpeedrunState.failure.name: (context, game) => FailureOverlay(game: game),
          },
        ),
      ),
    );
  }
}
