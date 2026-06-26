import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';

class NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;

  const NavItem({
    required this.label,
    required this.activeIcon,
    required this.icon,
  });
}

class NavigationConstants {
  static const List<NavItem> memberNavItems = [
    NavItem(
      label: 'Inicio',
      activeIcon: Icons.home_rounded,
      icon: Icons.home,
    ),
    NavItem(
      label: 'Retos',
      activeIcon: Icons.sports_esports,
      icon: Icons.sports_esports_outlined,
    ),
    NavItem(
      label: 'Canjes',
      activeIcon: Icons.redeem_rounded,
      icon: Icons.redeem_outlined,
    ),
  ];

  static const List<NavItem> adminNavItems = [
    NavItem(
      label: 'Inicio',
      activeIcon: Icons.home_rounded,
      icon: Icons.home,
    ),
    NavItem(
      label: 'Retos',
      activeIcon: Icons.sports_esports,
      icon: Icons.sports_esports_outlined,
    ),
    NavItem(
      label: 'Scan',
      activeIcon: Icons.document_scanner,
      icon: Icons.document_scanner_outlined,
    ),
    NavItem(
      label: 'Canjes',
      activeIcon: Icons.redeem_rounded,
      icon: Icons.redeem_outlined,
    ),
    NavItem(
      label: 'Panel',
      activeIcon: Icons.admin_panel_settings,
      icon: Icons.admin_panel_settings_outlined,
    ),
  ];
}

class BottomNavHabitik extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final bool isJefe;
  final int notifCount;

  const BottomNavHabitik({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isJefe = false,
    this.notifCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final items = isJefe
        ? NavigationConstants.adminNavItems
        : NavigationConstants.memberNavItems;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.of(context).padding.bottom),
      height: 64,
      decoration: BoxDecoration(
        gradient: HabitikColors.heroGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(25),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final selected = currentIndex == i;
          final showBadge = i == 0 && notifCount > 0; // badge en Inicio

          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 56, height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: 200.ms,
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white.withAlpha(45) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? Colors.white : Colors.white.withAlpha(160),
                          size: 20,
                        ).animate(target: selected ? 1 : 0).scaleXY(begin: 1, end: 1.15, duration: 150.ms),
                        if (showBadge)
                          Positioned(
                            top: -4, right: -4,
                            child: Container(
                              width: 14, height: 14,
                              decoration: const BoxDecoration(color: HabitikColors.orange400, shape: BoxShape.circle),
                              child: Center(
                                child: Text('$notifCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: 200.ms,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected ? Colors.white : Colors.white.withAlpha(160),
                      fontFamily: 'Nunito',
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
