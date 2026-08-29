import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/retos_plaza_background.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/features/challenges/games/speedrun/speedrun.dart';

class ChallengesScreen extends StatefulWidget {
  final void Function(bool)? onGameModeChanged;
  const ChallengesScreen({super.key, this.onGameModeChanged});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final _challenges = ChallengeType.allChallenges.where((c) => c.id != 'pesca' && c.id != 'sopa').toList();
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
                              onTap: () => _showChallengesBottomSheet(context),
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

  void _showChallengesBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141F17) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra de arrastre superior
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Text(
                "Eco-Desafíos Diarios",
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Completa los juegos para consolidar tus hábitos ecológicos.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : HabitikColors.textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              
              // Grid de cartas de desafíos
              ValueListenableBuilder<Set<String>>(
                valueListenable: _completedNotifier,
                builder: (context, completedSet, child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = _challenges[index];
                      final isCompleted = completedSet.contains(challenge.id);
                      
                      return ChallengeCard(
                        challenge: challenge,
                        completed: isCompleted,
                        selected: challenge.id == 'ducha',
                        onTap: () {
                          if (challenge.id == 'ducha') {
                            Navigator.pop(context); // Cerrar bottom sheet
                            Navigator.push(
                              context,
                              FadePageRoute(
                                child: SpeedrunScreen(
                                  onChallengeCompleted: () {
                                    _completedNotifier.value = Set.from(_completedNotifier.value)..add('ducha');
                                  },
                                  onGameModeChanged: widget.onGameModeChanged,
                                ),
                              ),
                            );
                          } else if (challenge.id == 'puzzle') {
                            Navigator.pop(context);
                            _showEcoPuzzleDialog(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "¡El mini-juego '${challenge.titulo}' estará disponible pronto!",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: HabitikColors.green700,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showEcoPuzzleDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF141F17) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'Eco-Puzzle Temático',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : HabitikColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clasifica los residuos en menos de 60 segundos con menos de 3 errores para ganar +150 XP y 2 monedas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? HabitikColors.green200 : HabitikColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isSubmitting)
                      const CircularProgressIndicator(color: HabitikColors.green600)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HabitikColors.green600,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () async {
                                setDialogState(() => isSubmitting = true);
                                try {
                                  final user = SessionService().currentUser;
                                  final response = await ApiClient().post('/eco/completar', {
                                    'user_id': user?.id,
                                    'errores': 1,
                                    'tiempo_segundos': 35,
                                  });

                                  final data = jsonDecode(response.body);
                                  if (data['ok'] == true) {
                                    final recomp = data['data']['recompensas'];
                                    await SessionService().updateRewardsAndXp(
                                      xp: recomp['xp_total'],
                                      monedas: recomp['monedas_total'],
                                      nivel: recomp['nivel_actual'],
                                    );
                                    _completedNotifier.value = Set.from(_completedNotifier.value)..add('puzzle');
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(dialogCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(data['message'] ?? '¡Reto completado!'),
                                        backgroundColor: HabitikColors.green700,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setDialogState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al enviar reto: $e'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('¡Completar!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
