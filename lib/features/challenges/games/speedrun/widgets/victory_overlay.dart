import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/effects/effects.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

class VictoryOverlay extends StatelessWidget {
  final SpeedrunGame game;
  const VictoryOverlay({super.key, required this.game});

  int _calculateStars(double seconds) {
    if (seconds <= 300.0) return 3; // Óptimo (3 a 5 min)
    if (seconds <= 480.0) return 2; // Intermedio (5 a 8 min)
    return 1; // Extendido (8 a 10 min)
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SpeedrunState>(
      valueListenable: game.gameStateNotifier,
      builder: (context, state, child) {
        if (state != SpeedrunState.success) {
          return const SizedBox.shrink();
        }

        // Formatear duración de la ducha
        final durationMinutes = (game.showerDurationSeconds / 60).floor();
        final durationSeconds = (game.showerDurationSeconds % 60).floor();
        final durationStr = "${durationMinutes}m ${durationSeconds.toString().padLeft(2, '0')}s";

        final stars = _calculateStars(game.showerDurationSeconds);
        // Estimación ecológica: cada minuto recortado de los 10 min ahorra ~12 Litros
        final savedLiters = math.max(
          20,
          (((600.0 - game.showerDurationSeconds).clamp(0.0, 420.0)) / 60.0 * 12.0).round(),
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            // Sombra de fondo estándar Habitik
            Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),

            // Emisor de Confeti reutilizable
            const CelebrationConfetti(),

            // Tarjeta de Victoria Habitik 3D
            LayoutBuilder(
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
                              offset: Offset(0, 5), // Relieve 3D inferior
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── 1. Trofeo con Halo Radiante Dorado ──
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
                                Text(
                                  game.tierBadge.isNotEmpty ? game.tierBadge : "🏆",
                                  style: const TextStyle(fontSize: 50),
                                )
                                    .animate()
                                    .scale(
                                      begin: const Offset(0.0, 0.0),
                                      end: const Offset(1.0, 1.0),
                                      duration: 500.ms,
                                      curve: Curves.elasticOut,
                                    ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // ── 2. Calificación de 3 Estrellas Gamificadas ⭐⭐⭐ ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final isEarned = index < stars;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Icon(
                                    isEarned ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: isEarned ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                    size: index == 1 ? 42 : 34, // Estrella del medio más grande
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

                            // ── 3. Título y Desempeño ──
                            Text(
                              game.tierTitulo.isNotEmpty ? game.tierTitulo : "¡DUCHA COMPLETADA!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF047857),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ).animate().fadeIn(delay: 150.ms),
                            const SizedBox(height: 4),

                            Text(
                              game.tierDesempeno.isNotEmpty
                                  ? game.tierDesempeno
                                  : "¡Ahorraste agua bañándote en tiempo récord!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: HabitikColors.textMid,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ).animate().fadeIn(delay: 250.ms),
                            const SizedBox(height: 18),

                            // ── 4. Cuadrícula de Métricas Clave ──
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
                                  _buildStatCol(
                                    label: "TIEMPO",
                                    value: durationStr,
                                    icon: Icons.timer_outlined,
                                    color: const Color(0xFF0284C7),
                                  ),
                                  Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                  _buildStatCol(
                                    label: "AGUA AHORRADA",
                                    value: "~$savedLiters L",
                                    icon: Icons.water_drop_rounded,
                                    color: const Color(0xFF0EA5E9),
                                  ),
                                  Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                                  _buildStatCol(
                                    label: "ESTADO",
                                    value: "Válido",
                                    icon: Icons.verified_rounded,
                                    color: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 300.ms),
                            const SizedBox(height: 18),

                            // ── 5. Caja de Recompensas (Cofre Ámbar) ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("🎁", style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "RECOMPENSAS GANADAS",
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF92400E),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildRewardBadge(
                                        icon: "⚡",
                                        label: "+${game.earnedXp > 0 ? game.earnedXp : 200} XP",
                                        color: const Color(0xFFB45309),
                                      ),
                                      const SizedBox(width: 16),
                                      _buildRewardBadge(
                                        icon: "🪙",
                                        label: "+${game.earnedMonedas} Monedas",
                                        color: const Color(0xFFD97706),
                                      ),
                                    ],
                                  ),
                                  if (game.bonusConstancia) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFDE68A)),
                                      ),
                                      child: Text(
                                        "🌟 Bonus Constancia: +30 XP · +5 🪙",
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFB45309),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ).animate().fadeIn(delay: 350.ms),
                            const SizedBox(height: 22),

                            // ── 6. Botón Primario Chunky 3D ──
                            GestureDetector(
                              onTap: () {
                                game.completeChallenge();
                              },
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF047857), // Relieve 3D inferior
                                      offset: Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color(0x3310B981),
                                      blurRadius: 14,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("✨", style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      "RECLAMAR Y SALIR",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.025, 1.025),
                                  duration: 800.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.94, 0.94)),
          ],
        );
      },
    );
  }

  Widget _buildStatCol({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildRewardBadge({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
