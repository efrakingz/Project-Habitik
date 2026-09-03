import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import '../../../../../core/services/session_service.dart';
import '../../../../../core/services/api_client.dart';
import '../game/eco_puzzle_game.dart';
import '../game/models/eco_puzzle_state.dart';

/// Modal de victoria rediseñado estilo videojuego casual (Habitik).
/// Incluye sistema de 3 Estrellas ⭐⭐⭐ según el desempeño, partículas de confetti,
/// desglose de recompensas en cofre dorado y botones de continuar / reintentar.
class VictoryOverlay extends StatefulWidget {
  final EcoPuzzleGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay> {
  bool isSubmitting = false;
  int? xpGanada;
  int? monedasGanadas;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    widget.game.gameStateNotifier.addListener(_onStateChange);
    if (widget.game.gameState == EcoPuzzleState.success) {
      _submitResult();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    widget.game.gameStateNotifier.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (widget.game.gameState == EcoPuzzleState.success &&
        !isSubmitting &&
        xpGanada == null) {
      _submitResult();
    }
  }

  Future<void> _submitResult() async {
    setState(() => isSubmitting = true);
    final user = SessionService().currentUser;
    try {
      if (user == null) {
        setState(() {
          xpGanada = 150;
          monedasGanadas = 2;
        });
        _confettiController.play();
        return;
      }

      final response = await ApiClient().post('/eco/completar', {
        'errores': widget.game.errors,
        'tiempo_segundos': (59.0 - widget.game.timeLeft).ceil(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['ok'] == true &&
            body['data'] != null &&
            body['data']['recompensas'] != null) {
          final recompensas = body['data']['recompensas'];
          setState(() {
            xpGanada = recompensas['xp_ganado'];
            monedasGanadas = recompensas['monedas_ganadas'];
          });

          _confettiController.play();

          await SessionService().updateRewardsAndXp(
            xp: recompensas['xp_total'] ?? user.xp,
            monedas: recompensas['monedas_total'] ?? user.monedas,
            nivel: recompensas['nivel_actual'] ?? user.nivel,
          );
        } else {
          setState(() {
            xpGanada = 150;
            monedasGanadas = 2;
          });
          await SessionService().updateRewardsAndXp(
            xp: user.xp + 150,
            monedas: user.monedas + 2,
          );
          _confettiController.play();
        }
      } else {
        setState(() {
          xpGanada = 150;
          monedasGanadas = 2;
        });
        await SessionService().updateRewardsAndXp(
          xp: user.xp + 150,
          monedas: user.monedas + 2,
        );
        _confettiController.play();
      }
    } catch (e) {
      debugPrint('Info EcoPuzzle: $e');
      setState(() {
        xpGanada = 150;
        monedasGanadas = 2;
      });
      await SessionService().updateRewardsAndXp(
        xp: (user?.xp ?? 0) + 150,
        monedas: (user?.monedas ?? 0) + 2,
      );
      _confettiController.play();
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  int _calculateStars() {
    final errors = widget.game.errors;
    if (errors == 0) return 3;
    if (errors <= 2) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcoPuzzleState>(
      valueListenable: widget.game.gameStateNotifier,
      builder: (context, _, __) {
        if (widget.game.gameState != EcoPuzzleState.success) {
          return const SizedBox.shrink();
        }

        final timeTaken = (59.0 - widget.game.timeLeft).ceil();
        final timeStr = "${timeTaken}s";
        final stars = _calculateStars();

        return Stack(
          alignment: Alignment.center,
          children: [
            // Sombra ambiental
            Container(color: Colors.black.withValues(alpha: 0.45)),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF10B981),
                  Color(0xFF34D399),
                  Color(0xFFF59E0B),
                  Color(0xFF3B82F6),
                  Color(0xFFEC4899),
                ],
              ),
            ),

            // Tarjeta Principal Rediseñada
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
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
                          color: const Color(
                            0xFF059669,
                          ).withValues(alpha: 0.22),
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
                        // ── 1. Trofeo con Sol Radiante ──
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
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.35),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.2),
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

                        // ── 2. Calificación de 3 Estrellas Gamificadas ⭐⭐⭐ ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isEarned = index < stars;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child:
                                  Icon(
                                        isEarned
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: isEarned
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFFCBD5E1),
                                        size: index == 1
                                            ? 40
                                            : 32, // Estrella del medio más grande
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
                          stars == 3
                              ? "¡PUNTUACIÓN PERFECTA!"
                              : "¡MISIÓN CUMPLIDA!",
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
                              ? "¡Separaste todos los residuos sin ningún error!"
                              : "¡Clasificaste los 10 residuos a tiempo!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF059669),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 250.ms),

                        const SizedBox(height: 18),

                        // ── 3. Tarjetas de Estadísticas (Tiempo y Precisión) ──
                        Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    "TIEMPO",
                                    timeStr,
                                    Icons.timer_outlined,
                                    const Color(0xFF0284C7),
                                    const Color(0xFFF0F9FF),
                                    const Color(0xFFBAE6FD),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    "ERRORES",
                                    "${widget.game.errors}/3",
                                    Icons.favorite_rounded,
                                    const Color(0xFFEF4444),
                                    const Color(0xFFFEF2F2),
                                    const Color(0xFFFECACA),
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.1, end: 0.0),

                        const SizedBox(height: 18),

                        // ── 4. Cofre de Recompensas Dorado ──
                        if (isSubmitting)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: CircularProgressIndicator(
                              color: Color(0xFF10B981),
                            ),
                          )
                        else if (xpGanada != null) ...[
                          Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFFBEB),
                                      Color(0xFFFEF3C7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.12),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const GameStarIcon(size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          "+$xpGanada XP",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF047857),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        const GameCoinIcon(size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          "+$monedasGanadas Monedas",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFB45309),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .scale(begin: const Offset(0.95, 0.95)),
                        ],

                        const SizedBox(height: 22),

                        // ── 5. Botón Gigante "¡CONTINUAR!" con Relieve ──
                        GestureDetector(
                          onTap: () {
                            widget.game.completeChallenge();
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
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                                const BoxShadow(
                                  color: Color(0xFF047857),
                                  blurRadius: 0,
                                  offset: Offset(0, 4), // Relieve 3D botón
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

                        // Botón secundario para Reintentar (por si quiere 3 estrellas)
                        TextButton(
                          onPressed: () {
                            widget.game.retry();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.replay_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Jugar de nuevo",
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
      },
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
