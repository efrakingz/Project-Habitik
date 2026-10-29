import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/level_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import 'package:habitik/shared/widgets/effects/effects.dart';
import 'package:habitik/shared/widgets/modals/modals.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/retos_plaza_background.dart';

// Mini-juegos
import 'package:habitik/features/challenges/games/speedrun/speedrun.dart';
import 'package:habitik/features/challenges/games/eco_puzzle/eco_puzzle.dart';
import 'package:habitik/features/challenges/games/eco_wordle/eco_wordle.dart';
import 'package:habitik/features/challenges/games/trivia/trivia.dart';
import 'package:habitik/features/challenges/games/cazador_sombras/cazador_sombras_screen.dart';
import 'widgets/weekly_streak_card.dart';
import 'widgets/daily_bonus_card.dart';

class ChallengesScreen extends StatefulWidget {
  final bool isActive;
  final void Function(bool)? onGameModeChanged;
  const ChallengesScreen({
    super.key,
    this.isActive = true,
    this.onGameModeChanged,
  });

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  final _challenges =
      ChallengeType.allChallenges.where((c) => c.id != 'pesca').toList();

  // Racha semanal calculada desde el backend (L-D)
  List<bool> _streakDays = [false, false, false, false, false, false, false];

  // Aisladores de estado para alto rendimiento de renderizado
  final ValueNotifier<String?> _selectedChallengeIdNotifier = ValueNotifier(null);
  final ValueNotifier<Set<String>> _completedNotifier = ValueNotifier({});
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0.0);

  late final List<ChallengeType> _orderedChallenges;
  late final AnimationController _entranceCtrl;
  late final Animation<double> _entranceAnimation;

  // Cache de dimensiones para evitar recalcular coordenadas innecesarias
  double? _cachedWidth;
  late double _mapHeight;
  late Map<String, Offset> _nodes;

  // Colores dinámicos del botón del juego seleccionado
  Color _btnColor = Colors.green;
  Color _btnShadow = Colors.green;

  @override
  void initState() {
    super.initState();
    _orderedChallenges = _challenges.reversed.toList();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOut,
    );
    _entranceCtrl.forward();
    _cargarRachaSemanal();
    _loadCompletedChallenges();
  }

  @override
  void didUpdateWidget(covariant ChallengesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Al volver a la pestaña de Retos, sincronizar el estado y racha automáticamente
      _loadCompletedChallenges();
      _cargarRachaSemanal();
    }
  }

  Future<void> _loadCompletedChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final user = SessionService().currentUser;
    final key = 'completed_challenges_${user?.id}_$dateStr';
    final completed = prefs.getStringList(key) ?? [];
    if (completed.isNotEmpty && mounted) {
      _completedNotifier.value = completed.toSet();
    }

    // Sincronizar con el backend si el Wordle de hoy ya fue completado o finalizado
    try {
      final res = await ApiClient().get('/wordle/hoy');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final estado = decoded['data']['estado'];
          if (estado == 'ganado' || estado == 'perdido') {
            final updated = {..._completedNotifier.value, 'wordle'};
            if (mounted) {
              _completedNotifier.value = updated;
            }
            await prefs.setStringList(key, updated.toList());
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _cargarRachaSemanal() async {
    final user = SessionService().currentUser;
    if (user == null) return;
    try {
      final res = await ApiClient().get('/reto/racha-semanal/${user.id}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['ok'] == true && decoded['data'] != null) {
          final diasRaw = decoded['data']['dias'];
          if (diasRaw is List && diasRaw.length == 7) {
            final dias = diasRaw.map((d) => d == true).toList();
            if (mounted) {
              setState(() {
                _streakDays = dias;
              });
            }
          }
        }
      }
    } catch (_) {
      // Si falla o no hay conexión, se preserva el estado previo
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _selectedChallengeIdNotifier.dispose();
    _completedNotifier.dispose();
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  void _onSelectChallenge(String? id) {
    if (id == null) {
      _selectedChallengeIdNotifier.value = null;
      return;
    }
    final challenge = _challenges.firstWhere((c) => c.id == id);
    _btnColor = Color(
      int.parse('FF${challenge.colorHex.replaceFirst('#', '')}', radix: 16),
    );
    _btnShadow = Color(
      int.parse('FF${challenge.colorHex2.replaceFirst('#', '')}', radix: 16),
    );
    _selectedChallengeIdNotifier.value = id;
  }

  void _rebuildNodes(double width) {
    if (_cachedWidth == width) return;
    _cachedWidth = width;
    _mapHeight = 250.0 + (_orderedChallenges.length * 120.0) + 50.0;
    _nodes = {};
    for (int i = 0; i < _orderedChallenges.length; i++) {
      final id = _orderedChallenges[i].id;
      final x = (i % 2 == 0) ? (width * 0.25) : (width * 0.75);
      final y = _mapHeight - 120.0 - (i * 120.0);
      _nodes[id] = Offset(x, y);
    }
  }

  void _playGame(String id) {
    widget.onGameModeChanged?.call(true);

    Widget gameWidget;
    switch (id) {
      case 'ducha':
        gameWidget = SpeedrunScreen(
          onChallengeCompleted: () => _completeGame(id),
          onGameModeChanged: widget.onGameModeChanged,
        );
        break;
      case 'puzzle':
        gameWidget = EcoPuzzleScreen(
          onChallengeCompleted: () => _completeGame(id),
        );
        break;
      case 'wordle':
        gameWidget = EcoWordleScreen(
          onChallengeCompleted: () => _completeGame(id),
          onChallengeAlreadyCompleted: () => _completeGame(id, showConfetti: false),
        );
        break;
      case 'trivia':
        gameWidget = TriviaScreen(
          onChallengeCompleted: () => _completeGame(id),
          onGameModeChanged: widget.onGameModeChanged,
        );
        break;
      case 'inspeccion':
        gameWidget = CazadorSombrasScreen(
          onChallengeCompleted: () => _completeGame(id),
        );
        break;
      default:
        widget.onGameModeChanged?.call(false);
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => gameWidget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      if (mounted) {
        widget.onGameModeChanged?.call(false);
      }
    });
  }

  void _completeGame(String id, {bool showConfetti = true, AchievementItem? unlockedBadge}) async {
    final newCompleted = {..._completedNotifier.value, id};
    _completedNotifier.value = newCompleted;
    if (mounted) {
      if (unlockedBadge != null) {
        await BadgeUnlockedDialog.show(context, badge: unlockedBadge);
      } else if (showConfetti) {
        CelebrationConfetti.show(context);
        LevelService.checkAndShowLevelUp(context);
      }
      _cargarRachaSemanal();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final user = SessionService().currentUser;
      final key = 'completed_challenges_${user?.id}_$dateStr';
      await prefs.setStringList(key, newCompleted.toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final streak = SessionService().currentUser?.rachaDias ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? HabitikColors.heroGreenDark : HabitikColors.heroGreen,
      ),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Desafíos de Hoy',
          subtitulo: '🎮 ¡Completa desafíos y gana XP!',
          useDefaultBackground: false,
          headerActions: [_StreakBadge(streak: streak)],
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              _rebuildNodes(width);

              return Stack(
                children: [
                  // 1. Fondo interactivo Flame de la plaza ocupando todo el fondo
                  Positioned.fill(
                    child: RetosPlazaBackground(
                      challenges: _challenges,
                      completedChallengesNotifier: _completedNotifier,
                      mapHeight: _mapHeight,
                      screenWidth: width,
                      nodes: _nodes,
                      scrollOffsetNotifier: _scrollOffsetNotifier,
                      onBackgroundTap: () => _onSelectChallenge(null),
                    ),
                  ),

                  // 2. Scroll transparente encima con los elementos de juego
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      _scrollOffsetNotifier.value = notification.metrics.pixels;
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _onSelectChallenge(null),
                        child: SizedBox(
                          height: _mapHeight + 80.0,
                          width: width,
                          child: Stack(
                            children: [
                              // Racha semanal (arriba del sendero)
                              Positioned(
                                left: 16,
                                right: 16,
                                top: 16,
                                child: WeeklyStreakCard(days: _streakDays),
                              ),

                              // Bono del día
                              Positioned(
                                left: 16,
                                right: 16,
                                top: 140,
                                child: ValueListenableBuilder<Set<String>>(
                                  valueListenable: _completedNotifier,
                                  builder: (context, completed, _) {
                                    return DailyBonusCard(
                                      claimed: completed.length >= 3,
                                    );
                                  },
                                ),
                              ),

                              // Tarjetas de reto nativas posicionadas sobre el sendero de Flame
                              ..._challenges.map((challenge) {
                                final node = _nodes[challenge.id]!;
                                return _ChallengeCardSlot(
                                  challenge: challenge,
                                  node: node,
                                  completedNotifier: _completedNotifier,
                                  selectedNotifier:
                                      _selectedChallengeIdNotifier,
                                  entranceAnim: _entranceAnimation,
                                  onTap: () {
                                    AudioService.playSFX('click.mp3');
                                    _onSelectChallenge(challenge.id);
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Panel de detalles inferior flotante con animación suave
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _selectedChallengeIdNotifier,
                      builder: (context, selectedId, _) {
                        return ValueListenableBuilder<Set<String>>(
                          valueListenable: _completedNotifier,
                          builder: (context, completed, _) {
                            final isCompleted =
                                selectedId != null && completed.contains(selectedId);
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutQuad,
                                  ),
                                ),
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: selectedId == null
                                  ? const SizedBox.shrink()
                                  : _buildBottomDetailPanel(selectedId, isCompleted),
                            );
                          },
                        );
                      },
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

  Widget _buildBottomDetailPanel(String selectedId, bool isCompleted) {
    final challenge = _challenges.firstWhere((c) => c.id == selectedId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = challenge.isAvailable;
    final isWordleCompleted = challenge.id == 'wordle' && isCompleted;

    return Container(
      key: ValueKey('$selectedId-$isCompleted'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
        borderRadius: HabitikRadius.xl_,
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: isDark ? const Color(0x30FFFFFF) : _btnColor.withAlpha(50),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GameChallengeIcon(
                challengeId: challenge.id,
                size: 36,
                color: _btnColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            challenge.displayTitle,
                            style: TextStyle(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isWordleCompleted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: HabitikColors.green500.withAlpha(35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: HabitikColors.green500.withAlpha(120),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: HabitikColors.green500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'COMPLETADO HOY',
                                  style: TextStyle(
                                    color: isDark ? HabitikColors.green300 : HabitikColors.green700,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (!isAvailable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? Colors.amber.shade400 : Colors.amber.shade700,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 11,
                                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'PRÓXIMAMENTE',
                                  style: TextStyle(
                                    color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.desc,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : HabitikColors.textLight,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _btnColor.withAlpha(30),
                      borderRadius: HabitikRadius.lg_,
                    ),
                    child: Row(
                      children: [
                        const GameStarIcon(size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${challenge.xp}',
                          style: TextStyle(
                            color: _btnColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2618)
                          : const Color(0xFFFFF8E1),
                      borderRadius: HabitikRadius.lg_,
                    ),
                    child: Row(
                      children: [
                        const GameCoinIcon(size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${challenge.monedas}',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFFFD54F)
                                : const Color(0xFFF57F17),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isWordleCompleted)
                GestureDetector(
                  onTap: () {
                    AudioService.playSFX('click.mp3');
                    HabitikFeedback.showInfo(
                      context,
                      '¡Ya completaste el reto de hoy! Vuelve mañana para una nueva palabra ecológica.',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3825) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF388E3C) : const Color(0xFF81C784),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '¡COMPLETADO!',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    AudioService.playSFX('click.mp3');
                    if (isAvailable) {
                      final id = _selectedChallengeIdNotifier.value!;
                      _onSelectChallenge(null);
                      _playGame(id);
                    } else {
                      ComingSoonModal.show(
                        context,
                        title: challenge.titulo,
                        emoji: challenge.emoji,
                        description:
                            'El desafío "${challenge.titulo}" está actualmente en desarrollo y estará disponible en una próxima actualización. ¡Sigue cuidando el planeta con los demás retos!',
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? _btnColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isAvailable ? _btnShadow : (isDark ? Colors.black45 : Colors.grey.shade600),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isAvailable) ...[
                          const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 15),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          isAvailable ? '¡JUGAR!' : 'PRÓXIMAMENTE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChallengeCardSlot - Slot aislado para evitar rebuilds de todas las tarjetas
// ─────────────────────────────────────────────────────────────────────────────
class _ChallengeCardSlot extends StatelessWidget {
  final ChallengeType challenge;
  final Offset node;
  final ValueNotifier<Set<String>> completedNotifier;
  final ValueNotifier<String?> selectedNotifier;
  final Animation<double> entranceAnim;
  final VoidCallback onTap;

  const _ChallengeCardSlot({
    required this.challenge,
    required this.node,
    required this.completedNotifier,
    required this.selectedNotifier,
    required this.entranceAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.dx - 55,
      top: node.dy - 60,
      child: SizedBox(
        width: 110,
        height: 120,
        child: FadeTransition(
          opacity: entranceAnim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(entranceAnim),
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: completedNotifier,
              builder: (_, completed, _) {
                final isCompleted = completed.contains(challenge.id);
                return ValueListenableBuilder<String?>(
                  valueListenable: selectedNotifier,
                  builder: (_, selectedId, child) => ChallengeCard(
                    challenge: challenge,
                    completed: isCompleted,
                    selected: selectedId == challenge.id,
                    onTap: onTap,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HabitikColors.green600,
        borderRadius: HabitikRadius.xxl_,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GameFireIcon(size: 13),
          const SizedBox(width: 4),
          Text(
            '$streak días',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

