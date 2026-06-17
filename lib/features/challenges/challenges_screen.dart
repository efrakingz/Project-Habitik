import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/retos_plaza_background.dart';

class ChallengesScreen extends StatefulWidget {
  final void Function(bool)? onGameModeChanged;
  const ChallengesScreen({super.key, this.onGameModeChanged});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final _challenges = ChallengeType.allChallenges.where((c) => c.id != 'pesca').toList();
  final ValueNotifier<Set<String>> _completedNotifier = ValueNotifier({});
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0.0);
  
  late final Map<String, Offset> _nodes;
  late final double _mapHeight;

  @override
  void initState() {
    super.initState();
    _mapHeight = 250.0 + (_challenges.length * 120.0) + 50.0;
    _nodes = {};
    for (int i = 0; i < _challenges.length; i++) {
      final id = _challenges[i].id;
      final x = (i % 2 == 0) ? 100.0 : 300.0;
      final y = _mapHeight - 120.0 - (i * 120.0);
      _nodes[id] = Offset(x, y);
    }
  }

  @override
  void dispose() {
    _completedNotifier.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Desafíos de Hoy',
          subtitulo: '🎮 ¡Completa desafíos y gana XP!',
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final Map<String, Offset> activeNodes = {};
              for (int i = 0; i < _challenges.length; i++) {
                final id = _challenges[i].id;
                final x = (i % 2 == 0) ? (width * 0.25) : (width * 0.75);
                final y = _mapHeight - 120.0 - (i * 120.0);
                activeNodes[id] = Offset(x, y);
              }

              return Stack(
                children: [
                  // Fondo de la plaza (sendero)
                  Positioned.fill(
                    child: RetosPlazaBackground(
                      challenges: _challenges,
                      completedChallengesNotifier: _completedNotifier,
                      mapHeight: _mapHeight,
                      screenWidth: width,
                      nodes: activeNodes,
                      scrollOffsetNotifier: _scrollOffsetNotifier,
                      onBackgroundTap: () {},
                    ),
                  ),

                  // Tarjeta limpia centrada flotando encima
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                          borderRadius: HabitikRadius.lg_,
                          border: Border.all(
                            color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: HabitikShadows.card,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎮', style: TextStyle(fontSize: 54))
                                .animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 12),
                            const Text(
                              'Eco-Desafíos',
                              style: TextStyle(
                                color: HabitikColors.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Participa en divertidos mini-juegos ecológicos diarios y acumula puntos de experiencia (XP) para tu nivel.',
                              style: TextStyle(
                                color: HabitikColors.textLight,
                                fontSize: 12,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: HabitikColors.heroGreen,
                                  borderRadius: HabitikRadius.md_,
                                  boxShadow: HabitikShadows.colored(HabitikColors.green600),
                                ),
                                child: const Text(
                                  '🎮 Ver Desafíos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
