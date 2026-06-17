import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';

class WasteSorterChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;
  const WasteSorterChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<WasteSorterChallenge> createState() => _WasteSorterChallengeState();
}

class _WasteSorterChallengeState extends State<WasteSorterChallenge> {
  static const _totalSeconds = 60;

  final _items = [
    _WasteItem(name: 'Botella PET', emoji: '🧴', correct: 'Plástico', color: const Color(0xFFFFA726)),
    _WasteItem(name: 'Papel Periódico', emoji: '📰', correct: 'Papel/Cartón', color: const Color(0xFF8D6E63)),
    _WasteItem(name: 'Botella Vidrio', emoji: '🍶', correct: 'Vidrio', color: const Color(0xFF42A5F5)),
    _WasteItem(name: 'Cáscara Naranja', emoji: '🍊', correct: 'Orgánico', color: const Color(0xFF66BB6A)),
    _WasteItem(name: 'Pila Usada', emoji: '🔋', correct: 'Peligroso', color: const Color(0xFFEF5350)),
    _WasteItem(name: 'Lata Aluminio', emoji: '🥫', correct: 'Metal', color: const Color(0xFF78909C)),
    _WasteItem(name: 'Bolsa Plástica', emoji: '🛍️', correct: 'Plástico', color: const Color(0xFFFFA726)),
    _WasteItem(name: 'Caja Cartón', emoji: '📦', correct: 'Papel/Cartón', color: const Color(0xFF8D6E63)),
  ];

