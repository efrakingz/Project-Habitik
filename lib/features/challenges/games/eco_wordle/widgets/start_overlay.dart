import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

/// Overlay de inicio con instrucciones y recompensas del Eco-Wordle.
/// Replica la estética y estructura exacta del StartOverlay de EcoPuzzle.
class WordleStartOverlay extends StatelessWidget {
  final int largoPalabra;
  final int maxIntentos;
  final int intentosPrevios;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const WordleStartOverlay({
    super.key,
    required this.largoPalabra,
    required this.maxIntentos,
    this.intentosPrevios = 0,
    required this.onStart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Fila superior
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48),
                            Text(
                              "🌱 HABITIK RETOS",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 1.5,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                              onPressed: onClose,
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Tarjeta blanca
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669).withValues(alpha: 0.18),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE8F8F0),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const GameChallengeIcon(
                                    challengeId: 'wordle',
                                    size: 44,
                                  )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 1200.ms, curve: Curves.easeInOut),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Eco-Wordle",
                                style: GoogleFonts.outfit(
                                  color: HabitikColors.textDark,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "¡Adivina la palabra ecológica del día!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF059669),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Instrucciones
                              _buildInstructionRow(
                                Icons.text_fields_rounded,
                                "La palabra tiene $largoPalabra letras. Escríbela con el teclado virtual.",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionRow(
                                Icons.replay_rounded,
                                "Tienes $maxIntentos intentos para adivinar la palabra correcta.",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionRow(
                                Icons.palette_rounded,
                                "🟩 Verde = letra correcta | 🟨 Amarillo = otra posición | ⬜ Gris = no está.",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionRow(
                                Icons.lightbulb_outline_rounded,
                                "Compra una pista por 3 monedas si necesitas ayuda.",
                              ),

                              const SizedBox(height: 22),

                              // Caja de Recompensas
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                    width: 1.2,
                                  ),
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    Text(
                                      "Recompensa:",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF065F46),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const GameStarIcon(size: 17),
                                        const SizedBox(width: 6),
                                        Text(
                                          "100 XP",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF047857),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const GameCoinIcon(size: 17),
                                        const SizedBox(width: 6),
                                        Text(
                                          "4 Monedas",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFB45309),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Botón Empezar
                              GestureDetector(
                                onTap: onStart,
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
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    intentosPrevios > 0
                                        ? "CONTINUAR RETO ($intentosPrevios/$maxIntentos)"
                                        : "EMPEZAR RETO",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.92, 0.92)),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8F0),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF059669),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: const Color(0xFF334155),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
