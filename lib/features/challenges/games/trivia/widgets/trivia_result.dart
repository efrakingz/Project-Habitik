import 'package:flutter/material.dart';
import 'package:habitik/shared/widgets/effects/celebration_confetti.dart';
import '../models/trivia_final_result.dart';

class TriviaResultView extends StatelessWidget {
  final TriviaFinalResult result;
  final VoidCallback onClose;

  const TriviaResultView({
    super.key,
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Efecto de confeti animado de fondo
        const Positioned.fill(
          child: IgnorePointer(child: CelebrationConfetti()),
        ),

        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE1BEE7), width: 2),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono trofeo
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏆', style: TextStyle(fontSize: 44)),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '¡Partida Finalizada!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '¡Gran esfuerzo ecológico! Tus recompensas ya fueron sumadas a tu perfil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF555555),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Si subió de nivel
                  if (result.levelUp) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌟', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            '¡SUBISTE AL NIVEL ${result.currentLevel}!',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3E2723),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Resumen de estadísticas en cuadrícula
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          emoji: '🎯',
                          title: 'Aciertos',
                          value: '${result.correctCount}',
                          bgColor: const Color(0xFFE8F5E9),
                          borderColor: const Color(0xFFA5D6A7),
                          textColor: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          emoji: '❌',
                          title: 'Errores',
                          value: '${result.incorrectCount}',
                          bgColor: const Color(0xFFFFEBEE),
                          borderColor: const Color(0xFFFFCDD2),
                          textColor: const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          emoji: '⚡',
                          title: 'XP Ganada',
                          value: '+${result.xpEarned}',
                          bgColor: const Color(0xFFFFF8E1),
                          borderColor: const Color(0xFFFFE082),
                          textColor: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          emoji: '🪙',
                          title: 'Monedas',
                          value: '+${result.coinsEarned}',
                          bgColor: const Color(0xFFF3E5F5),
                          borderColor: const Color(0xFFCE93D8),
                          textColor: const Color(0xFF7B1FA2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón reclamar recompensa / salir
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (result.correctCount > 0 || result.xpEarned > 0)
                            ? const Color(0xFF8E24AA)
                            : const Color(0xFF757575),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        (result.correctCount > 0 || result.xpEarned > 0)
                            ? '¡RECLAMAR RECOMPENSA! ✨'
                            : 'VOLVER A DESAFÍOS',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF616161),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
