import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tablero de EcoWordle que organiza las celdas en filas y columnas
/// con animaciones 3D de flip secuenciales al evaluar cada intento.
class EcoWordleBoard extends StatelessWidget {
  final int rows;
  final int cols;
  final List<String> attempts;
  final String currentAttempt;
  final List<List<String>> evaluationMatrix;
  final int currentRow;

  const EcoWordleBoard({
    super.key,
    required this.rows,
    required this.cols,
    required this.attempts,
    required this.currentAttempt,
    required this.evaluationMatrix,
    required this.currentRow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: List.generate(rows, (r) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cols, (c) {
                String letter = '';
                String state = 'vacio';

                if (r < attempts.length) {
                  if (c < attempts[r].length) {
                    letter = attempts[r][c];
                  }
                  if (r < evaluationMatrix.length && c < evaluationMatrix[r].length) {
                    state = evaluationMatrix[r][c];
                  }
                } else if (r == currentRow) {
                  if (c < currentAttempt.length) {
                    letter = currentAttempt[c];
                    state = 'typing';
                  }
                }

                return WordleCell(
                  key: ValueKey('cell_${r}_$c'),
                  letter: letter,
                  state: state,
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

/// Celda interactiva de Wordle con animación 3D de giro (flip) al revelarse.
class WordleCell extends StatefulWidget {
  final String letter;
  final String state;

  const WordleCell({
    super.key,
    required this.letter,
    required this.state,
  });

  @override
  State<WordleCell> createState() => _WordleCellState();
}

class _WordleCellState extends State<WordleCell> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  String _displayedState = 'vacio';

  @override
  void initState() {
    super.initState();
    _displayedState = widget.state;
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _flipController.addListener(() {
      if (_flipController.value >= 0.5 && _displayedState != widget.state) {
        setState(() {
          _displayedState = widget.state;
        });
      }
    });
  }

  @override
  void didUpdateWidget(WordleCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (widget.state == 'verde' || widget.state == 'amarillo' || widget.state == 'gris') {
        _flipController.forward(from: 0.0);
      } else {
        _displayedState = widget.state;
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, _) {
        final val = _flipAnimation.value;
        // Rotación 3D en el eje X: 0 a pi/2 en la primera mitad, -pi/2 a 0 en la segunda mitad
        final angle = val <= 0.5 ? val * math.pi : (1.0 - val) * -math.pi;
        final scale = 1.0 + (val > 0.5 ? (1.0 - val) * 0.12 : val * 0.12);

        Color bgColor = const Color(0xFF234B34); // Verde bosque cálido y acogedor (no negro sombrío)
        Color borderColor = const Color(0xFF427B55);
        const textColor = Colors.white;

        final curState = val >= 0.5 ? widget.state : _displayedState;

        if (curState == 'typing') {
          bgColor = const Color(0xFF2D6342);
          borderColor = const Color(0xFF86EFAC);
        } else if (curState == 'verde') {
          bgColor = const Color(0xFF10B981);
          borderColor = const Color(0xFF34D399);
        } else if (curState == 'amarillo') {
          bgColor = const Color(0xFFF59E0B);
          borderColor = const Color(0xFFFDE68A);
        } else if (curState == 'gris') {
          bgColor = const Color(0xFF475569);
          borderColor = const Color(0xFF64748B);
        } else if (widget.letter.isNotEmpty) {
          bgColor = const Color(0xFF2D6342);
          borderColor = const Color(0xFF86EFAC);
        }

        final isEvaluated = curState == 'verde' || curState == 'amarillo' || curState == 'gris';

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // Perspectiva 3D
            ..rotateX(angle)
            ..scaleByDouble(scale, scale, 1.0, 1.0),
          alignment: Alignment.center,
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.all(3.5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: borderColor,
                width: (curState == 'typing' || widget.letter.isNotEmpty) ? 2.2 : 1.8,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isEvaluated
                      ? bgColor.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.15),
                  blurRadius: isEvaluated ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.letter,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
