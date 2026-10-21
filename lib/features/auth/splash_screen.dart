import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/branding/habitik_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(1200.ms, widget.onFinish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkModeNotifier.value;
    final bgGradient = isDark ? HabitikColors.heroGreenDark : HabitikColors.heroGreen;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo oficial de Habitik
                HabitikLogo(
                  size: 130,
                )
                .animate()
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // App name
                const Text(
                  'HABITIK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut),

                const SizedBox(height: 8),

                const Text(
                  'Hábitos que cuidan el planeta 🌎',
                  style: TextStyle(color: HabitikColors.green200, fontSize: 14, fontWeight: FontWeight.w600),
                )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms),

                const SizedBox(height: 60),

                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark ? HabitikColors.green300 : HabitikColors.amber400,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: (i * 150).ms + 900.ms).then().fadeOut(duration: 400.ms)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeTransitionScreen extends StatefulWidget {
  final bool targetIsDark;
  const ThemeTransitionScreen({super.key, required this.targetIsDark});

  @override
  State<ThemeTransitionScreen> createState() => _ThemeTransitionScreenState();
}

class _ThemeTransitionScreenState extends State<ThemeTransitionScreen> {
  Timer? _timerSwitch;
  Timer? _timerClose;

  @override
  void initState() {
    super.initState();
    _timerSwitch = Timer(900.ms, () {
      ThemeService.setDarkMode(widget.targetIsDark);
    });
    _timerClose = Timer(2300.ms, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timerSwitch?.cancel();
    _timerClose?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.targetIsDark;
    final bgDecoration = isDark
        ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D1E13), Color(0xFF162B1D), Color(0xFF0A140D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          )
        : const BoxDecoration(gradient: HabitikColors.heroGreen);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: bgDecoration,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo oficial de Habitik
                  HabitikLogo(
                    size: 130,
                  )
                  .animate()
                  .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 250.ms),

                  const SizedBox(height: 24),

                  // App name
                  const Text(
                    'HABITIK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),

                  const SizedBox(height: 14),

                  // Mensaje de transición con ícono estilizado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFFFE082),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDark ? 'Activando Modo Oscuro... ✨' : 'Volviendo al Modo Claro... 🌿',
                          style: const TextStyle(
                            color: HabitikColors.green200,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),

                  const SizedBox(height: 60),

                  // Loading dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark ? HabitikColors.green300 : HabitikColors.amber400,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: (i * 150).ms + 600.ms).then().fadeOut(duration: 400.ms)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

