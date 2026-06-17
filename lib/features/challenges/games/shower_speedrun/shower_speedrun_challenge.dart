import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';
import 'package:habitik/features/challenges/games/shower_speedrun/drip_animation.dart';

class ShowerSpeedrunChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;
  const ShowerSpeedrunChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<ShowerSpeedrunChallenge> createState() => _ShowerSpeedrunChallengeState();
}

class _ShowerSpeedrunChallengeState extends State<ShowerSpeedrunChallenge> {
  static const _total = 10 * 60; // 10 minutos
  int _seconds = _total;
  bool _running = false;
  bool _finished = false;
  bool _won = false;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _start() {
    AudioService.playSFX('catch_fish.mp3');
    setState(() { _running = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          t.cancel();
          _finished = true;
          _running = false;
          _won = false;
          AudioService.playSFX('error.mp3');
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    final wonGame = _seconds > 0;
    setState(() {
      _running = false;
      _finished = true;
      _won = wonGame;
    });
    if (wonGame) {
      AudioService.playSFX('win.mp3');
    } else {
      AudioService.playSFX('error.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitikColors.bgLight,
      body: SafeArea(
        child: GameShell(
          title: '🚿 Speedrun de la Ducha',
          headerColor: HabitikColors.blue500,
          onClose: widget.onBack,
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Dúchate en menos de 10 minutos y presiona "Listo" al terminar.',
                style: TextStyle(color: HabitikColors.textMid, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Shower cabin UI container
              Container(
                width: 260,
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: HabitikRadius.lg_,
                  border: Border.all(color: HabitikColors.blue300, width: 3),
                  boxShadow: HabitikShadows.card,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Water drip animation particles
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: ShowerDripAnimation(active: _running),
                      ),
                    ),
                    // Shower Head vector decoration
                    Positioned(
                      top: 10,
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade600, width: 1.5),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                    // Timer in the middle
                    Positioned(
                      bottom: 20,
                      child: CircularGameTimer(
                        secondsLeft: _seconds,
                        totalSeconds: _total,
                        running: _running,
                        color: HabitikColors.blue500,
                      ).animate(target: _running ? 1 : 0)
                       .shimmer(duration: 2000.ms, color: Colors.white.withAlpha(60)),
                    ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.9, 0.9), duration: 450.ms, curve: Curves.elasticOut),

              const SizedBox(height: 28),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(label: 'Litros ahorro', value: '${((_total - _seconds) * 0.15).toStringAsFixed(1)} L', color: HabitikColors.blue500),
                  const SizedBox(width: 16),
                  _StatChip(label: 'Meta', value: '< 10 min', color: HabitikColors.green600),
                ],
              ),

              const SizedBox(height: 28),

              if (!_finished) ...[
                if (!_running)
                  _BigButton(
                    label: '💧 ¡Empezar ducha!',
                    gradient: HabitikColors.coolBlue,
                    onTap: _start,
                  ).animate().scale(begin: const Offset(0.9, 0.9), duration: 300.ms)
                else
                  _BigButton(
                    label: '✅ ¡Terminé!',
                    gradient: HabitikColors.heroGreen,
                    onTap: _stop,
                  ),
              ] else ...[
                _ResultPanel(won: _won, timeLeft: _seconds),
                const SizedBox(height: 20),
                _BigButton(
                  label: _won ? '🎉 Reclamar +50 XP' : 'Intentar de nuevo',
                  gradient: _won ? HabitikColors.xpGold : const LinearGradient(colors: [Color(0xFF78909C), Color(0xFF546E7A)]),
                  onTap: _won ? widget.onComplete : () {
                    setState(() {
                      _seconds = _total;
                      _finished = false;
                      _won = false;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: HabitikRadius.md_, border: Border.all(color: color.withAlpha(60))),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: TextStyle(color: color.withAlpha(180), fontSize: 11)),
      ]),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final VoidCallback? onTap;
  const _BigButton({required this.label, required this.gradient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.playSFX('click.mp3');
        onTap?.call();
      },
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(gradient: gradient, borderRadius: HabitikRadius.md_, boxShadow: HabitikShadows.floating),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final bool won;
  final int timeLeft;
  const _ResultPanel({required this.won, required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: won ? HabitikColors.green50 : Colors.red.shade50,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: won ? HabitikColors.green300 : Colors.red.shade200),
      ),
      child: Column(children: [
        Text(won ? '🎉 ¡Lo lograste!' : '⏰ ¡Tiempo agotado!',
          style: TextStyle(color: won ? HabitikColors.green700 : Colors.red.shade700, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
          won ? 'Te duchaste en menos de 10 min. ¡Agua ahorrada!' : 'La próxima intenta ser más rápido 💪',
          style: TextStyle(color: won ? HabitikColors.textMid : Colors.red.shade600, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        if (won) ...[
          const SizedBox(height: 10),
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
