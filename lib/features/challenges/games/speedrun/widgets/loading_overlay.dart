import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/speedrun_game.dart';

class LoadingOverlay extends StatefulWidget {
  final SpeedrunGame game;
  const LoadingOverlay({super.key, required this.game});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  late final Timer _tipTimer;
  int _currentTipIndex = 0;
  
  final List<String> _ecoTips = [
    "Ducharse en menos de 5 minutos ahorra hasta 100 litros de agua al día.",
    "Cerrar la llave mientras te enjabonas ahorra unos 12 litros de agua por minuto.",
    "El agua de la ducha representa más del 30% del consumo de agua caliente en el hogar.",
    "Instalar un cabezal de bajo flujo reduce el consumo de agua de la ducha a la mitad.",
    "¡Ducharse rápido no solo ahorra agua, también reduce las emisiones de CO₂ por calentar el agua!"
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
  }

  @override
  void dispose() {
    _tipTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Lista de burbujas decorativas con tamaños, posiciones y velocidades aleatorias simuladas
    final List<Map<String, dynamic>> bubbleConfigs = [
      {'size': 35.0, 'left': 0.15, 'duration': 4200, 'delay': 0},
      {'size': 50.0, 'left': 0.35, 'duration': 5000, 'delay': 400},
      {'size': 25.0, 'left': 0.65, 'duration': 3800, 'delay': 200},
      {'size': 40.0, 'left': 0.80, 'duration': 4600, 'delay': 600},
      {'size': 60.0, 'left': 0.25, 'duration': 5500, 'delay': 100},
      {'size': 30.0, 'left': 0.50, 'duration': 4000, 'delay': 800},
      {'size': 45.0, 'left': 0.70, 'duration': 4800, 'delay': 300},
      {'size': 20.0, 'left': 0.10, 'duration': 3500, 'delay': 500},
      {'size': 55.0, 'left': 0.55, 'duration': 5200, 'delay': 700},
      {'size': 32.0, 'left': 0.90, 'duration': 4300, 'delay': 150},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // Agua jabonosa superior
              Color(0xFFB2EBF2),
              Color(0xFF80DEEA),
              Color(0xFF4DD0E1), // Profundidad de tina inferior
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 1. Burbujas flotantes animadas de fondo
            ...bubbleConfigs.map((config) {
              final double bSize = config['size'];
              final double bLeft = config['left'] * size.width;
              final int duration = config['duration'];
              final int delay = config['delay'];

              return Positioned(
                bottom: -80,
                left: bLeft,
                child: Container(
                  width: bSize,
                  height: bSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Reflejo en la burbuja
                      Positioned(
                        top: bSize * 0.15,
                        left: bSize * 0.15,
                        child: Container(
                          width: bSize * 0.25,
                          height: bSize * 0.25,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 400.ms)
                    .slideY(
                      begin: 0.0,
                      end: -(size.height + 150) / bSize,
                      duration: duration.ms,
                      delay: delay.ms,
                      curve: Curves.easeInQuad,
                    )
                    .then()
                    .fadeOut(duration: 200.ms),
              );
            }),

            // 2. Capa de espuma de burbujas responsiva en la parte inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 140,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Base sólida de espuma
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      // Burbuja 1 (Izquierda)
                      Positioned(
                        left: -35,
                        bottom: 20,
                        child: _buildBubble(100, 0.7, 2200.ms, -0.08),
                      ),
                      // Burbuja 2 (Centro-Izquierda)
                      Positioned(
                        left: width * 0.14,
                        bottom: 25,
                        child: _buildBubble(120, 0.8, 2500.ms, -0.06),
                      ),
                      // Burbuja 3 (Centro)
                      Positioned(
                        left: width * 0.40,
                        bottom: 15,
                        child: _buildBubble(90, 0.65, 2000.ms, -0.1),
                      ),
                      // Burbuja 4 (Centro-Derecha)
                      Positioned(
                        left: width * 0.60,
                        bottom: 30,
                        child: _buildBubble(130, 0.85, 2800.ms, -0.05),
                      ),
                      // Burbuja 5 (Derecha)
                      Positioned(
                        right: -35,
                        bottom: 20,
                        child: _buildBubble(110, 0.75, 2300.ms, -0.07),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 3. Contenido principal centrado
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pato de goma o tina flotante animada
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms),
                        
                        // Icono de burbujas/baño
                        const Text(
                          "🧼🫧",
                          style: TextStyle(fontSize: 58),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .slideY(begin: -0.1, end: 0.1, duration: 1000.ms, curve: Curves.easeInOut)
                            .then()
                            .shake(hz: 2, curve: Curves.easeInOut),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Título creativo
                    Text(
                      "PREPARANDO BURBUJAS...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0D47A1),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(
                            color: Colors.white54,
                            blurRadius: 10.0,
                          )
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0.0),
                    const SizedBox(height: 12),
                    
                    // Pequeña barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 180,
                        height: 6,
                        color: Colors.white.withValues(alpha: 0.3),
                        child: const LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B0FF)),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    
                    const SizedBox(height: 54),
                    
                    // Caja de consejos ecológicos
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "CONSEJO DE AHORRO",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: 400.ms,
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              _ecoTips[_currentTipIndex],
                              key: ValueKey<int>(_currentTipIndex),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1B4965),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(double size, double opacity, Duration duration, double slideOffset) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .slideY(begin: 0, end: slideOffset, duration: duration, curve: Curves.easeInOut);
  }
}
