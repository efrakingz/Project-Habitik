import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titulo: 'Panel de Control',
      subtitulo: '👑 Jefe de Familia',
      headerActions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: HabitikColors.amber400, borderRadius: HabitikRadius.xxl_),
          child: const Text('ADMIN', style: TextStyle(color: Color(0xFF5D4037), fontSize: 10, fontWeight: FontWeight.w900)),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            HeroBannerCard(
              emoji: '👑',
              title: 'Administrar Familia',
              description: 'Gestiona las metas de ahorro mensual de luz y agua, y aprueba evidencias de retos familiares.',
              actionLabel: '👑 Configurar Metas',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}
