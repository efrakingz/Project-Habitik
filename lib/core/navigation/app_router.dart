import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/features/auth/splash_screen.dart';
import 'package:habitik/features/auth/login_screen.dart';
import 'package:habitik/features/onboarding/onboarding_screen.dart';
import 'package:habitik/features/home/home_shell.dart';

enum AppState { splash, login, onboarding, home }

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  AppState _state = AppState.splash;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 400.ms,
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: switch (_state) {
        AppState.splash     => SplashScreen(key: const ValueKey('splash'), onFinish: () => setState(() => _state = AppState.login)),
        AppState.login      => LoginScreen(key: const ValueKey('login'),   onLogin:  () => setState(() => _state = AppState.onboarding)),
        AppState.onboarding => OnboardingScreen(key: const ValueKey('ob'), onFinish: () => setState(() => _state = AppState.home)),
        AppState.home       => const HomeShell(key: ValueKey('home')),
      },
    );
  }
}
