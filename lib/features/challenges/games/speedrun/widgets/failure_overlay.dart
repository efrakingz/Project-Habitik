import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

class FailureOverlay extends StatelessWidget {
  final SpeedrunGame game;
  const FailureOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Formatear duración final de la ducha excesiva
    final durationMinutes = (game.showerDurationSeconds / 60).floor();
    final durationSeconds = (game.showerDurationSeconds % 60).floor();
    final durationStr = "${durationMinutes}m ${durationSeconds.toString().padLeft(2, '0')}s";



    return Container(
      color: Colors.black.withValues(alpha: 0.75), // Fondo sombreado
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono triste / de alerta
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEEBEE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    "🚿⚠️",
                    style: TextStyle(fontSize: 36),
                  )
                      .animate()
                      .scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.elasticOut),
                ],
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                "¡DUCHA EXCESIVA!",
                style: GoogleFonts.outfit(
                  color: const Color(0xFFC62828),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              
              Text(
                "Te tardaste más de los 4 minutos recomendados.",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF546E7A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),

              const Divider(height: 1),
              const SizedBox(height: 16),

              // Estadísticas de consumo excesivo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCol("TU TIEMPO", durationStr, Icons.timer_rounded, Colors.redAccent),
                ],
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 16),

              // Mensaje ecológico reflexivo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 1.0),
                ),
                child: Column(
                  children: [
                    Text(
                      "¿SABÍAS QUÉ?",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFC62828),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Para una ducha verdaderamente sostenible, el tiempo límite óptimo es de 4 minutos. Cada minuto adicional gasta unos 12 litros de agua limpia.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFC62828),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Botones de acción
              GestureDetector(
                onTap: () {
                  // Volver a la preparación
                  game.gameState = SpeedrunState.preparing;
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC62828), Color(0xFFE53935)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC62828).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
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
              const SizedBox(height: 10),
              
              GestureDetector(
                onTap: () {
                  game.closeGame();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.0),
                  ),
                  child: Text(
                    "Salir al mapa",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF546E7A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
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
