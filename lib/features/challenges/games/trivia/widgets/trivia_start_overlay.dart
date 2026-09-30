import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

class TriviaStartOverlay extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onExit;

  const TriviaStartOverlay({
    super.key,
    required this.onStart,
    required this.onExit,
  });

  @override
  State<TriviaStartOverlay> createState() => _TriviaStartOverlayState();
}

class _TriviaStartOverlayState extends State<TriviaStartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;

  int _tipIndex = 0;
  Timer? _tipTimer;

  static const List<String> _ecoTips = [
    '💡 Desenchufar equipos en espera reduce hasta un 10% del consumo eléctrico.',
    '💧 Una ducha de 5 minutos ahorra hasta 60 litros de agua frente a una de 10 minutos.',
    '🌱 Las abejas y polinizadores sostienen más del 75% de los cultivos mundiales.',
    '♻️ El plástico tipo PET puede tardar hasta 500 años en degradarse por completo.',
    '🚲 Desplazarse en bicicleta genera cero emisiones y cuida tu salud cardiovascular.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 0.96,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _tipIndex = (_tipIndex + 1) % _ecoTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: const Color(0xFFE1BEE7), width: 2),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón cerrar arriba a la derecha
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: widget.onExit,
                ),
              ),

              // Icono animado
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🧠', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Trivia Ambiental',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A148C),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Demuestra tus conocimientos ecológicos y gana XP para tu hogar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: HabitikColors.textMid,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // Reglas con iconos
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1BEE7)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  children: const [
                    _RuleRow(
                      emoji: '❤️',
                      title: '3 Vidas',
                      desc: 'Pierdes 1 vida por error o timeout.',
                    ),
                    SizedBox(height: 8),
                    _RuleRow(
                      emoji: '⏱️',
                      title: '30 Segundos',
                      desc: 'Tiempo límite por cada pregunta.',
                    ),
                    SizedBox(height: 8),
                    _RuleRow(
                      emoji: '⚡',
                      title: 'Hasta 60 XP',
                      desc: '<10s: 60 XP · 10-20s: 40 XP · 21-30s: 20 XP.',
                    ),
                    SizedBox(height: 8),
                    _RuleRow(
                      emoji: '🪙',
                      title: '1 Moneda',
                      desc: 'Por cada 5 respuestas correctas.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Eco-Tip rotativo
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey<int>(_tipIndex),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Text(
                    _ecoTips[_tipIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Botón de comenzar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E24AA).withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: widget.onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '¡COMENZAR TRIVIA!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;

  const _RuleRow({
    required this.emoji,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF333333)),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A148C),
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
