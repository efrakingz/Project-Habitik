import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';

/// Overlay de derrota del Eco-Wordle.
/// Replica la estética y estructura exacta del FailureOverlay de EcoPuzzle.
class WordleFailureOverlay extends StatelessWidget {
  final int intentosUsados;
  final int maxIntentos;
  final String? pistaEducativa;
  final String? palabraCorrecta;
  final VoidCallback onClose;

  const WordleFailureOverlay({
    super.key,
    required this.intentosUsados,
    required this.maxIntentos,
    this.pistaEducativa,
    this.palabraCorrecta,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final progressRatio = (intentosUsados / maxIntentos).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Fondo oscuro semitransparente
        Container(color: Colors.black.withValues(alpha: 0.45)),

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
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── 1. Emblema Central ──
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
                    const Text(
                      "📝",
                      style: TextStyle(fontSize: 46),
                    )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.10, 1.10), duration: 500.ms),
                  ],
                ),
                const SizedBox(height: 14),

                // Título
                Text(
                  "¡CASI LO LOGRAS!",
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
                  "Agotaste los $maxIntentos intentos sin adivinar la palabra. ¡Mañana hay una nueva oportunidad!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 18),

                // ── Palabra Correcta Revelada ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.help_outline_rounded, color: Color(0xFFDC2626), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "LA PALABRA ERA",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF991B1B),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: (palabraCorrecta ?? 'BIOMA')
                            .toUpperCase()
                            .split('')
                            .map((char) => Container(
                                  width: 40,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: HabitikColors.green500,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: HabitikColors.green500.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    char,
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 220.ms).scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 14),

                // ── 2. Progreso Alcanzado ──
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
                            "Intentos usados:",
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          Text(
                            "$intentosUsados/$maxIntentos intentos",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFDC2626),
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
                                  colors: [Color(0xFFEF4444), Color(0xFFF87171)],
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

                // ── 3. Eco-Consejo / Pista ──
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
                          pistaEducativa ?? "Cada día hay una nueva palabra ecológica. ¡Sigue aprendiendo y mejorando!",
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

                // ── 4. Botón Volver ──
                GestureDetector(
                  onTap: onClose,
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
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "VOLVER A DESAFÍOS",
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
              ],
            ),
          ),
        ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.92, 0.92)),
      ],
    );
  }
}
