import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/features/home/dashboard_screen.dart';
import 'package:habitik/features/challenges/challenges_screen.dart';
import 'package:habitik/features/scan/scan_screen.dart';
import 'package:habitik/features/rewards/rewards_screen.dart';
import 'package:habitik/features/control/control_screen.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';

class HomeShell extends StatefulWidget {
  final int? initialTab;
  const HomeShell({super.key, this.initialTab});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _tab;
  final _sessionService = SessionService();
  bool _hideNavbar = false;

  @override
  void initState() {
    super.initState();
    final isJefe = _sessionService.currentUser?.isJefe ?? false;
    // Si se especifica initialTab se respeta; por defecto el miembro inicia en Retos (índice 1) y el jefe en Inicio (0)
    _tab = widget.initialTab ?? (isJefe ? 0 : 1);
  }

  List<Widget> _buildScreens(bool isJefe) {
    return isJefe
        ? [
            const DashboardScreen(),
            ChallengesScreen(
              onGameModeChanged: (hide) => setState(() => _hideNavbar = hide),
            ),
            const ScanScreen(),
            const RewardsScreen(),
            const ControlScreen(),
          ]
        : [
            const DashboardScreen(),
            ChallengesScreen(
              onGameModeChanged: (hide) => setState(() => _hideNavbar = hide),
            ),
            const RewardsScreen(),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: _sessionService.currentUserNotifier,
      builder: (context, user, _) {
        final isJefe = user?.isJefe ?? false;
        final screens = _buildScreens(isJefe);
        final currentTab = _tab >= screens.length ? 0 : _tab;

        return ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDark, _) {
            return Scaffold(
              extendBody: true,
              backgroundColor: isDark ? const Color(0xFF142419) : HabitikColors.green700,
              body: IndexedStack(
                index: currentTab,
                children: screens,
              ),
              bottomNavigationBar: _hideNavbar
                  ? null
                  : BottomNavHabitik(
                      currentIndex: currentTab,
                      onTap: (i) => setState(() => _tab = i),
                      isJefe: isJefe,
                      notifCount: 0,
                    ),
            );
          },
        );
      },
    );
  }
}
