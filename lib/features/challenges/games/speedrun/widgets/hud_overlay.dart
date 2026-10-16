import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/modals/modals.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import '../game/speedrun_game.dart';
import '../game/models/speedrun_state.dart';

class FloatingMessage {
  final Offset position;
  final String text;
  final DateTime createdAt;
  FloatingMessage({
    required this.position,
    required this.text,
    required this.createdAt,
  });
}

class HudOverlay extends StatefulWidget {
  final SpeedrunGame game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late final Timer _rebuildTimer;
  bool _shakeButton = false;
  String _warningMessage = "";
  Timer? _warningTimer;

  final List<FloatingMessage> _floatingMessages = [];

  bool get isSolved => widget.game.elapsedShowerSeconds >= 180.0;

  @override
  void initState() {
    super.initState();
    widget.game.onWarning = _showWarning;
    widget.game.gameStateNotifier.addListener(_onGameStateChanged);

    _rebuildTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widget.game.gameState != SpeedrunState.preparing &&
          widget.game.gameState != SpeedrunState.playing) {
        timer.cancel();
        return;
      }
      setState(() {});
    });
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.game.gameStateNotifier.removeListener(_onGameStateChanged);
    widget.game.onWarning = null;
    _rebuildTimer.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  void _showWarning(String msg) {
    _warningTimer?.cancel();
    setState(() {
      _warningMessage = msg;
      _shakeButton = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _shakeButton = false;
        });
      }
    });

    _warningTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _warningMessage = "";
        });
      }
    });
  }

  void _addFloatingMessage(Offset localPosition) {
    if (widget.game.gameState != SpeedrunState.playing) return;

    setState(() {
      _floatingMessages.add(
        FloatingMessage(
          position: localPosition,
          text: "💧 ¡Concéntrate en la ducha!",
          createdAt: DateTime.now(),
        ),
      );
    });

    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _floatingMessages.removeWhere((msg) =>
              DateTime.now().difference(msg.createdAt).inMilliseconds >= 1000);
        });
      }
    });
  }

  void _showExitConfirmationDialog() async {
    final confirm = await HabitikConfirmDialog.show(
      context,
      title: '¿SALIR DE LA DUCHA?',
      description:
          'Si sales ahora perderás el registro de este speedrun y las recompensas de agua.',
      confirmLabel: 'SALIR DEL RETO',
      cancelLabel: 'SEGUIR EN LA DUCHA',
      icon: Icons.shower_rounded,
      isDestructive: true,
    );

    if (confirm && mounted) {
      widget.game.closeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final state = game.gameState;

    if (state != SpeedrunState.preparing && state != SpeedrunState.playing) {
      return const SizedBox.shrink();
    }

    // ─────────────────────────────────────────────────────────────
    // 1. MODO PREPARACIÓN (30 segundos) - Tarjeta limpia Habitik 3D
    // ─────────────────────────────────────────────────────────────
    if (state == SpeedrunState.preparing) {
      final prepSeconds = game.prepRemainingSeconds.ceil();
      final progress = (game.prepRemainingSeconds / 30.0).clamp(0.0, 1.0);

      return Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
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
                    // Badge circular
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const GameChallengeIcon(
                        challengeId: 'ducha',
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "ENTRA A LA DUCHA",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: HabitikColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "¡Ponte cómodo y abre la llave! El cronómetro empezará en:",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: HabitikColors.textMid,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Círculo grande con cuenta regresiva
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 9,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                            backgroundColor: const Color(0xFFE0F2FE),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$prepSeconds",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0284C7),
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                                .animate(key: ValueKey<int>(prepSeconds))
                                .scale(begin: const Offset(0.85, 0.85), duration: 250.ms, curve: Curves.easeOutBack),
                            Text(
                              "segundos",
                              style: GoogleFonts.outfit(
                                color: HabitikColors.textLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),

                    // Botón Chunky para Omitir y Empezar Ya
                    GestureDetector(
                      onTap: () {
                        game.gameState = SpeedrunState.playing;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFBAE6FD),
                              offset: Offset(0, 3), // Relieve 3D inferior
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("⚡", style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              "Omitir y empezar ya",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0284C7),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 2. MODO JUEGO ACTIVO (Cronómetro en marcha)
    // ─────────────────────────────────────────────────────────────
    final minutes = (game.elapsedShowerSeconds / 60).floor();
    final seconds = (game.elapsedShowerSeconds % 60).floor();
    final timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    // Colores semánticos según el tiempo transcurrido
    final isOver10 = game.elapsedShowerSeconds > 600.0;
    final isWarning = game.elapsedShowerSeconds > 480.0 && !isOver10;
    final isOptimal = isSolved && game.elapsedShowerSeconds <= 300.0;
    final isIntermediate = isSolved && game.elapsedShowerSeconds > 300.0 && game.elapsedShowerSeconds <= 480.0;

    final timerBgColor = isOver10
        ? const Color(0xFFFEF2F2)
        : (isWarning
            ? const Color(0xFFFFFBEB)
            : (isSolved ? const Color(0xFFF0FDF4) : const Color(0xFFF0F9FF)));

    final timerBorderColor = isOver10
        ? const Color(0xFFFCA5A5)
        : (isWarning
            ? const Color(0xFFFDE68A)
            : (isSolved ? const Color(0xFFA7F3D0) : const Color(0xFFBAE6FD)));

    final timerTextColor = isOver10
        ? const Color(0xFFDC2626)
        : (isWarning
            ? const Color(0xFFD97706)
            : (isSolved ? const Color(0xFF16A34A) : const Color(0xFF0284C7)));

    final gaugeProgress = (game.elapsedShowerSeconds / 600.0).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        if (state == SpeedrunState.playing) {
          _addFloatingMessage(details.localPosition);
        }
      },
      child: Stack(
        children: [
          // ── Barra Superior HUD Unificada Flotante (Estilo EcoPuzzle) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isOver10
                                ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                                : const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isOver10
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                  : const Color(0xFF0284C7).withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                            const BoxShadow(
                              color: Color(0xFFBAE6FD),
                              blurRadius: 0,
                              offset: Offset(0, 3), // Relieve 3D inferior
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ⏱️ Píldora del Cronómetro
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: timerBgColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: timerBorderColor, width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    color: timerTextColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.outfit(
                                      color: timerTextColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 💧 Píldora de Estado / Tier
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    !isSolved
                                        ? "🔒 Esperando 3 min"
                                        : (isOptimal
                                            ? "🏆 Óptimo"
                                            : (isIntermediate
                                                ? "🥈 Buen tiempo"
                                                : (isOver10 ? "⚠️ Límite superado" : "🥉 Extendido"))),
                                    style: GoogleFonts.outfit(
                                      color: HabitikColors.textDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Botón Circular de Salir / Pausar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFBAE6FD),
                            blurRadius: 0,
                            offset: Offset(0, 3), // Relieve 3D
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF0284C7), size: 24),
                        onPressed: _showExitConfirmationDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Banner de Alerta Flotante (si presiona antes de tiempo) ──
          if (_warningMessage.isNotEmpty)
            Positioned(
              top: 76,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33EF4444),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _warningMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().shake(duration: 300.ms),
                ),
              ),
            ),

          // ── Tarjeta Central: Eco-Gauge y Medidor Táctil ──
          Center(
            child: Container(
              width: (game.size.x - 48.0).clamp(280.0, 330.0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: timerBorderColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: timerBorderColor,
                    blurRadius: 0,
                    offset: const Offset(0, 5), // Relieve 3D inferior dinámico
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Anillo Eco-Gauge con gota animada
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: gaugeProgress,
                          strokeWidth: 9,
                          valueColor: AlwaysStoppedAnimation<Color>(timerTextColor),
                          backgroundColor: timerBgColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: timerBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: GameChallengeIcon(
                            challengeId: 'ducha',
                            size: 48,
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            end: const Offset(1.06, 1.06),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Cronómetro grande y limpio en Outfit
                  Text(
                    timeStr,
                    style: GoogleFonts.outfit(
                      color: timerTextColor,
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Pill con el estado del tiempo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: timerBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      !isSolved
                          ? "🔒 Esperando 3 minutos mínimos"
                          : (isOptimal
                              ? "🏆 ¡Récord Óptimo! (+200 XP · +2 🪙)"
                              : (isIntermediate
                                  ? "🥈 Tiempo Intermedio (+100 XP · +1 🪙)"
                                  : (isOver10
                                      ? "⚠️ Superó 10 min · ¡Cierra la llave!"
                                      : "🥉 Tiempo Extendido (+50 XP)"))),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: timerTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Consejo ecológico en vivo
                  Text(
                    isOver10
                        ? "Has superado los 10 minutos recomendados. Cierra la llave para evitar derroches."
                        : (isWarning
                            ? "Te estás acercando al límite de los 10 minutos. Es hora de terminar."
                            : (isSolved
                                ? "¡Meta de ahorro cumplida! Puedes apagar la ducha cuando gustes."
                                : "Ahorra agua enjabonándote con rapidez. El botón se habilitará en breve.")),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: HabitikColors.textMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.96, 0.96)),

          // ── Botón Inferior Chunky 3D para Finalizar Ducha ──
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isSolved) {
                        game.completeShower();
                      } else {
                        _showWarning("¡Aún no pasan los 3 minutos mínimos!");
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: isSolved
                            ? const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isSolved
                                ? const Color(0xFF047857) // Relieve 3D verde
                                : const Color(0xFF64748B), // Relieve 3D gris
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: isSolved
                                ? const Color(0x3310B981)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSolved ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSolved ? "¡LISTO, CERRÉ LA LLAVE!" : "DUCHA EN PROGRESO",
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
                      .animate(target: _shakeButton ? 1.0 : 0.0)
                      .shake(duration: 400.ms),

                  const SizedBox(height: 12),

                  // Botón discreto de prueba
                  GestureDetector(
                    onTap: () {
                      game.completeShower();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                      ),
                      child: Text(
                        "Finalizar ahora (Modo Prueba)",
                        style: GoogleFonts.outfit(
                          color: HabitikColors.textMid,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Alertas flotantes al tocar la pantalla ──
          ..._floatingMessages.map((msg) {
            return Positioned(
              left: msg.position.dx - 100,
              top: msg.position.dy - 20,
              child: IgnorePointer(
                child: SizedBox(
                  width: 200,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 150.ms)
                      .slideY(begin: 0.2, end: -0.6, duration: 800.ms, curve: Curves.easeOut)
                      .fadeOut(delay: 500.ms, duration: 300.ms),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
