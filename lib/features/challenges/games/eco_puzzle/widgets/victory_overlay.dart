import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import '../../../../../core/services/session_service.dart';
import '../../../../../core/services/api_client.dart';
import '../game/eco_puzzle_game.dart';
import '../game/models/eco_puzzle_state.dart';

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    widget.game.gameStateNotifier.addListener(_onStateChange);
    // If it's already in success state when built, submit it immediately
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
    if (widget.game.gameState == EcoPuzzleState.success && !isSubmitting && xpGanada == null) {
      _submitResult();
    }
  }

  Future<void> _submitResult() async {
    setState(() => isSubmitting = true);
    try {
      final user = SessionService().currentUser;
      if (user == null) return;

      // Enviamos también tiempo_segundos como requiere el backend en /eco/completar
      final response = await ApiClient().post('/eco/completar', {
        'user_id': user.id,
        'errores': widget.game.errors,
        'tiempo_segundos': (59.0 - widget.game.timeLeft).ceil(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['ok'] == true && body['data'] != null) {
          final data = body['data'];
          final recompensas = data['recompensas'];
          
          if (recompensas != null && recompensas['valido'] == true) {
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
            // Si el backend lo marcó inválido, mostramos 0
            setState(() {
              xpGanada = 0;
              monedasGanadas = 0;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error enviando EcoPuzzle al backend: $e');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
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

        return Stack(
          alignment: Alignment.center,
          children: [
            // Dark Overlay
            Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
            
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF059669),
                  Color(0xFF34D399),
                  Color(0xFFF59E0B),
                  Color(0xFF00E5FF),
                ],
              ),
            ),

            // Card
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: HabitikColors.green400.withValues(alpha: 0.5), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: HabitikColors.green500.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: HabitikColors.green50,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Text(
                              "🌍",
                              style: TextStyle(fontSize: 48),
                            )
                                .animate()
                                .scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.elasticOut),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          "¡ECO-PUZZLE COMPLETADO!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: HabitikColors.green800,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        
                        const SizedBox(height: 6),
                        
                        Text(
                          "¡Clasificaste los residuos correctamente!",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF546E7A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),

                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCol("TIEMPO", timeStr, Icons.timer_outlined, HabitikColors.blue500),
                            _buildStatCol("ERRORES", "${widget.game.errors}", Icons.warning_amber_rounded, Colors.orange),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                        
                        const SizedBox(height: 24),

                        if (isSubmitting)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(color: HabitikColors.green600),
                          )
                        else if (xpGanada != null) ...[
                          // Rewards Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: HabitikColors.green50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: HabitikColors.green100, width: 1.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "RECOMPENSAS OBTENIDAS",
                                  style: GoogleFonts.outfit(
                                    color: HabitikColors.green800,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("🏆", style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "+$xpGanada XP",
                                      style: GoogleFonts.outfit(
                                        color: HabitikColors.green900,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    const Text("🪙", style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "+$monedasGanadas Monedas",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFB58D14),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0.0),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        GestureDetector(
                          onTap: () {
                            widget.game.completeChallenge();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Text(
                              "¡ENTENDIDO!",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
          ],
        );
      },
    );
  }

  Widget _buildStatCol(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: const Color(0xFF0F2B48),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
