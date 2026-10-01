import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import 'package:habitik/shared/widgets/effects/effects.dart';

/// Overlay de victoria del Eco-Wordle.
/// Replica la estética y estructura exacta del VictoryOverlay de EcoPuzzle.
class WordleVictoryOverlay extends StatelessWidget {
  final int intentosUsados;
  final int maxIntentos;
  final String? pistaEducativa;
  final Map<String, dynamic>? recompensas;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  const WordleVictoryOverlay({
    super.key,
    required this.intentosUsados,
    required this.maxIntentos,
    this.pistaEducativa,
    this.recompensas,
    required this.onContinue,
    required this.onClose,
  });

  int _calculateStars() {
    if (intentosUsados <= 2) return 3;
    if (intentosUsados <= 4) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final stars = _calculateStars();
    final xp = recompensas?['xp'] as int? ?? 100;
    final monedas = recompensas?['monedas'] as int? ?? 2;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Sombra ambiental
        Container(color: Colors.black.withValues(alpha: 0.45)),

        // Confetti
        const CelebrationConfetti(),

        // Tarjeta principal
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.22),
                      blurRadius: 36,
                      offset: const Offset(0, 14),
                    ),
                    const BoxShadow(
                      color: Color(0xFFD1FAE5),
                      blurRadius: 0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── 1. Trofeo ──
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEF3C7),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          "🏆",
                          style: TextStyle(fontSize: 54),
                        ).animate().scale(
                          begin: const Offset(0.0, 0.0),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── 2. Estrellas ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isEarned = index < stars;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            isEarned ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isEarned ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                            size: index == 1 ? 40 : 32,
                          )
                              .animate(delay: (200 + index * 150).ms)
                              .scale(
                                begin: const Offset(0, 0),
                                end: const Offset(1, 1),
                                duration: 400.ms,
                                curve: Curves.elasticOut,
                              ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // Título
                    Text(
                      stars == 3 ? "¡PUNTUACIÓN PERFECTA!" : "¡PALABRA ADIVINADA!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: HabitikColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 4),
                    Text(
                      stars == 3
                          ? "¡Adivinaste la palabra en los primeros intentos!"
                          : "¡Descubriste la palabra ecológica del día!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF059669),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 18),

                    // ── 3. Stats ──
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "INTENTOS",
                            "$intentosUsados/$maxIntentos",
                            Icons.edit_rounded,
                            const Color(0xFF0284C7),
                            const Color(0xFFF0F9FF),
                            const Color(0xFFBAE6FD),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "ESTRELLAS",
                            "$stars/3 ⭐",
                            Icons.star_rounded,
                            const Color(0xFFF59E0B),
                            const Color(0xFFFFFBEB),
                            const Color(0xFFFDE68A),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0.0),

                    const SizedBox(height: 14),

                    // Eco-dato educativo
                    if (pistaEducativa != null)
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
                            const Text("🌿", style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pistaEducativa!,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 18),

                    // ── 4. Cofre de Recompensas ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "RECOMPENSAS OBTENIDAS",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFB45309),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const GameStarIcon(size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "+$xp XP",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF047857),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const GameCoinIcon(size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "+$monedas Monedas",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFB45309),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const GameFireIcon(size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "+1 Racha",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFEA580C),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 22),

                    // ── 5. Botón Continuar ──
                    GestureDetector(
                      onTap: onContinue,
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
                            ),
                          ],
                        ),
                        child: Text(
                          "¡RECLAMAR Y CONTINUAR! ✨",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón secundario para volver
                    TextButton(
                      onPressed: onClose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            "Volver a desafíos",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ).animate().fadeIn(duration: 450.ms).scale(begin: const Offset(0.92, 0.92)),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: iconColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: HabitikColors.textDark,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
