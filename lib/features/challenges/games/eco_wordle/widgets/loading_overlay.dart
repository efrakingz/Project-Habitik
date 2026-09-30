import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

/// Overlay de carga previo al inicio del Eco-Wordle.
/// Replica la estética y estructura exacta del LoadingOverlay de EcoPuzzle.
class WordleLoadingOverlay extends StatefulWidget {
  final VoidCallback onLoadingComplete;
  final VoidCallback onClose;

  const WordleLoadingOverlay({
    super.key,
    required this.onLoadingComplete,
    required this.onClose,
  });

  @override
  State<WordleLoadingOverlay> createState() => _WordleLoadingOverlayState();
}

class _WordleLoadingOverlayState extends State<WordleLoadingOverlay> {
  late final Timer _tipTimer;
  int _currentTipIndex = 0;

  final List<String> _ecoTips = [
    "Cada palabra ecológica que aprendes fortalece tu compromiso con el planeta.",
    "Reciclar una sola botella de aluminio ahorra suficiente energía para cargar un celular durante 20 horas.",
    "Los árboles absorben CO₂ y producen oxígeno: ¡un solo árbol puede absorber hasta 22 kg de CO₂ al año!",
    "Reducir el consumo de plásticos desechables es uno de los gestos más impactantes para el medio ambiente.",
    "El compostaje doméstico puede reducir los residuos del hogar hasta en un 30%.",
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

    // Auto-transición a la pantalla de inicio tras 2.2s
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        widget.onLoadingComplete();
      }
    });
  }

  @override
  void dispose() {
    _tipTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: SafeArea(
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
                        // ── 1. Fila Superior ──
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
                                    color: Colors.black45,
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                              onPressed: widget.onClose,
                            ),
                          ],
                        ),
                        const Spacer(),

                        // ── 2. Tarjeta Blanca ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669).withValues(alpha: 0.18),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono animado
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE8F8F0),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const GameChallengeIcon(
                                    challengeId: 'wordle',
                                    size: 44,
                                  )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 1200.ms, curve: Curves.easeInOut),
                                ],
                              ),
                              const SizedBox(height: 14),

                              Text(
                                "Eco-Wordle",
                                style: GoogleFonts.outfit(
                                  color: HabitikColors.textDark,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                "Preparando la palabra del día...",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF059669),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Barra de Progreso Esmeralda
                              Container(
                                width: double.infinity,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
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
                                            Color(0xFF059669),
                                            Color(0xFF10B981),
                                            Color(0xFF34D399),
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

                              // Tarjeta de Eco-Dato
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
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
                                            color: const Color(0xFF065F46),
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

                              // Indicador inferior
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Cargando desafío...",
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95)),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