  final _bins = ['Plástico', 'Papel/Cartón', 'Vidrio', 'Orgánico', 'Peligroso', 'Metal'];
  final Map<String, String> _placed = {}; // itemName -> binName
  final List<Map<String, dynamic>> _activeEffects = [];
  int _seconds = _totalSeconds;
  bool _started = false;
  bool _finished = false;
  Timer? _timer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioService.playBGM('puzzle_bgm.mp3');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    AudioService.stopBGM();
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          t.cancel();
          _finished = true;
          AudioService.stopBGM();
          if (_won) {
            AudioService.playSFX('win.mp3');
            _confettiController.play();
          } else {
            AudioService.playSFX('error.mp3');
          }
        }
      });
    });
  }

  void _place(String item, String bin, double width) {
    if (!_started || _finished) return;
    
    // Check if correct
    final waste = _items.firstWhere((i) => i.name == item, orElse: () => _items.first);
    final correct = waste.correct == bin;

    // Play feedback sound
    if (correct) {
      AudioService.playSFX('catch_trash.mp3');
    } else {
      AudioService.playSFX('error.mp3');
    }
    
    // Position calculation for floating score
    final binIdx = _bins.indexOf(bin);
    final col = binIdx % 3;
    final row = binIdx ~/ 3;
    final double w = (width - 52) / 3;
    final double x = 16 + col * (w + 10) + w / 2;
    final double y = 220 + row * (w + 10) + w / 2;
    
    final effectId = DateTime.now().millisecondsSinceEpoch + binIdx;
    
    setState(() {
      _placed[item] = bin;
      _activeEffects.add({
        'id': effectId,
        'text': correct ? '✅ +15 XP 🪙' : '❌ Incorrecto',
        'position': Offset(x, y),
      });
    });

    if (_placed.length == _items.length) {
      _timer?.cancel();
      setState(() {
        _finished = true;
        AudioService.stopBGM();
        if (_won) {
          AudioService.playSFX('win.mp3');
          _confettiController.play();
        } else {
          AudioService.playSFX('error.mp3');
        }
      });
    }
  }

  int get _correct => _placed.entries.where((e) {
    final item = _items.firstWhere((i) => i.name == e.key, orElse: () => _items.first);
    return item.correct == e.value;
  }).length;

  bool get _won => _correct >= 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitikColors.bgLight,
      body: SafeArea(
        child: GameShell(
          title: '🎯 Eco-Puzzle',
          headerColor: const Color(0xFFC62828),
          onClose: widget.onBack,
          extra: CircularGameTimer(secondsLeft: _seconds, totalSeconds: _totalSeconds, running: _started && !_finished),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _finished ? _buildResult() : _buildGameLayout(),
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
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
          ),
        ),
      ),
    );
  }

  Widget _buildGameLayout() {
    if (!_started) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('♻️', style: TextStyle(fontSize: 72))
                .animate().scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text('Clasifica los residuos\nen el contenedor correcto',
              style: TextStyle(color: HabitikColors.textDark, fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Tienes 60 segundos', style: TextStyle(color: HabitikColors.textLight, fontSize: 13)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _start,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFB71C1C)]),
                  borderRadius: HabitikRadius.md_,
                  boxShadow: HabitikShadows.colored(const Color(0xFFC62828)),
                ),
                child: const Text('¡Empezar!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }

    final unplaced = _items.where((i) => !_placed.containsKey(i.name)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          height: 550,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Conveyor Belt Queue
                  if (unplaced.isNotEmpty) ...[
                    const Text('Cinta Transportadora:', style: TextStyle(color: HabitikColors.textLight, fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _ConveyorBelt(items: unplaced),
                    const SizedBox(height: 6),
                    Center(child: Text('${_items.length - unplaced.length}/${_items.length} clasificados', style: const TextStyle(color: HabitikColors.textLight, fontSize: 11))),
                    const SizedBox(height: 20),
                  ],

                  // Bins Grid Title
                  const Text('Contenedores de Reciclaje:', style: TextStyle(color: HabitikColors.textDark, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),

                  // Bins wrap
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: _bins.map((bin) => _BinTarget(
                      bin: bin,
                      onAccept: (item) => _place(item, bin, width),
                      placedCount: _placed.values.where((b) => b == bin).length,
                    )).toList(),
                  ),
                ],
              ),

              // Floating Score Effects Stacked on Top
              ..._activeEffects.map((effect) => FloatingEffectWidget(
                key: ValueKey(effect['id']),
                text: effect['text'] as String,
                position: effect['position'] as Offset,
                onFinished: () {
                  setState(() {
                    _activeEffects.removeWhere((e) => e['id'] == effect['id']);
                  });
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(_won ? '🏆' : '😢', style: const TextStyle(fontSize: 72))
              .animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(_won ? '¡Reciclaje maestro!' : 'Sigue practicando', style: const TextStyle(color: HabitikColors.textDark, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('$_correct / ${_items.length} clasificados correctamente', style: const TextStyle(color: HabitikColors.textLight, fontSize: 14)),
          const SizedBox(height: 24),
          if (_won) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GameRewardChip(text: '+120 XP', color: HabitikColors.amber400),
            const SizedBox(width: 8),
            GameRewardChip(text: '+20 🪙', color: HabitikColors.amber300),
          ]),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _won ? widget.onComplete : widget.onBack,
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: _won ? HabitikColors.xpGold : HabitikColors.heroGreen,
                borderRadius: HabitikRadius.md_,
                boxShadow: const [
                  BoxShadow(color: Color(0x20000000), offset: Offset(0, 4), blurRadius: 8),
                ],
              ),
              alignment: Alignment.center,
              child: Text(_won ? '🎉 Reclamar recompensa' : '🔄 Volver', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

}

class _WasteItem {
  final String name;
  final String emoji;
  final String correct;
  final Color color;
  _WasteItem({required this.name, required this.emoji, required this.correct, required this.color});
}

class _ItemChip extends StatelessWidget {
  final _WasteItem item;
  final bool dragging;
  final double width;
  final double height;
  final double emojiSize;
  final double fontSize;

  const _ItemChip({
    required this.item,
    this.dragging = false,
    this.width = 100,
    this.height = 90,
    this.emojiSize = 34,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: HabitikRadius.lg_,
          border: Border.all(color: item.color, width: 2),
          boxShadow: dragging ? HabitikShadows.glow(item.color) : HabitikShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji, style: TextStyle(fontSize: emojiSize)),
            const SizedBox(height: 4),
            Text(item.name, style: TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.w900, fontSize: fontSize)),
          ],
        ),
      ),
    );
  }
}

class _BinTarget extends StatelessWidget {
  final String bin;
  final void Function(String) onAccept;
  final int placedCount;

  static const _colors = {
    'Plástico':     Color(0xFFFFA726),
    'Papel/Cartón': Color(0xFF8D6E63),
    'Vidrio':       Color(0xFF42A5F5),
    'Orgánico':     Color(0xFF66BB6A),
    'Peligroso':    Color(0xFFEF5350),
    'Metal':        Color(0xFF78909C),
  };

  static const _emojis = {
    'Plástico':     '🟡',
    'Papel/Cartón': '🟫',
    'Vidrio':       '🔵',
    'Orgánico':     '🟢',
    'Peligroso':    '🔴',
    'Metal':        '⚫',
  };

  const _BinTarget({required this.bin, required this.onAccept, required this.placedCount});

  @override
  Widget build(BuildContext context) {
    final color = _colors[bin] ?? HabitikColors.green500;
    final emoji = _emojis[bin] ?? '♻️';
    final w = (MediaQuery.of(context).size.width - 52) / 3;

    return DragTarget<String>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (ctx, candidates, rejected) {
        final active = candidates.isNotEmpty;
        return Transform.scale(
          scale: active ? 1.08 : 1.0,
          child: AnimatedContainer(
            duration: 150.ms,
            width: w, height: w,
            decoration: BoxDecoration(
              color: active ? color.withAlpha(50) : Colors.white,
              borderRadius: HabitikRadius.lg_,
              border: Border.all(color: color, width: active ? 3.0 : 2.0),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(100),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26))
                    .animate(target: active ? 1 : 0)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 200.ms),
                const SizedBox(height: 6),
                Text(bin, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                if (placedCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: color, borderRadius: HabitikRadius.xxl_),
                    child: Text('$placedCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ConveyorBelt – cinta transportadora animada para el Eco-Puzzle
// ─────────────────────────────────────────────────────────────────────────────
class _ConveyorBelt extends StatefulWidget {
  final List<_WasteItem> items;
  const _ConveyorBelt({required this.items});

  @override
  State<_ConveyorBelt> createState() => _ConveyorBeltState();
}

class _ConveyorBeltState extends State<_ConveyorBelt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.grey.shade400, width: 3),
        boxShadow: HabitikShadows.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Moving rollers background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConveyorPainter(scrollProgress: _controller.value),
                );
              },
            ),
          ),
          // Queue row
          if (widget.items.isNotEmpty)
            Positioned(
              left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Active item (centered)
                  Draggable<String>(
                    data: widget.items.first.name,
                    feedback: _ItemChip(item: widget.items.first, dragging: true),
                    childWhenDragging: const SizedBox(width: 100, height: 90),
                    child: _ItemChip(item: widget.items.first)
                        .animate()
                        .scale(begin: const Offset(0.85, 0.85), duration: 250.ms, curve: Curves.easeOutBack),
                  ),
                  // Queue previews
                  if (widget.items.length > 1) ...[
                    const SizedBox(width: 12),
                    ...widget.items.skip(1).take(2).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Opacity(
                          opacity: 0.4,
                          child: _ItemChip(
                            item: item,
                            width: 65,
                            height: 58,
                            emojiSize: 22,
                            fontSize: 9,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConveyorPainter extends CustomPainter {
  final double scrollProgress;
  _ConveyorPainter({required this.scrollProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const double spacing = 35.0;
    final double offset = (scrollProgress * spacing);

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      final rx = x + offset;
      canvas.drawLine(Offset(rx, 4), Offset(rx, size.height - 4), paint);
      canvas.drawCircle(Offset(rx, size.height / 2), 2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(_ConveyorPainter old) => old.scrollProgress != scrollProgress;
}

// ─────────────────────────────────────────────────────────────────────────────
// FloatingEffectWidget – efecto flotante de +15 XP al clasificar correctamente
// ─────────────────────────────────────────────────────────────────────────────
class FloatingEffectWidget extends StatelessWidget {
  final String text;
  final Offset position;
  final VoidCallback onFinished;

  const FloatingEffectWidget({
    super.key,
    required this.text,
    required this.position,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 60,
      top: position.dy - 35,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: 900.ms,
        onEnd: onFinished,
        builder: (context, val, child) {
          final double translationY = -60 * val;
          final double opacity = val < 0.15 
              ? (val / 0.15) 
              : val > 0.75 
                  ? (1.0 - val) / 0.25 
                  : 1.0;
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, translationY),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: text.contains('✅') ? HabitikColors.xpGold : const LinearGradient(colors: [Color(0xFFEF5350), Color(0xFFC62828)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4, offset: const Offset(0, 3)),
                  ],
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
