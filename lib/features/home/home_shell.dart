import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/features/home/dashboard_screen.dart';
import 'package:habitik/features/challenges/challenges_screen.dart';
import 'package:habitik/features/scan/scan_screen.dart';
import 'package:habitik/features/rewards/rewards_screen.dart';
import 'package:habitik/features/control/control_screen.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  final _sessionService = SessionService();
  bool _hideNavbar = false;

  late final List<Widget> _screens;

  // Para Jefe: 5 tabs (Inicio, Retos, Scan, Canjes, Panel)
  // Para Miembro: 3 tabs (Inicio, Retos, Canjes)
  bool get _isJefe {
    return _sessionService.currentUser?.isJefe ?? false;
  }

  @override
  void initState() {
    super.initState();
    _screens = _isJefe
        ? [
            const DashboardScreen(),
            ChallengesScreen(onGameModeChanged: (hide) => setState(() => _hideNavbar = hide)),
            const ScanScreen(),
            const RewardsScreen(),
            const ControlScreen(),
          ]
        : [
            const DashboardScreen(),
            ChallengesScreen(onGameModeChanged: (hide) => setState(() => _hideNavbar = hide)),
            const RewardsScreen(),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: HabitikColors.green700,
      body: IndexedStack(
        index: _tab,
        children: _screens,
      ),
      bottomNavigationBar: _hideNavbar
          ? null
          : BottomNavHabitik(
              currentIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
              isJefe: _isJefe,
              notifCount: 0,
            ),
    );
  }
}
