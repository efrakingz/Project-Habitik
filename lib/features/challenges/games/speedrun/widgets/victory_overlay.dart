import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/speedrun_game.dart';

class VictoryOverlay extends StatefulWidget {
  final SpeedrunGame game;
  const VictoryOverlay({super.key, required this.game});

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    // Reproducir confeti inmediatamente al montar la pantalla
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    
    // Formatear duración de la ducha
    final durationMinutes = (game.showerDurationSeconds / 60).floor();
    final durationSeconds = (game.showerDurationSeconds % 60).floor();
    final durationStr = "${durationMinutes}m ${durationSeconds.toString().padLeft(2, '0')}s";



    return Stack(
      alignment: Alignment.center,
      children: [
        // Fondo semi-transparente oscuro
        Container(
          color: Colors.black.withValues(alpha: 0.7),
        ),

        // Emisor de Confeti en la parte superior central
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF059669), // Green 600
              Color(0xFF34D399), // Green 400
              Color(0xFFF59E0B), // Gold / Amber
              Color(0xFF00E5FF), // Cyan
              Color(0xFF10B981), // Emerald
              Color(0xFFFBBF24), // Amber Accent
            ],
          ),
        ),

        // Tarjeta de Victoria
        // Tarjeta de Victoria
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
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono e insignia de victoria
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              game.tierBadge.isNotEmpty ? game.tierBadge : "🏆",
                              style: const TextStyle(fontSize: 48),
                            )
                                .animate()
                                .scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.elasticOut),
                          ],
                        ),
                        const SizedBox(height: 16),
        
                        // Título
                        Text(
                          game.tierTitulo.isNotEmpty ? game.tierTitulo : "¡DUCHA COMPLETADA!",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF2E7D32),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 6),
                        
                        Text(
                          game.tierDesempeno.isNotEmpty
                              ? game.tierDesempeno
                              : "¡Lograste bañarte en tiempo récord!",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF546E7A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
        
                        const Divider(height: 1),
                        const SizedBox(height: 20),
        
                        // Datos de la ducha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCol("TIEMPO TOTAL", durationStr, Icons.timer_outlined, Colors.blue),
                            _buildStatCol("ESTADO", "Válido", Icons.check_circle_outline_rounded, Colors.green),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
        
                        const SizedBox(height: 24),
        
                        // Caja de Recompensas Escalonadas
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFC8E6C9), width: 1.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "RECOMPENSAS DEL RETO",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF2E7D32),
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
                                    "+${game.earnedXp > 0 ? game.earnedXp : 200} XP",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1B5E20),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  const Text("🪙", style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "+${game.earnedMonedas} Monedas",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFB58D14),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              if (game.bonusConstancia) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFFE082)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("🎁", style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Bonus Constancia: +30 XP · +5 🪙",
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFE65100),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "¡Recompensas sumadas a tu perfil!",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF2E7D32),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0.0),
        
                        const SizedBox(height: 24),
        
                        // Botón Entendido / Salir
                        GestureDetector(
                          onTap: () {
                            game.closeGame();
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
                ),
              ),
            );
          }
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
      ],
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
