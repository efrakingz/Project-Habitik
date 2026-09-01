import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import '../game/eco_puzzle_game.dart';
import '../game/models/eco_puzzle_state.dart';

/// Barra superior HUD de videojuego casual (estilo Habitik 3D).
/// Barra unificada flotante con relieve, cronómetro con barra de tensión,
/// indicador de residuos con medidor de progreso, vidas con corazones animados y botón de pausa con confirmación.
class HudOverlay extends StatefulWidget {
  final EcoPuzzleGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late final Timer _rebuildTimer;
  int _lastErrors = 0;
  int _lastLostHeartIndex = -1;
  int _heartAnimKey = 0;

  @override
  void initState() {
    super.initState();
    _lastErrors = widget.game.errors;

    _rebuildTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      final currentErrors = widget.game.errors;
      if (currentErrors > _lastErrors) {
        setState(() {
          _lastLostHeartIndex = widget.game.maxErrors - currentErrors;
          _lastErrors = currentErrors;
          _heartAnimKey++;
        });
      } else if (currentErrors < _lastErrors) {
        setState(() {
          _lastErrors = currentErrors;
          _lastLostHeartIndex = -1;
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _rebuildTimer.cancel();
    super.dispose();
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                const BoxShadow(
                  color: Color(0xFFD1FAE5),
                  blurRadius: 0,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emblema superior
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEF3C7),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      width: 2.0,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "🚪",
                      style: TextStyle(fontSize: 38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  "¿SALIR DEL RETO?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: HabitikColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  "Si sales ahora perderás el progreso de clasificación actual y las recompensas.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Botón Primario: SEGUIR JUGANDO (3D)
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                        const BoxShadow(
                          color: Color(0xFF047857),
                          blurRadius: 0,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Text(
                      "CONTINUAR JUGANDO",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Botón Secundario: Salir
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    widget.game.closeGame();
                  },
                  child: Text(
                    "Salir de la partida",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFEF4444),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.92, 0.92)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EcoPuzzleState>(
      valueListenable: widget.game.gameStateNotifier,
      builder: (context, _, __) {
        if (widget.game.gameState != EcoPuzzleState.playing) {
          return const SizedBox.shrink();
        }

        final isTimeLow = widget.game.timeLeft <= 15.0;
        final progressRatio = (widget.game.correctlyClassified / widget.game.itemsToClassify).clamp(0.0, 1.0);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                // ── 1. Barra Unificada de Estado del Juego ──
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isTimeLow
                            ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                            : const Color(0xFF10B981).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isTimeLow
                              ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                              : const Color(0xFF059669).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        const BoxShadow(
                          color: Color(0xFFD1FAE5),
                          blurRadius: 0,
                          offset: Offset(0, 3), // Relieve 3D inferior
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ⏱️ Sección Cronómetro
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isTimeLow
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isTimeLow
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFA7F3D0),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                color: isTimeLow ? const Color(0xFFEF4444) : const Color(0xFF059669),
                                size: 19,
                              )
                                  .animate(target: isTimeLow ? 1 : 0)
                                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 300.ms),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.game.timeLeft.ceil()}s',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isTimeLow ? const Color(0xFFEF4444) : HabitikColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🎯 Sección Progreso con Barra de Llenado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('♻️', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.game.correctlyClassified}/${widget.game.itemsToClassify}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 54,
                                  height: 4.5,
                                  color: const Color(0xFFE2E8F0),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progressRatio,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF059669), Color(0xFF34D399)],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ❤️ Sección Vidas con Animación Reactiva
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              key: ValueKey<int>(_heartAnimKey),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: List.generate(widget.game.maxErrors, (index) {
                                  final hasHeart = index < (widget.game.maxErrors - widget.game.errors);
                                  final isJustLost = index == _lastLostHeartIndex;

                                  if (isJustLost) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.heart_broken_rounded,
                                            color: Color(0xFFEF4444),
                                            size: 20,
                                          )
                                              .animate(key: ValueKey('lost_$_heartAnimKey'))
                                              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.4, 1.4), duration: 250.ms, curve: Curves.easeOut)
                                              .fadeOut(delay: 200.ms, duration: 250.ms),
                                          const Icon(
                                            Icons.favorite_border_rounded,
                                            color: Color(0xFFCBD5E1),
                                            size: 18,
                                          ).animate().fadeIn(delay: 250.ms, duration: 200.ms),
                                        ],
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Icon(
                                      hasHeart ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: hasHeart ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                                      size: 18,
                                    ),
                                  );
                                }),
                              ),
                            ).animate(target: _heartAnimKey > 0 ? 1 : 0).shake(hz: 6, offset: const Offset(3.0, 0), duration: 300.ms),

                            // Badge flotante -1
                            if (_lastLostHeartIndex >= 0)
                              Positioned(
                                top: -16,
                                child: Text(
                                  "-1 💔",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFEF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                                    .animate(key: ValueKey('float_$_heartAnimKey'))
                                    .fadeIn(duration: 150.ms)
                                    .slideY(begin: 0.4, end: -0.6, duration: 600.ms, curve: Curves.easeOut)
                                    .fadeOut(delay: 350.ms, duration: 300.ms),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ── 2. Botón Redondo de Salida / Pausa con Diálogo de Confirmación ──
                GestureDetector(
                  onTap: _showExitConfirmationDialog,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        const BoxShadow(
                          color: Color(0xFFE2E8F0),
                          blurRadius: 0,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
