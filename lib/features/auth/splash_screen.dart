import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';

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
    _timer = Timer(2800.ms, widget.onFinish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: HabitikShadows.glow(HabitikColors.green400),
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 60)),
                  ),
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
                    decoration: const BoxDecoration(color: HabitikColors.amber400, shape: BoxShape.circle),
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
