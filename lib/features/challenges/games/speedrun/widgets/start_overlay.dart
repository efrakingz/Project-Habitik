import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

class StartOverlay extends StatelessWidget {
  final SpeedrunGame game;
  const StartOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35), // Sombra suave para enfocar la tarjeta igual que EcoPuzzle
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
                        // Fila superior unificada estilo Habitik
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
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                              onPressed: () => game.closeGame(),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Tarjeta blanca limpia estilo videojuego casual Habitik 3D
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              const BoxShadow(
                                color: Color(0xFFBAE6FD),
                                blurRadius: 0,
                                offset: Offset(0, 5), // Relieve 3D inferior característico
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono de reto con halo circular y microanimación
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE0F2FE),
                                      border: Border.all(
                                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const GameChallengeIcon(
                                    challengeId: 'ducha',
                                    size: 44,
                                  )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .scale(
                                        begin: const Offset(0.92, 0.92),
                                        end: const Offset(1.08, 1.08),
                                        duration: 1200.ms,
                                        curve: Curves.easeInOut,
                                      ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Speedrun de la Ducha",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: HabitikColors.textDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "¡Controla tu tiempo bajo el agua y ahorra recursos!",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0284C7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Instrucciones detalladas en tarjetas limpias
                              _buildInstructionCard(
                                icon: Icons.play_arrow_rounded,
                                iconColor: const Color(0xFF0EA5E9),
                                bgColor: const Color(0xFFF0F9FF),
                                text: "Inicia el cronómetro justo antes de abrir la llave de la ducha.",
                              ),
                              const SizedBox(height: 8),
                              _buildInstructionCard(
                                icon: Icons.lock_clock_rounded,
                                iconColor: const Color(0xFF0284C7),
                                bgColor: const Color(0xFFE0F2FE),
                                text: "El botón para finalizar la ducha se desbloqueará a los 3 minutos.",
                              ),
                              const SizedBox(height: 8),
                              _buildInstructionCard(
                                icon: Icons.timer_rounded,
                                iconColor: const Color(0xFF10B981),
                                bgColor: const Color(0xFFECFDF5),
                                text: "¡Termina antes de los 10 minutos para superar el reto y ganar XP!",
                              ),

                              const SizedBox(height: 18),

                              // Caja de recompensas gamificadas (estilo cofre/premio)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("🏆", style: TextStyle(fontSize: 14)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "RECOMPENSAS POR DESEMPEÑO",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF92400E),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildTierRow("3 a 5 min (Récord Óptimo)", "+200 XP · +2 🪙", const Color(0xFFB45309)),
                                    const SizedBox(height: 4),
                                    _buildTierRow("5 a 8 min (Intermedio)", "+100 XP · +1 🪙", const Color(0xFFD97706)),
                                    const SizedBox(height: 4),
                                    _buildTierRow("8 a 10 min (Extendido)", "+50 XP", const Color(0xFFF59E0B)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

                        const Spacer(),

                        // Botón Chunky 3D con relieve para Empezar
                        GestureDetector(
                          onTap: () => game.gameState = SpeedrunState.confirming,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF0369A1),
                                  offset: Offset(0, 4), // Relieve 3D inferior del botón
                                  blurRadius: 0,
                                ),
                                BoxShadow(
                                  color: Color(0x440284C7),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.water_drop_rounded, color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  "EMPEZAR DUCHA",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.025, 1.025), duration: 800.ms, curve: Curves.easeInOut),

                        const SizedBox(height: 12),
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

  Widget _buildInstructionCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: HabitikColors.textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow(String title, String reward, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFF78350F),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          reward,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
