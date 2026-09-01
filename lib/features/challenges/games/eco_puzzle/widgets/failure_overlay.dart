import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/eco_puzzle_game.dart';
import '../game/models/eco_puzzle_state.dart';

/// Modal de derrota/reintento estilo Habitik 3D.
/// Proporciona resumen de progreso alcanzado, consejo motivacional y botón 3D de reintento inmediato.
class FailureOverlay extends StatelessWidget {
  final EcoPuzzleGame game;

  const FailureOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcoPuzzleState>(
      valueListenable: game.gameStateNotifier,
      builder: (context, _, __) {
        if (game.gameState != EcoPuzzleState.failure) {
          return const SizedBox.shrink();
        }

        final isTimeOut = game.timeLeft <= 0;
        final progressRatio = (game.correctlyClassified / game.itemsToClassify).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Fondo oscuro semitransparente
            Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                    const BoxShadow(
                      color: Color(0xFFFEE2E2),
                      blurRadius: 0,
                      offset: Offset(0, 5), // Relieve 3D inferior
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── 1. Emblema Central Animado ──
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                blurRadius: 18,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                        Text(
                          isTimeOut ? "⏱️" : "💔",
                          style: const TextStyle(fontSize: 46),
                        )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.10, 1.10), duration: 500.ms),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Título
                    Text(
                      isTimeOut ? "¡TIEMPO AGOTADO!" : "¡CASI LO LOGRAS!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFDC2626),
                        letterSpacing: 0.6,
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 6),

                    Text(
                      isTimeOut
                          ? "Se terminó el tiempo de 59 segundos. ¡Inténtalo de nuevo con mayor rapidez!"
                          : "Cometiste 3 errores clasificando los residuos. ¡La práctica hace al maestro!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 18),

                    // ── 2. Resumen de Progreso Alcanzado ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progreso alcanzado:",
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              Text(
                                "${game.correctlyClassified}/${game.itemsToClassify} residuos",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: double.infinity,
                              height: 7,
                              color: const Color(0xFFE2E8F0),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progressRatio,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 14),

                    // ── 3. Tarjeta de Eco-Consejo ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFA7F3D0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text("💡", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Tip: 🍎 Orgánico | ♻️ Botellas y latas | 🗑️ Pilas y no reciclables.",
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 22),

                    // ── 4. Botón Gigante 3D "INTENTAR DE NUEVO" ──
                    GestureDetector(
                      onTap: () {
                        game.retry();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF10B981)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                            const BoxShadow(
                              color: Color(0xFF047857),
                              blurRadius: 0,
                              offset: Offset(0, 4), // Relieve 3D
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "INTENTAR DE NUEVO",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón secundario
                    TextButton(
                      onPressed: () => game.closeGame(),
                      child: Text(
                        "Volver a los desafíos",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.92, 0.92)),
          ],
        );
      },
    );
  }
}
