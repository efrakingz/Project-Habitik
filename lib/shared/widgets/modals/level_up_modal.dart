import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/shared/widgets/effects/celebration_confetti.dart';

/// Modal interactivo y visualmente impactante al subir de nivel en Habitik
class LevelUpModal extends StatelessWidget {
  final int nivelAnterior;
  final int nivelNuevo;
  final int nivelesSubidos;
  final int monedasAcumuladas;
  final String tituloRango;

  const LevelUpModal({
    super.key,
    required this.nivelAnterior,
    required this.nivelNuevo,
    required this.nivelesSubidos,
    required this.monedasAcumuladas,
    required this.tituloRango,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Fondo de desenfoque oscuro
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withAlpha(190)),
            ),
          ),

          // 2. Confeti festivo lloviendo en pantalla completa
          const Positioned.fill(
            child: RepaintBoundary(
              child: CelebrationConfetti(
                autoPlay: true,
                duration: Duration(seconds: 4),
                numberOfParticles: 40,
              ),
            ),
          ),

          // 3. Tarjeta central de celebración
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF142B1D),
                    Color(0xFF0D1E14),
                    Color(0xFF08140D),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFF66BB6A).withAlpha(120),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withAlpha(150),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withAlpha(60),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emblema circular del nivel con resplandor dorado
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Anillo de brillo exterior
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFFFD54F),
                              Color(0xFF66BB6A),
                              Colors.transparent,
                            ],
                            stops: [0.2, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withAlpha(100),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1200.ms),

                      // Escudo central
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFEE58), Color(0xFFFFA000)],
                          ),
                          border: Border.all(color: Colors.white, width: 3.5),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'LVL',
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '$nivelNuevo',
                              style: const TextStyle(
                                color: Color(0xFF3E2723),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    '¡NIVEL ALCANZADO!',
                    style: TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 6),

                  // Título de Rango
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: Text(
                      tituloRango,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 16),

                  // Transición de Nivel (Pill)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A28),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF81C784).withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nivel $nivelAnterior',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFD54F), size: 16),
                        ),
                        Text(
                          'Nivel $nivelNuevo',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  // Alerta de niveles acumulados si subió más de 1 nivel
                  if (nivelesSubidos > 1) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100).withAlpha(60),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF9800).withAlpha(120)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            '¡Subiste +$nivelesSubidos niveles sin reclamar!',
                            style: const TextStyle(
                              color: Color(0xFFFFCC80),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).shake(delay: 500.ms, duration: 400.ms),
                  ],

                  const SizedBox(height: 20),

                  // Caja de Recompensas Acumuladas
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFD54F).withAlpha(70)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'RECOMPENSAS TOTALES GANADAS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF8E1),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🪙', style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '+$monedasAcumuladas Monedas',
                              style: const TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        if (nivelesSubidos > 1) ...[
                          const SizedBox(height: 4),
                          Text(
                            '($nivelesSubidos niveles acumulados × 10 monedas c/u)',
                            style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),

                  // Botón "¡RECLAMAR RECOMPENSA!"
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF1B5E20),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                        border: Border.all(color: Colors.white.withAlpha(100), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '¡RECLAMAR RECOMPENSA!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
