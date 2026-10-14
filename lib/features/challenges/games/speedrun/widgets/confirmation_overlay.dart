import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/history_service.dart';
import 'package:habitik/core/services/session_service.dart';

class ConfirmationOverlay extends StatelessWidget {
  final SpeedrunGame game;
  const ConfirmationOverlay({super.key, required this.game});

  void _iniciarDuchaYNotificar(BuildContext context) async {
    final user = SessionService().currentUser;
    final familyId = user?.familyId;
    final nombre = (user?.nombre != null && user!.nombre.isNotEmpty)
        ? user.nombre
        : 'Un familiar';

    if (familyId != null && familyId.isNotEmpty) {
      HistoryService.enviarAlertaFamilia(
        familyId: familyId,
        usuarioId: user?.id,
        usuarioNombre: nombre,
        titulo: '🚿 ¡Hora de la Ducha!',
        mensaje: '¡$nombre ha comenzado a bañarse en modo Speedrun! Ahorrando agua en el hogar.',
        tipo: 'DUCHA_SPEEDRUN',
        visual: const {'icon': 'shower', 'color': '#00ACC1'},
        payload: {
          'juego': 'speedrun_ducha',
          'usuario_nombre': nombre,
          'iniciado_en': DateTime.now().toIso8601String(),
        },
      );
    }

    // Registrar inicio de la ducha en el servidor de forma autoritaria
    if (user?.id != null) {
      try {
        await ApiClient().post('/reto/ducha/iniciar', {
          'user_id': user!.id,
        });
      } catch (err) {
        debugPrint('Error notificando inicio de ducha al backend: $err');
      }
    }

    // Iniciar la preparación (30 segundos para entrar)
    game.gameState = SpeedrunState.preparing;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45), // Sombra de fondo estándar Habitik
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
                        offset: Offset(0, 5), // Relieve 3D inferior
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono con halo y microanimación
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              shape: BoxShape.circle,
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
                                duration: 1000.ms,
                                curve: Curves.easeInOut,
                              ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Título
                      Text(
                        "¿Listo para bañarte?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: HabitikColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Explicación
                      Text(
                        "Tendrás 30 segundos de preparación para entrar a la ducha. Luego el cronómetro correrá automáticamente.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: HabitikColors.textMid,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tarjeta de Alerta Familiar en vivo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Text("📢", style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "AVISO FAMILIAR",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF92400E),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Tu familia verá en el muro del hogar que estás ahorrando agua.",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF78350F),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Botón Primario Chunky 3D
                      GestureDetector(
                        onTap: () => _iniciarDuchaYNotificar(context),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF0369A1),
                                offset: Offset(0, 4), // Relieve 3D
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: Color(0x330284C7),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
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
                      const SizedBox(height: 12),

                      // Botón Secundario Relieve
                      GestureDetector(
                        onTap: () {
                          game.gameState = SpeedrunState.start;
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFCBD5E1),
                                offset: Offset(0, 3), // Relieve 3D inferior
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            "No, todavía no",
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
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.96, 0.96)),
    );
  }
}
