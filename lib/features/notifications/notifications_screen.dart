import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          bottom: false,
          child: ScreenShell(
            titulo: 'Notificaciones',
            subtitulo: 'Todo leído ✅',
            showBackButton: true,
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  HeroBannerCard(
                    emoji: '🔔',
                    title: 'Centro de Notificaciones',
                    description: 'Revisa las últimas novedades de ahorro, retos completados y recompensas obtenidas por tu familia.',
                    actionLabel: '🔔 Ver Todo',
                    onAction: () {},
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
