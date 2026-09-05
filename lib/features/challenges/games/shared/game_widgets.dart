import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CircularGameTimer – timer circular animado para el reto de la ducha
// ─────────────────────────────────────────────────────────────────────────────
class CircularGameTimer extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;
  final bool running;
  final Color? color;

  const CircularGameTimer({
    super.key,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.running,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = secondsLeft / totalSeconds;
    final timerColor = pct > 0.5
        ? HabitikColors.green500
        : pct > 0.25
            ? HabitikColors.amber400
            : Colors.redAccent;

    final min = secondsLeft ~/ 60;
    final sec = (secondsLeft % 60).toString().padLeft(2, '0');

    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              color: timerColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
          ),
          // Progress arc
          CustomPaint(
            size: const Size(160, 160),
            painter: _ArcPainter(pct: pct, color: timerColor),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$min:$sec',
                style: TextStyle(
                  color: timerColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito',
                ),
              ).animate(target: running && secondsLeft <= 30 ? 1 : 0)
               .shake(duration: 300.ms, hz: 3),
              if (running)
                Text('⏳', style: const TextStyle(fontSize: 16))
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double pct;
  final Color color;
  _ArcPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final bgPaint = Paint()
      ..color = color.withAlpha(40)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * pct,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.pct != pct || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// WordleGrid – cuadrícula del juego Wordle
// ─────────────────────────────────────────────────────────────────────────────
class WordleGrid extends StatelessWidget {
  final String target;
  final List<String> guesses;
  final int attempt;
  final String current;
  final List<Color> Function(String guess) getColors;

  const WordleGrid({
    super.key,
    required this.target,
    required this.guesses,
    required this.attempt,
    required this.current,
    required this.getColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(6, (r) {
        final guess = guesses[r];
        final isCurrentRow = r == attempt;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(target.length, (c) {
            String char = '';
            Color cellBg = Colors.white;
            Color borderCol = HabitikColors.divider;
            Color textCol = HabitikColors.textDark;

            if (isCurrentRow) {
              if (c < current.length) {
                char = current[c];
                borderCol = HabitikColors.green500;
              }
            } else if (guess.isNotEmpty) {
              char = guess[c];
              final colors = getColors(guess);
              cellBg = colors[c];
              borderCol = Colors.transparent;
              textCol = Colors.white;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(3),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: cellBg,
                border: Border.all(color: borderCol, width: 2),
                borderRadius: HabitikRadius.sm_,
                boxShadow: cellBg != Colors.white ? HabitikShadows.colored(cellBg) : [],
              ),
              child: Center(
                child: Text(
                  char,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textCol),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WordleKeyboard – teclado del Wordle con colores de estado
// ─────────────────────────────────────────────────────────────────────────────
class WordleKeyboard extends StatelessWidget {
  final Map<String, Color> keyColors;
  final void Function(String key) onKey;

  const WordleKeyboard({super.key, required this.keyColors, required this.onKey});

  static const _rows = [
    ['Q','W','E','R','T','Y','U','I','O','P'],
    ['A','S','D','F','G','H','J','K','L','Ñ'],
    ['ENVIAR','Z','X','C','V','B','N','M','BORRAR'],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate standard key width based on available width, leaving room for margins.
        // Row 3 has equivalent of 7 standard keys + 2 special keys (at 1.6x width) = 10.2 keys.
        // Margins: 9 keys * 4px horizontal margin = 36px.
        final standardWidth = ((constraints.maxWidth - 44) / 10.2).clamp(24.0, 36.0);
        final specialWidth = standardWidth * 1.6;

        return Column(
          children: _rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  final isSpecial = key == 'ENVIAR' || key == 'BORRAR';
                  final bg = keyColors[key] ?? HabitikColors.green50;
                  final textCol = bg == HabitikColors.green50 ? HabitikColors.textDark : Colors.white;
                  final keyWidth = isSpecial ? specialWidth : standardWidth;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {
                        AudioService.playSFX('click.mp3');
                        onKey(key);
                      },
                      child: AnimatedContainer(
                        duration: 200.ms,
                        width: keyWidth,
                        height: 42,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: HabitikRadius.xs_,
                          boxShadow: bg != HabitikColors.green50 ? HabitikShadows.colored(bg) : HabitikShadows.card,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          key == 'BORRAR' ? '⌫' : key == 'ENVIAR' ? '✔' : key,
                          style: TextStyle(
                            fontSize: isSpecial ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            color: textCol,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TriviaOption – botón de opción de trivia con estados
// ─────────────────────────────────────────────────────────────────────────────
enum TriviaOptionState { idle, correct, wrong, selected }

class TriviaOption extends StatelessWidget {
  final String text;
  final TriviaOptionState state;
  final VoidCallback onTap;
  final int index;

  const TriviaOption({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, border, textCol, shadowCol, icon) = _colors(state);
    final isPressed = state != TriviaOptionState.idle;

    return GestureDetector(
      onTap: state == TriviaOptionState.idle
          ? () {
              AudioService.playSFX('click.mp3');
              onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: 150.ms,
        curve: Curves.easeOut,
        width: double.infinity,
        margin: EdgeInsets.only(top: isPressed ? 4 : 0, bottom: isPressed ? 0 : 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: HabitikRadius.md_,
          border: Border.all(color: border, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowCol,
              offset: Offset(0, isPressed ? 1 : 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: border.withAlpha(40), shape: BoxShape.circle),
              child: Center(
                child: icon != null 
                    ? Icon(icon, color: border, size: 16) 
                    : Text(['A','B','C','D'][index], style: TextStyle(color: border, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(color: textCol, fontSize: 14, fontWeight: FontWeight.w800))),
          ],
        ),
      ).animate().slideX(begin: 0.05, delay: (index * 80).ms, duration: 300.ms),
    );
  }

  static (Color, Color, Color, Color, IconData?) _colors(TriviaOptionState s) {
    switch (s) {
      case TriviaOptionState.correct:  return (HabitikColors.green50,  HabitikColors.green500, HabitikColors.green700, HabitikColors.green700, Icons.check_circle);
      case TriviaOptionState.wrong:    return (Colors.red.shade50,     Colors.redAccent,       Colors.red.shade700,    Colors.red.shade800,    Icons.cancel);
      case TriviaOptionState.selected: return (HabitikColors.blue100,  HabitikColors.blue500,  HabitikColors.blue500,  const Color(0xFF1976D2),  null);
      default:                         return (Colors.white,            HabitikColors.divider,  HabitikColors.textDark,  const Color(0xFFD6D6D6), null);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LivesRow – fila de vidas para la trivia (corazones)
// ─────────────────────────────────────────────────────────────────────────────
class LivesRow extends StatelessWidget {
  final int lives;
  final int maxLives;

  const LivesRow({super.key, required this.lives, this.maxLives = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLives, (i) {
        final alive = i < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.favorite_rounded,
            color: alive ? Colors.redAccent : Colors.grey.shade400,
            size: 28,
          )
              .animate(target: alive ? 1 : 0)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.15, 1.15),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .animate(onPlay: (c) => alive ? c.repeat(reverse: true) : null)
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.08, 1.08),
                duration: 600.ms,
                curve: Curves.easeInOut,
              ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GameShell – contenedor base para todos los juegos
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Shared game helpers – used across all game screens to avoid duplication
// ─────────────────────────────────────────────────────────────────────────────

/// Small reward pill: "+50 XP", "+5 🪙", etc.
class GameRewardChip extends StatelessWidget {
  final String text;
  final Color color;

  const GameRewardChip({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: HabitikRadius.xxl_,
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Full-width gradient action button used at the bottom of result screens.
class GameActionButton extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final VoidCallback? onTap;
  final double height;

  const GameActionButton({
    super.key,
    required this.label,
    required this.gradient,
    this.onTap,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.playSFX('click.mp3');
        onTap?.call();
      },
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: HabitikRadius.md_,
          boxShadow: HabitikShadows.floating,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Victory / defeat banner shown at the end of a game.
///
/// [won]           – whether the player won
/// [titleWon]      – e.g. '🎉 ¡Sopa Resuelta!'
/// [titleLost]     – e.g. '😢 Tiempo agotado'
/// [chips]         – reward chips shown only when [won]
///
class GameCompleteBanner extends StatefulWidget {
  final bool won;
  final String titleWon;
  final String titleLost;
  final List<(String, Color)> chips;

  const GameCompleteBanner({
    super.key,
    required this.won,
    required this.titleWon,
    this.titleLost = '😢 ¡Inténtalo de nuevo!',
    this.chips = const [],
  });

  @override
  State<GameCompleteBanner> createState() => _GameCompleteBannerState();
}

class _GameCompleteBannerState extends State<GameCompleteBanner> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    if (widget.won) {
      AudioService.playSFX('win.mp3');
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.won
                ? (isDark ? const Color(0xFF1E2E22) : HabitikColors.green50)
                : (isDark ? const Color(0xFF3E1F1F) : Colors.red.shade50),
            borderRadius: HabitikRadius.lg_,
            border: Border.all(
              color: widget.won
                  ? (isDark ? const Color(0x30FFFFFF) : HabitikColors.green300)
                  : (isDark ? const Color(0x30FFFFFF) : Colors.red.shade200),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.won ? widget.titleWon : widget.titleLost,
                style: TextStyle(
                  color: widget.won
                      ? (isDark ? Colors.white : HabitikColors.green700)
                      : (isDark ? Colors.white : Colors.red.shade700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.won && widget.chips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.chips
                      .expand((c) => [
                            GameRewardChip(text: c.$1, color: c.$2),
                            const SizedBox(width: 8),
                          ])
                      .toList()
                    ..removeLast(), // remove trailing spacer
                ),
              ],
            ],
          ),
        ).animate().scale(
              begin: const Offset(0.9, 0.9),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
        if (widget.won)
          Positioned(
            top: -20,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 15,
              emissionFrequency: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.amber,
              ],
            ),
          ),
      ],
    );
  }
}

/// Shows the standard "¿Salir del juego?" confirmation dialog.
/// Returns [true] if the user confirmed exit.
Future<bool> showExitDialog(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: HabitikRadius.lg_),
      title: Text(
        '¿Salir del juego?',
        style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : HabitikColors.textDark),
      ),
      content: Text(
        '¿Seguro que quieres salir? Perderás tu progreso actual en este reto.',
        style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : HabitikColors.textMid),
      ),
      actions: [
        TextButton(
          onPressed: () {
            AudioService.playSFX('click.mp3');
            Navigator.of(context).pop(false);
          },
          child: const Text('Continuar jugando', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () {
            AudioService.playSFX('click.mp3');
            Navigator.of(context).pop(true);
          },
          child: const Text('Salir', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ─────────────────────────────────────────────────────────────────────────────
// GameShell – contenedor base para todos los juegos
// ─────────────────────────────────────────────────────────────────────────────
class GameShell extends StatelessWidget {
  final String title;
  final Color headerColor;
  final Widget child;
  final Widget? extra;
  final VoidCallback onClose;

  const GameShell({
    super.key,
    required this.title,
    required this.headerColor,
    required this.child,
    required this.onClose,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final extraWidget = extra;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Header del juego
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [headerColor.withAlpha(240), headerColor],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  AudioService.playSFX('click.mp3');
                  onClose();
                },
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(50), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
              extraWidget ?? const SizedBox.shrink(),
            ],
          ),
        ),

        // Body del juego
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF111D15) : HabitikColors.bgLight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
