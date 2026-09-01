import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import '../game/eco_puzzle_game.dart';

class StartOverlay extends StatelessWidget {
  final EcoPuzzleGame game;
  const StartOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Deja ver el fondo animado en Flame
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
                        // Fila superior con botón de salida
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48), // Espaciador para centrar el título
                            Text(
                              "🌍 HABITIK RETOS",
                              style: GoogleFonts.outfit(
                                color: HabitikColors.green600,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1.5,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF1B4965), size: 30),
                              onPressed: () => game.closeGame(),
                            ),
                          ],
                        ),
                        const Spacer(),
                        
                        // Tarjeta principal con la información del juego
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: HabitikColors.green600.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono y título
                              const Text(
                                "♻️",
                                style: TextStyle(fontSize: 54),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
                              const SizedBox(height: 12),
                              Text(
                                "Eco-Puzzle",
                                style: GoogleFonts.outfit(
                                  color: HabitikColors.green900,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Misión: Clasificar la basura en 59 segundos",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: HabitikColors.green600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Instrucciones detalladas
                              _buildInstructionRow(
                                Icons.touch_app_rounded,
                                "Arrastra los residuos al contenedor correcto.",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionRow(
                                Icons.timer_rounded,
                                "¡Tienes 59 segundos para completar el reto!",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionRow(
                                Icons.warning_rounded,
                                "Cuidado, solo tienes un máximo de 3 errores permitidos.",
                              ),
                              const SizedBox(height: 12),
                              _buildInstructionRow(
                                Icons.delete_outline_rounded,
                                "Orgánico (Verde) | Reciclable (Amarillo) | Inorgánico (Gris)",
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Recompensas estimadas
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: HabitikColors.green50,
                                  borderRadius: BorderRadius.circular(16),
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
                                        color: HabitikColors.green800,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("🏆", style: TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "150 XP",
                                          style: GoogleFonts.outfit(
                                            color: HabitikColors.green700,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("🪙", style: TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "2 Monedas",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFB58D14),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                        
                        const Spacer(),
                        
                        // Botón gigante para Empezar
                        GestureDetector(
                          onTap: () {
                            game.overlays.remove('Start');
                            game.overlays.add('HUD');
                            game.startGame();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [HabitikColors.green600, HabitikColors.green500],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: HabitikColors.green600.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Text(
                              "♻️ EMPEZAR RETO",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03), duration: 800.ms, curve: Curves.easeInOut),
                        
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: HabitikColors.green600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: const Color(0xFF1B4965),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
