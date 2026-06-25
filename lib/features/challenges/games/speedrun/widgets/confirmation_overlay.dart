import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

class ConfirmationOverlay extends StatelessWidget {
  final SpeedrunGame game;
  const ConfirmationOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6), // Sombra de fondo
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de campana/alerta familiar
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.notification_important_rounded,
                    color: Color(0xFFFF9800),
                    size: 38,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
              const SizedBox(height: 16),
              
              // Título
              Text(
                "¿Listo para bañarte?",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F2B48),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              
              // Explicación
              Text(
                "Tendrás 30 segundos para entrar a la ducha. Después, el cronómetro empezará a subir y no podrás detenerlo hasta secarte las manos.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF546E7A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              
              // Alerta de notificación familiar (Solicitado por el usuario)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE0B2), width: 1.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("📢", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "¡Les llegará una notificación a toda la familia de que te estás bañando!",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE65100),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botón Sí
              GestureDetector(
                onTap: () {
                  // Iniciar la preparación (30 segundos para entrar)
                  game.gameState = SpeedrunState.preparing;
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00ACC1), Color(0xFF00838F)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00ACC1).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Text(
                    "¡SÍ, EMPEZAR DUCHA!",
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
              
              // Botón Cancelar
              GestureDetector(
                onTap: () {
                  game.gameState = SpeedrunState.start;
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
                    "No, todavía no",
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
      ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }
}
