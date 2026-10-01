import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/modals/confirm_dialog.dart';
import 'models/trivia_question.dart';
import 'trivia_controller.dart';
import 'widgets/trivia_header.dart';
import 'widgets/trivia_start_overlay.dart';
import 'widgets/trivia_loading_overlay.dart';
import 'widgets/answer_option.dart';
import 'widgets/answer_feedback.dart';
import 'widgets/extra_life_dialog.dart';
import 'widgets/trivia_result.dart';

class TriviaScreen extends StatefulWidget {
  final VoidCallback? onChallengeCompleted;
  final void Function(bool)? onGameModeChanged;
  final TriviaController? controller;
  final bool initialLoading;
  final Duration? loadingDuration;

  const TriviaScreen({
    super.key,
    this.onChallengeCompleted,
    this.onGameModeChanged,
    this.controller,
    this.initialLoading = true,
    this.loadingDuration,
  });

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  late final TriviaController _controller;
  bool _isLocalController = false;
  late bool _isLoading;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.initialLoading;
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TriviaController();
      _isLocalController = true;
    }

    _controller.addListener(_onControllerUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onGameModeChanged?.call(true);
      }
    });
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (_isLocalController) {
      _controller.dispose();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onGameModeChanged?.call(false);
    });
    super.dispose();
  }

  Future<void> _handleExit() async {
    if (!_hasStarted || _controller.state == TriviaState.finished) {
      Navigator.of(context).pop();
      return;
    }

    final confirm = await HabitikConfirmDialog.show(
      context,
      title: '¿Salir de la Trivia?',
      description:
          'Se guardará tu progreso acumulado de esta partida y se finalizará tu participación.',
      confirmLabel: 'SÍ, SALIR',
      cancelLabel: 'SEGUIR JUGANDO',
      icon: Icons.exit_to_app_rounded,
      isDestructive: true,
    );

    if (confirm && mounted) {
      await _controller.finishGame();
      if (mounted) {
        // Al salir o abandonar la partida antes de completarla, no se marca el desafío como completado
        Navigator.of(context).pop();
      }
    }
  }

  void _startGame() {
    setState(() {
      _hasStarted = true;
    });
    _controller.initGame();
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'energia':
        return '⚡';
      case 'agua':
        return '💧';
      case 'reciclaje':
        return '♻️';
      case 'biodiversidad':
        return '🐾';
      case 'consumo':
      case 'consumo_responsable':
        return '🌱';
      default:
        return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleExit();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6FC),
        body: Stack(
          children: [
            // Pantalla previa de carga
            if (_isLoading)
              TriviaLoadingOverlay(
                loadingDuration: widget.loadingDuration ?? const Duration(milliseconds: 2200),
                onLoadingComplete: () {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              )
            // Pantalla previa si no ha comenzado
            else if (!_hasStarted)
              TriviaStartOverlay(
                onStart: _startGame,
                onExit: () => Navigator.of(context).pop(),
              )
            else
              _buildActiveGame(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGame(BuildContext context) {
    // Si la partida finalizó, mostrar vista de resultados
    if (_controller.state == TriviaState.finished &&
        _controller.finalResult != null) {
      return TriviaResultView(
        result: _controller.finalResult!,
        onClose: () {
          final res = _controller.finalResult!;
          if (res.correctCount > 0 || res.xpEarned > 0) {
            widget.onChallengeCompleted?.call();
          }
          Navigator.of(context).pop();
        },
      );
    }

    return Column(
      children: [
        // Cabecera superior
        TriviaHeader(
          lives: _controller.lives,
          remainingSeconds: _controller.remainingSeconds,
          correctCount: _controller.correctCount,
          accumulatedXp: _controller.accumulatedXp,
          onExit: _handleExit,
        ),

        // Cuerpo principal
        Expanded(
          child: Stack(
            children: [
              if (_controller.state == TriviaState.loading)
                _buildLoadingState()
              else if (_controller.state == TriviaState.error)
                _buildErrorState()
              else if (_controller.currentQuestion != null)
                _buildQuestionView(_controller.currentQuestion!)
              else
                _buildLoadingState(),

              // Modal de sin vidas
              if (_controller.state == TriviaState.outOfLives)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: ExtraLifeDialog(
                    onBuyLife: () => _controller.buyExtraLife(),
                    onFinish: () => _controller.finishGame(),
                  ),
                ),

              // Banner de feedback inferior
              if (_controller.state == TriviaState.feedback &&
                  _controller.lastAnswerResult != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnswerFeedbackBanner(
                    result: _controller.lastAnswerResult!,
                    onContinue: _controller.onContinueAfterFeedback,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionView(TriviaQuestion question) {
    final category = question.category;
    final emoji = _getCategoryEmoji(category);
    final categoryLabel = category.toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tags de categoría y dificultad
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE1BEE7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      categoryLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B1FA2),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  question.difficulty.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tarjeta de la pregunta
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEDE7F6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF263238),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4 Opciones de respuesta
          for (int i = 0; i < question.options.length; i++) ...[
            AnswerOption(
              index: i,
              text: question.options[i],
              state: _resolveOptionState(i),
              isDisabled:
                  _controller.isSubmitting ||
                  _controller.state != TriviaState.question,
              onTap: () => _controller.submitAnswer(i),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  AnswerOptionState _resolveOptionState(int index) {
    if (_controller.state == TriviaState.feedback &&
        _controller.lastAnswerResult != null) {
      final res = _controller.lastAnswerResult!;
      if (index == res.correctOption) {
        return AnswerOptionState.correct;
      }
      if (index == _controller.selectedOptionIndex && !res.isCorrect) {
        return AnswerOptionState.incorrect;
      }
      return AnswerOptionState.dimmed;
    }

    if (_controller.state == TriviaState.submitting) {
      if (index == _controller.selectedOptionIndex) {
        return AnswerOptionState.selected;
      }
      return AnswerOptionState.dimmed;
    }

    return AnswerOptionState.defaultState;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando pregunta ecológica...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B1FA2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 14),
            Text(
              _controller.errorMessage ??
                  'Ocurrió un error inesperado al conectar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _controller.retry(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('REINTENTAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
