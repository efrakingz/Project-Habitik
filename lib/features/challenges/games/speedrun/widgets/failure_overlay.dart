import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

class FailureOverlay extends StatelessWidget {
  final SpeedrunGame game;
  const FailureOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SpeedrunState>(
      valueListenable: game.gameStateNotifier,
      builder: (context, state, child) {
        if (state != SpeedrunState.failure) {
          return const SizedBox.shrink();
        }

        final durationMinutes = (game.showerDurationSeconds / 60).floor();
        final durationSeconds = (game.showerDurationSeconds % 60).floor();
        final durationStr = "${durationMinutes}m ${durationSeconds.toString().padLeft(2, '0')}s";

        final bool isTooShort = game.failureReason == ShowerFailureReason.tooShort ||
            game.showerDurationSeconds < 180.0;

        final Color primaryColor = isTooShort ? const Color(0xFFD97706) : const Color(0xFFDC2626);
        final Color cardBorderColor = isTooShort
            ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
            : const Color(0xFFEF4444).withValues(alpha: 0.4);
        final Color reliefColor = isTooShort ? const Color(0xFFFDE68A) : const Color(0xFFFECACA);

        return Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48.0,
                  ),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: cardBorderColor, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: reliefColor,
                            blurRadius: 0,
                            offset: const Offset(0, 5), // Relieve 3D inferior
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icono animado con halo
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: isTooShort ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cardBorderColor, width: 1.5),
                                ),
                              ),
                              isTooShort
                                  ? const Icon(Icons.timer_off_rounded, color: Color(0xFFD97706), size: 48)
                                  : const GameChallengeIcon(challengeId: 'ducha', size: 48)
                                  .animate()
                                  .scale(
                                    begin: const Offset(0.0, 0.0),
                                    end: const Offset(1.0, 1.0),
                                    duration: 500.ms,
                                    curve: Curves.elasticOut,
                                  ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Título
                          Text(
                            isTooShort ? "¡DUCHA INCOMPLETA!" : "¡DUCHA EXCESIVA!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 6),

                          Text(
                            isTooShort
                                ? "Tu ducha duró solo $durationStr. El reto exige al menos 3 minutos para registrarse."
                                : "Te tardaste más de 10 minutos. Cuidar el agua es un hábito diario.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: HabitikColors.textMid,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 18),

                          // Métricas
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCol("TU TIEMPO", durationStr, Icons.timer_rounded, primaryColor),
                                Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                _buildStatCol(
                                  "ESTADO",
                                  isTooShort ? "No válida" : "Excesiva",
                                  isTooShort ? Icons.timer_off_rounded : Icons.warning_amber_rounded,
                                  primaryColor,
                                ),
                                Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                _buildStatCol("RECOMPENSA", "0 XP", Icons.stars_rounded, HabitikColors.textLight),
                              ],
                            ),
                          ).animate().fadeIn(delay: 250.ms),
                          const SizedBox(height: 18),

                          // Consejo ecológico constructivo
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isTooShort ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isTooShort ? const Color(0xFFFDE68A) : const Color(0xFFFECACA),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isTooShort ? "¿POR QUÉ OCURRIÓ ESTO?" : "¿SABÍAS ESTO?",
                                  style: GoogleFonts.outfit(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isTooShort
                                      ? "Para asegurar un aseo adecuado y evitar registros falsos, la ducha requiere un mínimo de 3 minutos. ¡Inténtalo en tu próximo baño!"
                                      : "Una ducha estándar gasta entre 12 y 15 litros por minuto. Acortarla a menos de 5 o 8 minutos ahorra decenas de litros en tu hogar.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: isTooShort ? const Color(0xFF92400E) : const Color(0xFF991B1B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 300.ms),

                          const SizedBox(height: 22),

                          // Botón Reintentar Chunky 3D
                          GestureDetector(
                            onTap: () {
                              game.gameState = SpeedrunState.preparing;
                            },
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isTooShort
                                      ? const [Color(0xFFF59E0B), Color(0xFFD97706)]
                                      : const [Color(0xFFEF4444), Color(0xFFDC2626)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: isTooShort ? const Color(0xFFB45309) : const Color(0xFF991B1B),
                                    offset: const Offset(0, 4), // Relieve 3D inferior
                                    blurRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                "VOLVER A INTENTAR",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Botón Salir Relieve
                          GestureDetector(
                            onTap: () {
                              game.closeGame();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFCBD5E1),
                                    offset: Offset(0, 3), // Relieve 3D
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                "Salir a Retos",
                                style: GoogleFonts.outfit(
                                  color: HabitikColors.textMid,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCol(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: HabitikColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: HabitikColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
