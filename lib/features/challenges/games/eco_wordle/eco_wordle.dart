import 'package:flutter/material.dart';
import 'game/eco_wordle_controller.dart';
import 'models/eco_wordle_state.dart';
import 'widgets/failure_overlay.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/start_overlay.dart';
import 'widgets/victory_overlay.dart';

/// Pantalla principal y punto de entrada para el minijuego EcoWordle.
/// Diseñada siguiendo la arquitectura y estándares de Clean Code de Habitik.
class EcoWordleScreen extends StatefulWidget {
  final VoidCallback? onChallengeCompleted;
  final VoidCallback? onChallengeAlreadyCompleted;

  const EcoWordleScreen({
    super.key, 
    this.onChallengeCompleted,
    this.onChallengeAlreadyCompleted,
  });

  @override
  State<EcoWordleScreen> createState() => _EcoWordleScreenState();
}

class _EcoWordleScreenState extends State<EcoWordleScreen> {
  late final EcoWordleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EcoWordleController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.init(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeGame() {
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B492E), Color(0xFF255B3A), Color(0xFF183D26)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final isPlaying = _controller.gameState == EcoWordleState.playing ||
                _controller.gameState == EcoWordleState.success ||
                _controller.gameState == EcoWordleState.alreadyWon ||
                _controller.gameState == EcoWordleState.failure;

            return Stack(
              children: [
                // ── Capa Base: HUD de Juego Activo (solo visible al jugar o mostrar resultados) ──
                if (isPlaying)
                  EcoWordleHudOverlay(
                    controller: _controller,
                    onClose: _closeGame,
                    onChallengeCompleted: widget.onChallengeCompleted,
                  ),

                // ── Overlays según Estado ──
                if (_controller.gameState == EcoWordleState.loading)
                  WordleLoadingOverlay(
                    onLoadingComplete: _controller.onLoadingComplete,
                    onClose: _closeGame,
                  ),

                if (_controller.gameState == EcoWordleState.start)
                  WordleStartOverlay(
                    largoPalabra: _controller.largoPalabra,
                    maxIntentos: _controller.maxIntentos,
                    intentosPrevios: _controller.attempts.length,
                    onStart: _controller.onStartGame,
                    onClose: _closeGame,
                  ),

                if (_controller.gameState == EcoWordleState.success || _controller.gameState == EcoWordleState.alreadyWon)
                  Positioned.fill(
                    child: WordleVictoryOverlay(
                      intentosUsados: _controller.attempts.length,
                      maxIntentos: _controller.maxIntentos,
                      pistaEducativa: _controller.pistaEducativa,
                      recompensas: _controller.recompensas,
                      isReentry: _controller.gameState == EcoWordleState.alreadyWon,
                      onContinue: () {
                        widget.onChallengeCompleted?.call();
                        _closeGame();
                      },
                      onClose: () {
                        if (_controller.gameState == EcoWordleState.alreadyWon) {
                          widget.onChallengeAlreadyCompleted?.call();
                        }
                        _closeGame();
                      },
                    ),
                  ),

                if (_controller.gameState == EcoWordleState.failure)
                  Positioned.fill(
                    child: WordleFailureOverlay(
                      intentosUsados: _controller.attempts.length,
                      maxIntentos: _controller.maxIntentos,
                      pistaEducativa: _controller.pistaEducativa,
                      palabraCorrecta: _controller.palabraCorrecta,
                      onClose: _closeGame,
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
}
