import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

/// Overlay de pantalla de carga previa para la Trivia Ecológica.
/// Ambientada con la estética y paleta violeta/púrpura de la Trivia de Habitik,
/// manteniendo la estructura visual idéntica a los otros juegos.
class TriviaLoadingOverlay extends StatefulWidget {
  final VoidCallback onLoadingComplete;
  final VoidCallback onClose;
  final Duration loadingDuration;

  const TriviaLoadingOverlay({
    super.key,
    required this.onLoadingComplete,
    required this.onClose,
    this.loadingDuration = const Duration(milliseconds: 2200),
  });

  @override
  State<TriviaLoadingOverlay> createState() => _TriviaLoadingOverlayState();
}

class _TriviaLoadingOverlayState extends State<TriviaLoadingOverlay> {
  late final Timer _tipTimer;
  Timer? _completeTimer;
  int _currentTipIndex = 0;

  final List<String> _ecoTips = [
    "Responder preguntas ecológicas en familia refuerza hábitos sostenibles en casa.",
    "Cada acierto en la trivia demuestra tu compromiso con la protección del planeta.",
    "Ahorrar energía apagando luces innecesarias reduce directamente la huella de carbono.",
    "El 80% de los residuos marinos provienen de tierra firme; cada acción cotidiana cuenta.",
    "Aprender sobre biodiversidad ayuda a proteger polinizadores y ecosistemas locales.",
  ];

  @override
  void initState() {
    super.initState();
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _ecoTips.length;
        });
      }
    });

    _completeTimer = Timer(widget.loadingDuration, () {
      if (mounted) {
        widget.onLoadingComplete();
      }
    });
  }

  @override
  void dispose() {
    _tipTimer.cancel();
    _completeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Fondo Escénico con Ambiente Púrpura / Cósmico de Trivia ──
        Positioned.fill(
          child: const _TriviaCosmicSceneryBackground(),
        ),

        // ── 2. Velo translúcido para contraste ──
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.32),
          ),
        ),

        // ── 3. Contenido Principal (Header + Tarjeta Central) ──
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // ── Fila Superior con Título y Botón Cerrar ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 48),
                              Text(
                                "🌱 HABITIK RETOS",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: widget.onClose,
                              ),
                            ],
                          ),

                          const Spacer(),

                          // ── Tarjeta Blanca con Acento Temático Púrpura de Trivia ──
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFAB47BC).withValues(alpha: 0.35),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6A1B9A).withValues(alpha: 0.22),
                                  blurRadius: 32,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icono animado de Trivia con aura púrpura
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 78,
                                      height: 78,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFF3E5F5),
                                        border: Border.all(
                                          color: const Color(0xFFCE93D8).withValues(alpha: 0.6),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    const GameChallengeIcon(
                                      challengeId: 'trivia',
                                      size: 44,
                                    )
                                        .animate(onPlay: (c) => c.repeat(reverse: true))
                                        .scale(
                                          begin: const Offset(0.92, 0.92),
                                          end: const Offset(1.08, 1.08),
                                          duration: 1200.ms,
                                          curve: Curves.easeInOut,
                                        ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Título del juego
                                Text(
                                  "Eco-Trivia",
                                  style: GoogleFonts.outfit(
                                    color: HabitikColors.textDark,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subtítulo con color temático púrpura
                                Text(
                                  "Preparando el desafío de preguntas...",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF7B1FA2),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Barra de Progreso Púrpura Animada
                                Container(
                                  width: double.infinity,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6A1B9A),
                                              Color(0xFFAB47BC),
                                              Color(0xFFE040FB),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      )
                                          .animate(onPlay: (c) => c.repeat())
                                          .custom(
                                            duration: 1400.ms,
                                            builder: (context, value, child) {
                                              return FractionallySizedBox(
                                                widthFactor: value,
                                                child: child,
                                              );
                                            },
                                          ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Tarjeta de Eco-Dato Familiar con tono suave lavanda
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF5FF),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFE9D5FF),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.lightbulb_rounded,
                                            color: Color(0xFFF59E0B),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "ECO-DATO FAMILIAR",
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF6B21A8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        child: Text(
                                          _ecoTips[_currentTipIndex],
                                          key: ValueKey<int>(_currentTipIndex),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                            color: HabitikColors.textDark,
                                            fontSize: 13,
                                            height: 1.4,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Indicador inferior con texto y spinner púrpura
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF8E24AA),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Cargando desafío...",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF4B5563),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Fondo escénico con la atmósfera púrpura de Trivia:
/// Degradado cósmico / crepúsculo de conocimiento con orbe brillante, destellos y símbolos flotantes.
class _TriviaCosmicSceneryBackground extends StatelessWidget {
  const _TriviaCosmicSceneryBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1035), // Púrpura profundo nocturno
            Color(0xFF2E1065), // Índigo místico
            Color(0xFF4A154B), // Violeta cálido
            Color(0xFF5B21B6), // Amatista
            Color(0xFF260D3E), // Base oscura
          ],
          stops: [0.0, 0.3, 0.6, 0.85, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Orbe de sabiduría radiante en la esquina superior derecha
          Positioned(
            top: 50,
            right: 35,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFF80AB),
                    Color(0xFFE040FB),
                    Color(0xFF7C3AED),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE040FB).withValues(alpha: 0.55),
                    blurRadius: 36,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Halos de luz y estrellas sutiles en el fondo
          Positioned(
            top: 130,
            left: 30,
            child: Text(
              "✨",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.3, end: 0.85, duration: 1600.ms),
          ),
          Positioned(
            top: 240,
            right: 45,
            child: Text(
              "⚡",
              style: TextStyle(
                fontSize: 20,
                color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.15, 1.15), duration: 2000.ms),
          ),
          Positioned(
            bottom: 220,
            left: 40,
            child: Text(
              "💡",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.25, end: 0.75, duration: 1800.ms),
          ),
          Positioned(
            bottom: 280,
            right: 25,
            child: Text(
              "🌱",
              style: TextStyle(
                fontSize: 22,
                color: const Color(0xFF69F0AE).withValues(alpha: 0.5),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.1, 1.1), duration: 2200.ms),
          ),

          // Nubes estilizadas violetas
          Positioned(
            top: 150,
            left: 20,
            child: Container(
              width: 140,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            top: 230,
            right: 20,
            child: Container(
              width: 170,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // Resplandor inferior amatista
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF4A148C).withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
