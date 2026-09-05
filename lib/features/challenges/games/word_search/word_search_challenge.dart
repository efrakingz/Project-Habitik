import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';

class WordSearchChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const WordSearchChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<WordSearchChallenge> createState() => _WordSearchChallengeState();
}

class _WordSearchChallengeState extends State<WordSearchChallenge> {
  // Conceptos ecológicos a buscar
  static const List<String> _allWords = [
    'AGUA', 'LUZ', 'VERDE', 'PAPEL', 'SOLAR',
    'BOSQUE', 'ECOLOGIA', 'RECICLA',
  ];

  late List<String> _targetWords;
  late List<List<String>> _grid;
  final Set<String> _foundWords = {};

  // Celdas ya resueltas (fijas en verde)
  final Set<Point<int>> _solvedCells = {};

  // Estado del arrastre actual
  Point<int>? _startCell;
  Point<int>? _currentCell;
  List<Point<int>> _draggedPath = [];

  // Estado del feedback de error (parpadeo rojo)
  List<Point<int>> _errorPath = [];
  bool _isErrorFlashing = false;

  // Estado final
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _generateGame();
    AudioService.playBGM('sopa_bgm.mp3');
  }

  @override
  void dispose() {
    AudioService.stopBGM();
    super.dispose();
  }

  void _generateGame() {
    final random = Random();
    final shuffled = List<String>.from(_allWords)..shuffle(random);
    _targetWords = shuffled.take(5).toList();

    _grid = List.generate(10, (_) => List.generate(10, (_) => ''));

    for (var word in _targetWords) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 150) {
        attempts++;
        final row = random.nextInt(10);
        final col = random.nextInt(10);

        final direction = random.nextInt(3);
        int dx = 0, dy = 0;

        if (direction == 0) {
          dx = 1;
        } else if (direction == 1) {
          dy = 1;
        } else {
          dx = 1; dy = 1;
        }

        if (col + dx * (word.length - 1) >= 10 || row + dy * (word.length - 1) >= 10) {
          continue;
        }

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final cell = _grid[row + i * dy][col + i * dx];
          if (cell.isNotEmpty && cell != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            _grid[row + i * dy][col + i * dx] = word[i];
          }
          placed = true;
        }
      }
    }

    // Rellenar espacios vacíos con letras aleatorias
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        if (_grid[r][c].isEmpty) {
          _grid[r][c] = alphabet[random.nextInt(alphabet.length)];
        }
      }
    }

    _foundWords.clear();
    _solvedCells.clear();
    _finished = false;
  }

  void _onDragStart(Offset localPos, double gridWidth, double gridHeight) {
    if (_isErrorFlashing || _finished) return;

    final cellWidth = gridWidth / 10;
    final cellHeight = gridHeight / 10;
    final col = (localPos.dx / cellWidth).floor().clamp(0, 9);
    final row = (localPos.dy / cellHeight).floor().clamp(0, 9);

    setState(() {
      _startCell = Point(col, row);
      _currentCell = Point(col, row);
      _draggedPath = [Point(col, row)];
    });
  }

  void _onDragUpdate(Offset localPos, double gridWidth, double gridHeight) {
    if (_isErrorFlashing || _finished || _startCell == null) return;

    final cellWidth = gridWidth / 10;
    final cellHeight = gridHeight / 10;
    final col = (localPos.dx / cellWidth).floor().clamp(0, 9);
    final row = (localPos.dy / cellHeight).floor().clamp(0, 9);

    final newCell = Point(col, row);
    if (_currentCell == newCell) return;

    final dCol = col - _startCell!.x;
    final dRow = row - _startCell!.y;

    final isHorizontal = dRow == 0;
    final isVertical = dCol == 0;
    final isDiagonal = dCol.abs() == dRow.abs();

    if (isHorizontal || isVertical || isDiagonal) {
      final stepCol = dCol == 0 ? 0 : dCol.sign;
      final stepRow = dRow == 0 ? 0 : dRow.sign;
      final steps = max(dCol.abs(), dRow.abs());

      final List<Point<int>> path = [];
      for (int i = 0; i <= steps; i++) {
        path.add(Point(_startCell!.x + i * stepCol, _startCell!.y + i * stepRow));
      }

      setState(() {
        _currentCell = newCell;
        _draggedPath = path;
      });
    }
  }

  void _onDragEnd() {
    if (_isErrorFlashing || _finished || _startCell == null) return;

    final word = _draggedPath.map((p) => _grid[p.y][p.x]).join();
    final wordReversed = word.split('').reversed.join();

    String? matchedWord;
    if (_targetWords.contains(word) && !_foundWords.contains(word)) {
      matchedWord = word;
    } else if (_targetWords.contains(wordReversed) && !_foundWords.contains(wordReversed)) {
      matchedWord = wordReversed;
    }

    if (matchedWord != null) {
      AudioService.playSFX('catch_trash.mp3');
      setState(() {
        _foundWords.add(matchedWord!);
        _solvedCells.addAll(_draggedPath);
        _startCell = null;
        _currentCell = null;
        _draggedPath = [];
        if (_foundWords.length == _targetWords.length) {
          _finished = true;
          AudioService.stopBGM();
        }
      });
    } else {
      AudioService.playSFX('error.mp3');
      setState(() {
        _errorPath = List.from(_draggedPath);
        _isErrorFlashing = true;
        _startCell = null;
        _currentCell = null;
        _draggedPath = [];
      });

      Future.delayed(500.ms, () {
        if (!mounted) return;
        setState(() {
          _errorPath = [];
          _isErrorFlashing = false;
        });
      });
    }
  }

  void _confirmExit() async {
    final shouldExit = await showExitDialog(context);
    if (shouldExit && mounted) widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showExitDialog(context);
        if (shouldExit && context.mounted) widget.onBack();
      },
      child: Scaffold(
        backgroundColor: HabitikColors.bgLight,
        body: SafeArea(
          child: GameShell(
            title: '🔠 Sopa de Letras Ecológica',
            headerColor: const Color(0xFF00796B),
            onClose: _confirmExit,
            child: Column(
              children: [
                const Text(
                  'Encuentra los 5 conceptos ecológicos ocultos en la sopa.',
                  style: TextStyle(color: HabitikColors.textMid, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Lista de palabras a buscar
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _targetWords.map((word) {
                    final found = _foundWords.contains(word);
                    return AnimatedContainer(
                      duration: 300.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: found ? HabitikColors.green50 : Colors.white,
                        borderRadius: HabitikRadius.sm_,
                        border: Border.all(
                          color: found ? HabitikColors.green500 : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (found) ...[
                            const Icon(Icons.check_circle, color: HabitikColors.green500, size: 14),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            word,
                            style: TextStyle(
                              color: found ? HabitikColors.green700 : HabitikColors.textDark,
                              fontWeight: FontWeight.w800,
                              decoration: found ? TextDecoration.lineThrough : null,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Cuadrícula de Sopa de Letras
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth.clamp(200.0, 360.0);
                    return Center(
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: HabitikRadius.lg_,
                          border: Border.all(color: const Color(0xFF00796B), width: 3.5),
                          boxShadow: HabitikShadows.card,
                        ),
                        child: GestureDetector(
                          onPanStart: (d) => _onDragStart(d.localPosition, size, size),
                          onPanUpdate: (d) => _onDragUpdate(d.localPosition, size, size),
                          onPanEnd: (_) => _onDragEnd(),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 100,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 10,
                            ),
                            itemBuilder: (context, index) {
                              final row = index ~/ 10;
                              final col = index % 10;
                              final cellPt = Point(col, row);

                              final isSolved = _solvedCells.contains(cellPt);
                              final isDragged = _draggedPath.contains(cellPt);
                              final isError = _errorPath.contains(cellPt);

                              Color bg = Colors.transparent;
                              Color textCol = HabitikColors.textDark;

                              if (isSolved) {
                                bg = HabitikColors.green200;
                                textCol = HabitikColors.green900;
                              } else if (isDragged) {
                                bg = const Color(0x60009688);
                                textCol = const Color(0xFF004D40);
                              } else if (isError) {
                                bg = Colors.redAccent.withAlpha(100);
                                textCol = Colors.red.shade900;
                              }

                              return Container(
                                decoration: BoxDecoration(
                                  color: bg,
                                  border: Border.all(color: Colors.grey.shade100, width: 0.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _grid[row][col],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSolved || isDragged || isError
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    color: textCol,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Banner de Resultado
                if (_finished) ...[
                  GameCompleteBanner(
                    won: true,
                    titleWon: '🎉 ¡Sopa Resuelta!',
                    chips: const [
                      ('+100 XP', HabitikColors.amber400),
                      ('+10 🪙', HabitikColors.amber300),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GameActionButton(
                    label: 'Reclamar Recompensa',
                    gradient: HabitikColors.xpGold,
                    onTap: widget.onComplete,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
