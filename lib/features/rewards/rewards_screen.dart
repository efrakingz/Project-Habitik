import 'package:flutter/material.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titulo: 'Canjes',
      subtitulo: '🪙 Tienda de Recompensas',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            HeroBannerCard(
              emoji: '🎁',
              title: 'Tienda de Canjes',
              description: 'Usa tus monedas de ahorro obtenidas en los retos ecológicos para reclamar recompensas familiares.',
              actionLabel: '🎁 Ver Catálogo',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}
