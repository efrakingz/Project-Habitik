import 'package:flutter/material.dart';

class TriviaHeader extends StatelessWidget {
  final int lives;
  final int remainingSeconds;
  final int correctCount;
  final int accumulatedXp;
  final VoidCallback onExit;

  const TriviaHeader({
    super.key,
    required this.lives,
    required this.remainingSeconds,
    required this.correctCount,
    required this.accumulatedXp,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = remainingSeconds <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fila superior: Salir, Título y Vidas
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 26,
                    color: Color(0xFF4A148C),
                  ),
                  onPressed: onExit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Trivia Ambiental',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                ),
                // 3 Corazones con animación de opacidad
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final isAlive = index < lives;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isAlive ? 1.0 : 0.22,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          isAlive ? '❤️' : '🤍',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fila inferior: Reloj de 30s + Stats de XP y Aciertos
            Row(
              children: [
                // Reloj con alerta roja en <=10s
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUrgent
                          ? const Color(0xFFE53935)
                          : const Color(0xFFCE93D8),
                      width: isUrgent ? 1.8 : 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: isUrgent
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF7B1FA2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${remainingSeconds}s',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isUrgent
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF7B1FA2),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Aciertos
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$correctCount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // XP acumulada
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$accumulatedXp XP',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
