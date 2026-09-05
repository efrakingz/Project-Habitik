import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';

class WordleChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;
  const WordleChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<WordleChallenge> createState() => _WordleChallengeState();
}

class _WordleChallengeState extends State<WordleChallenge> {
  static const _words = ['AGUA', 'SOLAR', 'VERDE', 'SUELO', 'BOSQUE', 'VIDRIO', 'COMPOST', 'RECICLA', 'PLANTAS', 'AHORRO'];

  late final String _target;
  late final List<String> _guesses;
  int _attempt = 0;
  String _current = '';
  bool _finished = false;
  bool _won = false;
  final Map<String, Color> _keyColors = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final seed = (now.year * 365 + now.month * 31 + now.day) % _words.length;
    _target = _words[seed].toUpperCase();
    _guesses = List.generate(6, (_) => '');
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    AudioService.playBGM('wordle_bgm.mp3');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    AudioService.stopBGM();
    super.dispose();
  }

  List<Color> _getColors(String guess) {
    final colors = List.generate(guess.length, (_) => Colors.grey.shade400);
    final counts = <String, int>{};
    for (var c in _target.split('')) { counts[c] = (counts[c] ?? 0) + 1; }
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == _target[i]) { colors[i] = HabitikColors.green500; counts[guess[i]] = counts[guess[i]]! - 1; }
    }
    for (int i = 0; i < guess.length; i++) {
      if (colors[i] != HabitikColors.green500) {
        if (counts.containsKey(guess[i]) && counts[guess[i]]! > 0) { colors[i] = HabitikColors.amber400; counts[guess[i]] = counts[guess[i]]! - 1; }
      }
    }
    return colors;
  }

  void _onKey(String key) {
    if (_finished) return;
    if (key == 'BORRAR') {
      if (_current.isNotEmpty) setState(() => _current = _current.substring(0, _current.length - 1));
    } else if (key == 'ENVIAR') {
      if (_current.length == _target.length) {
        final guess = _current.toUpperCase();
        final colors = _getColors(guess);
        setState(() {
          _guesses[_attempt] = guess;
          for (int i = 0; i < guess.length; i++) {
            final col = colors[i];
            final curr = _keyColors[guess[i]];
            if (curr == HabitikColors.green500) continue;
            if (curr == HabitikColors.amber400 && col != HabitikColors.green500) continue;
            _keyColors[guess[i]] = col;
          }
          if (guess == _target) {
            _finished = true;
            _won = true;
            AudioService.stopBGM();
            AudioService.playSFX('win.mp3');
            _confettiController.play();
          }
          else {
            _attempt++;
            _current = '';
            if (_attempt >= 6) {
              _finished = true;
              _won = false;
              AudioService.stopBGM();
              AudioService.playSFX('error.mp3');
            }
          }
        });
      }
    } else {
      if (_current.length < _target.length) setState(() => _current += key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitikColors.bgLight,
      body: SafeArea(
        child: GameShell(
          title: '🔤 Eco-Wordle del Día',
          headerColor: HabitikColors.green700,
          onClose: widget.onBack,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Text('Adivina la palabra ecológica de ${_target.length} letras.',
                    style: const TextStyle(color: HabitikColors.textMid, fontSize: 13),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 16),

                  WordleGrid(
                    target: _target,
                    guesses: _guesses,
                    attempt: _attempt,
                    current: _current,
                    getColors: _getColors,
                  ),

                  const SizedBox(height: 20),

                  if (_finished) ...[
                    _ResultBanner(won: _won, word: _target),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _won ? widget.onComplete : widget.onBack,
                      child: Container(
                        width: double.infinity, height: 50,
                        decoration: BoxDecoration(
                          gradient: _won ? HabitikColors.xpGold : HabitikColors.heroGreen,
                          borderRadius: HabitikRadius.md_,
                        ),
                        alignment: Alignment.center,
                        child: Text(_won ? '🎉 Reclamar +50 XP' : '👋 Volver', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                  ] else ...[
                    WordleKeyboard(keyColors: _keyColors, onKey: _onKey),
                  ],
                ],
              ),
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
}

class _ResultBanner extends StatelessWidget {
  final bool won;
  final String word;
  const _ResultBanner({required this.won, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: won ? HabitikColors.green50 : Colors.red.shade50,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: won ? HabitikColors.green300 : Colors.red.shade200),
      ),
      child: Column(children: [
        Text(won ? '🎉 ¡Felicidades!' : '😢 La palabra era $word',
          style: TextStyle(color: won ? HabitikColors.green700 : Colors.red.shade700, fontWeight: FontWeight.w900, fontSize: 15)),
        if (won) ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GameRewardChip(text: '+50 XP', color: HabitikColors.amber400),
            const SizedBox(width: 8),
            GameRewardChip(text: '+5 🪙', color: HabitikColors.amber300),
          ]),
        ],
      ]),
    ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.elasticOut);
  }

}
