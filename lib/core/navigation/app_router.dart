import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/features/auth/splash_screen.dart';
import 'package:habitik/features/auth/login_screen.dart';
import 'package:habitik/features/onboarding/onboarding_screen.dart';
import 'package:habitik/features/home/home_shell.dart';

enum AppState { splash, login, onboarding, home }

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  static void logout(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    SessionService().clearSession();
  }

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  AppState _state = AppState.splash;
  final _sessionService = SessionService();
  bool _initialized = false;
  bool _splashFinished = false;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    await _sessionService.init();
    if (mounted) {
      setState(() {
        _initialized = true;
      });
      if (_splashFinished) {
        _evaluateNavigation();
      }
    }
  }

  void _onSplashFinished() {
    _splashFinished = true;
    if (_initialized) {
      _evaluateNavigation();
    }
  }

  void _evaluateNavigation() {
    if (!_initialized) return;

    if (_sessionService.hasSession) {
      if (_sessionService.isOnboardingCompleted) {
        setState(() => _state = AppState.home);
      } else {
        setState(() => _state = AppState.onboarding);
      }
    } else {
      setState(() => _state = AppState.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HabitikColors.green700,
      child: AnimatedSwitcher(
        duration: 400.ms,
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: ValueListenableBuilder(
          valueListenable: _sessionService.currentUserNotifier,
          builder: (context, user, child) {
            // Si el estado cambia a nulo (logout) y no estamos en splash/login, redirigir a login
            if (_initialized && _state != AppState.splash && !_sessionService.hasSession) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _state = AppState.login);
              });
            }

            return switch (_state) {
              AppState.splash     => SplashScreen(key: const ValueKey('splash'), onFinish: _onSplashFinished),
              AppState.login      => LoginScreen(key: const ValueKey('login'),   onLogin: _evaluateNavigation),
              AppState.onboarding => OnboardingScreen(key: const ValueKey('ob'), onFinish: _evaluateNavigation),
              AppState.home       => const HomeShell(key: ValueKey('home')),
            };
          },
        ),
      ),
    );
  }
}
