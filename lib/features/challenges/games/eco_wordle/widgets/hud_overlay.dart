import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/services/session_service.dart';
import '../game/eco_wordle_controller.dart';
import '../models/eco_wordle_state.dart';
import 'board.dart';
import 'keyboard.dart';

/// Overlay del HUD activo para EcoWordle.
/// Contiene el encabezado con monedas y pistas, el tablero y el teclado virtual.
class EcoWordleHudOverlay extends StatelessWidget {
  final EcoWordleController controller;
  final VoidCallback onClose;
  final VoidCallback? onChallengeCompleted;

  const EcoWordleHudOverlay({
    super.key,
    required this.controller,
    required this.onClose,
    this.onChallengeCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final user = SessionService().currentUser;
    final monedas = user?.monedas ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B492E), Color(0xFF255B3A), Color(0xFF183D26)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // ── Header Amigable ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Color(0xFF4ADE80), size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'EcoWordle',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                // Chip de monedas familiar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14301E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24), size: 18),
                      const SizedBox(width: 5),
                      Text(
                        '$monedas',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (controller.gameState == EcoWordleState.playing)
                  GestureDetector(
                    onTap: () => controller.buyHint(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: controller.pistaRevelada
                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                            : const Color(0xFFFEF3C7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: controller.pistaRevelada ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                          width: 1.2,
                        ),
                        boxShadow: [
                          if (!controller.pistaRevelada)
                            BoxShadow(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.pistaRevelada ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                            color: controller.pistaRevelada ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                            size: 18,
                          ),
                          if (!controller.pistaRevelada) ...[
                            const SizedBox(width: 4),
                            Text(
                              '3',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFBBF24),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24), size: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Pista revelada estilo tarjeta fresca ──
          if (controller.pistaRevelada && controller.pistaEducativa != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.pistaEducativa!,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF065F46),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Indicador de Intentos y Letras (Barra Familiar) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Intento ${controller.attempts.length + (controller.gameState == EcoWordleState.playing ? 1 : 0)} de ${controller.maxIntentos}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Puntos de progreso amigables
                      Row(
                        children: List.generate(controller.maxIntentos, (i) {
                          final isDone = i < controller.attempts.length;
                          final isCurrent = i == controller.attempts.length && controller.gameState == EcoWordleState.playing;
                          return Container(
                            width: isCurrent ? 12 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : isCurrent
                                      ? const Color(0xFFFBBF24)
                                      : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${controller.largoPalabra} LETRAS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF86EFAC),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tablero Central con Marco Amigable ──
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143521).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: EcoWordleBoard(
                    rows: controller.maxIntentos,
                    cols: controller.largoPalabra,
                    attempts: controller.attempts,
                    currentAttempt: controller.currentAttempt,
                    evaluationMatrix: controller.evaluationMatrix,
                    currentRow: controller.attempts.length,
                  ),
                ),
              ),
            ),
          ),

          // ── Teclado Virtual ──
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 6, right: 6),
            child: EcoWordleKeyboard(
              letterStates: controller.keyboardState,
              onKeyPressed: controller.onKeyPressed,
              onBackspacePressed: controller.onBackspacePressed,
              onEnterPressed: () => controller.onEnterPressed(
                context,
                onChallengeCompleted: onChallengeCompleted,
              ),
              disabled: controller.gameState != EcoWordleState.playing || controller.isProcessing,
            ),
          ),
        ],
      ),
    );
  }
}
