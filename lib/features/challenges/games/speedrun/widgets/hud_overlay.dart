import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Alertas flotantes interactivas en coordenadas de toque
  final List<FloatingMessage> _floatingMessages = [];

  bool get isSolved => widget.game.elapsedShowerSeconds >= 180.0;

  @override
  void initState() {
    super.initState();
    widget.game.onWarning = _showWarning;
    // Reconstruir la interfaz para actualizar el temporizador
    _rebuildTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
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
          text: "⚠️ ¡Acción inválida! Concéntrate en la ducha",
          createdAt: DateTime.now(),
        ),
      );
    });
    
    // Remover después de 1 segundo de forma automática
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _floatingMessages.removeWhere((msg) => 
            DateTime.now().difference(msg.createdAt).inMilliseconds >= 1000);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final state = game.gameState;

    // 1. MODO PREPARACIÓN (Cuenta regresiva de 30 segundos)
    if (state == SpeedrunState.preparing) {
      final prepSeconds = game.prepRemainingSeconds.ceil();
      return Container(
        color: const Color(0xFF0F2B48).withValues(alpha: 0.85),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ENTRA A LA DUCHA",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "¡Ponte cómodo y prepárate! El tiempo empezará a correr en:",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Círculo gigante con el tiempo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: game.prepRemainingSeconds / 30.0,
                        strokeWidth: 10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Text(
                      "$prepSeconds",
                      style: GoogleFonts.shareTechMono(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate(key: ValueKey<int>(prepSeconds))
                        .scale(begin: const Offset(0.8, 0.8), duration: 250.ms, curve: Curves.easeOutBack),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Botón omitir preparación
                GestureDetector(
                  onTap: () {
                    game.gameState = SpeedrunState.playing;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: Text(
                      "Omitir y empezar ya ⚡",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. MODO JUEGO ACTIVO (Temporizador en curso)
    final minutes = (game.elapsedShowerSeconds / 60).floor();
    final seconds = (game.elapsedShowerSeconds % 60).floor();
    final timeStr = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    
    // Color del temporizador: verde de 0 a 3 min, naranja de 3 a 4 min, rojo arriba de 4 min
    Color timerColor = Colors.greenAccent;
    if (game.elapsedShowerSeconds > 240.0) {
      timerColor = Colors.redAccent;
    } else if (game.elapsedShowerSeconds > 180.0) {
      timerColor = Colors.orangeAccent;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        if (state == SpeedrunState.playing) {
          _addFloatingMessage(details.localPosition);
        }
      },
      onPanDown: (details) {
        if (state == SpeedrunState.playing) {
          _addFloatingMessage(details.localPosition);
        }
      },
      child: Stack(
        children: [
          // Banner flotante de alerta superior (si intentan pulsar apagado bloqueado)
          if (_warningMessage.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      _warningMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().shake(duration: 300.ms),
                ),
              ),
            ),

          // 3. PANTALLA CENTRAL: Tarjeta con Ducha y Cronómetro Integrado
          if (state == SpeedrunState.playing)
            Center(
              child: GestureDetector(
                onTap: () {
                   // Capturar toques en la tarjeta también para mostrar el mensaje
                   // es mejor dejar que el GestureDetector padre lo maneje por HitTestBehavior.translucent
                },
                child: Container(
                  width: (game.size.x - 48.0).clamp(280.0, 340.0),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0D1B2A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono de ducha animado latiendo y vibrando
                      const Text("🚿", style: TextStyle(fontSize: 64))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1200.ms)
                          .shake(hz: 2, curve: Curves.easeInOut),
                      
                      const SizedBox(height: 16),
  
                      // Cronómetro digital gigante integrado en la tarjeta
                      Text(
                        timeStr,
                        style: GoogleFonts.shareTechMono(
                          color: timerColor,
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: timerColor,
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        "DUCHA EN CURSO",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF00E5FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "¡Báñate rápido! El botón se desbloqueará después de 3 minutos de ducha.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      
                      // Estado visual de bloqueo
                      AnimatedSwitcher(
                        duration: 300.ms,
                        child: Text(
                          isSolved 
                              ? "✨ ¡Botón Desbloqueado! ✨" 
                              : "🔒 Esperando 3 minutos...",
                          key: ValueKey<bool>(isSolved),
                          style: GoogleFonts.outfit(
                            color: isSolved ? Colors.greenAccent : Colors.orangeAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

          // 4. HUD Inferior: Controles de Apagado y Modo Programador
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón apagar ducha (Bloqueado/Desbloqueado según tiempo)
                  GestureDetector(
                    onTap: () {
                      if (isSolved) {
                        game.completeShower();
                      } else {
                        _showWarning("⚠️ ¡Aún no han pasado 3 minutos!");
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: isSolved
                            ? const LinearGradient(
                                colors: [Colors.green, Colors.greenAccent],
                              )
                            : LinearGradient(
                                colors: [Colors.grey.shade400, Colors.grey.shade500],
                              ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSolved ? Colors.white : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSolved
                                ? Colors.green.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: isSolved ? 16 : 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSolved 
                                ? Icons.check_circle_outline_rounded 
                                : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isSolved ? "APAGAR DUCHA" : "🔒 DUCHA EN PROGRESO",
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
                      .shake(duration: 400.ms)
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(0.97, 0.97),
                        duration: 100.ms,
                        curve: Curves.easeIn,
                      ),
                  
                  const SizedBox(height: 16),
                  
                  // Botón "Salir (Modo Programador)" para completar el juego instantáneamente
                  GestureDetector(
                    onTap: () {
                      game.gameState = SpeedrunState.success;
                      game.onChallengeCompleted?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        "Salir (Modo Programador)",
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. ALERTAS FLOTANTES DINÁMICAS (Toques del dedo)
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
                        color: Colors.redAccent.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
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
