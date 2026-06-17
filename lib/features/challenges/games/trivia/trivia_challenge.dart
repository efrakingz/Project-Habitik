import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';

class TriviaChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;
  const TriviaChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<TriviaChallenge> createState() => _TriviaChallengeState();
}

class _TriviaChallengeState extends State<TriviaChallenge> {
  static const _questions = [
    {
      'q': '¿Cuántos litros de agua puede contaminar una sola pila alcalina si se desecha en la basura?',
      'ops': ['10.000 litros', '100.000 litros', '600.000 litros', '1.000 litros'],
      'ans': 2,
      'tip': '¡Una sola pila puede contaminar 600.000 litros de agua subterránea si no se desecha correctamente!',
    },
    {
      'q': '¿Qué porcentaje de energía ahorra un foco LED comparado con uno incandescente?',
      'ops': ['40%', '60%', '80%', '95%'],
      'ans': 2,
      'tip': 'Los focos LED consumen hasta 80% menos energía y duran 25 veces más.',
    },
    {
      'q': '¿Cuántos árboles se necesitan reciclar para salvar de la tala una tonelada de papel?',
      'ops': ['5 árboles', '17 árboles', '30 árboles', '50 árboles'],
      'ans': 1,
      'tip': 'Reciclar 1 tonelada de papel salva 17 árboles y ahorra miles de litros de agua.',
    },
    {
      'q': '¿Cuánto CO2 puede absorber un árbol maduro al año?',
      'ops': ['5 kg', '22 kg', '50 kg', '100 kg'],
      'ans': 1,
      'tip': 'Un árbol maduro absorbe aproximadamente 22 kg de CO2 al año y libera oxígeno vital.',
    },
    {
      'q': '¿Qué significa "consumo vampiro" en el hogar?',
      'ops': ['Consumo de noche', 'Dispositivos en standby enchufados', 'Uso de aires acondicionados', 'Calefacción excesiva'],
      'ans': 1,
      'tip': 'Los dispositivos en standby pueden representar hasta el 10% de tu factura eléctrica.',
    },
  ];

  int _idx = 0;
  int _lives = 3;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _answer(int i) {
    if (_answered) return;
    final correct = i == _questions[_idx]['ans'] as int;
    setState(() {
      _selected = i;
      _answered = true;
      if (correct) {
        _score++;
        AudioService.playSFX('catch_trash.mp3');
      } else {
        _lives--;
        AudioService.playSFX('error.mp3');
        if (_lives <= 0) {
          _finished = true;
          AudioService.playSFX('error.mp3');
          return;
        }
      }
    });
    Future.delayed(1200.ms, () {
      if (!mounted) return;
      setState(() {
        _selected = null;
        _answered = false;
        if (_idx < _questions.length - 1) {
          _idx++;
        } else {
          _finished = true;
          final won = _score >= 3 && _lives > 0;
          if (won) {
            AudioService.playSFX('win.mp3');
            _confettiController.play();
          } else {
            AudioService.playSFX('error.mp3');
          }
        }
      });
    });
  }

  TriviaOptionState _stateFor(int i) {
    if (!_answered || _selected == null) return TriviaOptionState.idle;
    final correct = _questions[_idx]['ans'] as int;
    if (i == correct) return TriviaOptionState.correct;
    if (i == _selected && i != correct) return TriviaOptionState.wrong;
    return TriviaOptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitikColors.bgLight,
      body: SafeArea(
        child: GameShell(
          title: '🧠 Trivia Ecológica',
          headerColor: HabitikColors.purple500,
          onClose: widget.onBack,
          extra: LivesRow(lives: _lives),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _finished
                  ? _buildResult()
                  : _buildQuestion(),
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

  Widget _buildQuestion() {
    final q = _questions[_idx];
    final ops = q['ops'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pregunta ${_idx + 1} de ${_questions.length}', style: const TextStyle(color: HabitikColors.textLight, fontSize: 12)),
            Text('$_score correctas', style: const TextStyle(color: HabitikColors.green600, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: HabitikRadius.xs_,
          child: LinearProgressIndicator(
            value: (_idx + 1) / _questions.length,
            backgroundColor: HabitikColors.purple300.withAlpha(50),
            valueColor: const AlwaysStoppedAnimation(HabitikColors.purple500),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 24),

        // Mascot and dialog question card
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mascot Column
            Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: HabitikColors.heroGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x15000000), blurRadius: 4, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .moveY(begin: 0, end: 3, duration: 800.ms, curve: Curves.easeInOut),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: HabitikColors.green700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'EcoBot',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Dialog Question bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(color: HabitikColors.purple300, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFF3E5F5), // Solid purple shadow
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PREGUNTA ${_idx + 1}', style: const TextStyle(color: HabitikColors.purple500, fontSize: 10, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(q['q'] as String, style: const TextStyle(color: HabitikColors.textDark, fontSize: 14, fontWeight: FontWeight.w800, height: 1.35)),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Options
        ...ops.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TriviaOption(
            text: e.value,
            state: _stateFor(e.key),
            onTap: () => _answer(e.key),
            index: e.key,
          ),
        )),

        // Tip box after answering
        if (_answered) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
              ),
              borderRadius: HabitikRadius.md_,
              border: Border.all(color: HabitikColors.amber400, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFFFF59D),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q['tip'] as String,
                    style: const TextStyle(color: HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ],
    );
  }

  Widget _buildResult() {
    final won = _score >= 3 && _lives > 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // Victory Mascot
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: won ? HabitikColors.xpGold : const LinearGradient(colors: [Color(0xFF78909C), Color(0xFF546E7A)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: won ? HabitikColors.amber400.withAlpha(80) : Colors.black.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(won ? '🏆' : '😢', style: const TextStyle(fontSize: 52))
                  .animate(onPlay: (c) => won ? c.repeat() : null)
                  .shake(duration: 800.ms, hz: 4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            won ? '¡Eres un experto eco!' : 'Sigue aprendiendo...',
            style: const TextStyle(color: HabitikColors.textDark, fontSize: 20, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$_score de ${_questions.length} respuestas correctas',
            style: const TextStyle(color: HabitikColors.textLight, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Score Board
          Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: HabitikRadius.lg_,
              border: Border.all(color: won ? HabitikColors.green300 : HabitikColors.divider, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFE0E0E0),
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'RESUMEN DE RECOMPENSAS',
                  style: TextStyle(color: HabitikColors.textLight, fontSize: 10, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                if (won) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GameRewardChip(text: '+150 XP', color: HabitikColors.amber500),
                      GameRewardChip(text: '+15 🪙', color: HabitikColors.amber400),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'Consigue al menos 3 aciertos para obtener recompensas.',
                    style: TextStyle(color: HabitikColors.textMid, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action button
          GestureDetector(
            onTap: () {
              AudioService.playSFX('click.mp3');
              if (won) {
                widget.onComplete();
              } else {
                setState(() {
                  _idx = 0;
                  _lives = 3;
                  _score = 0;
                  _selected = null;
                  _answered = false;
                  _finished = false;
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: won ? HabitikColors.xpGold : HabitikColors.heroGreen,
                borderRadius: HabitikRadius.md_,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                won ? '🎉 Reclamar recompensa' : '🔄 Intentar de nuevo',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// Extension to darken colors slightly for text readability
extension ColorDarken on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
