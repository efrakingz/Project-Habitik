import 'package:flutter/material.dart';
import '../models/trivia_answer_result.dart';

class AnswerFeedbackBanner extends StatelessWidget {
  final TriviaAnswerResult result;
  final VoidCallback onContinue;

  const AnswerFeedbackBanner({
    super.key,
    required this.result,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF1F8E9) : const Color(0xFFFFF0F2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isCorrect
                ? const Color(0xFF66BB6A)
                : const Color(0xFFEF5350),
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera del resultado
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect
                        ? const Color(0xFF43A047)
                        : const Color(0xFFE53935),
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect
                            ? '¡Respuesta Correcta!'
                            : '¡Respuesta Incorrecta!',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: isCorrect
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFFB71C1C),
                        ),
                      ),
                      if (isCorrect && result.xpEarned > 0)
                        Text(
                          '+${result.xpEarned} XP ganada en ${result.timeSeconds}s',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        )
                      else if (!isCorrect)
                        const Text(
                          'Has perdido 1 vida ❤️',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC62828),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Explicación didáctica
            if (result.explanation.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFFC8E6C9)
                        : const Color(0xFFFFCDD2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.explanation,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF37474F),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botón de continuar
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect
                      ? const Color(0xFF388E3C)
                      : const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
