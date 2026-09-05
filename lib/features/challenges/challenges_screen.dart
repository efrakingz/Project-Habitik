import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/level_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import 'package:habitik/shared/widgets/effects/effects.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/retos_plaza_background.dart';

// Mini-juegos
import 'package:habitik/features/challenges/games/speedrun/speedrun.dart';
import 'package:habitik/features/challenges/games/eco_puzzle/eco_puzzle.dart';
import 'package:habitik/features/challenges/games/trivia/trivia_challenge.dart';
import 'package:habitik/features/challenges/games/wordle/wordle_challenge.dart';
import 'package:habitik/features/challenges/games/home_inspection/home_inspection_challenge.dart';
import 'package:habitik/features/challenges/games/word_search/word_search_challenge.dart';

const _kAnimFast = Duration(milliseconds: 200);
const _kAnimMedium = Duration(milliseconds: 300);

class ChallengesScreen extends StatefulWidget {
  final void Function(bool)? onGameModeChanged;
  const ChallengesScreen({super.key, this.onGameModeChanged});

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
      case 'trivia':
        gameWidget = TriviaChallenge(
          onBack: () => Navigator.of(context).pop(),
          onComplete: () {
            _completeGame(id);
            Navigator.of(context).pop();
          },
        );
        break;
      case 'wordle':
        gameWidget = WordleChallenge(
          onBack: () => Navigator.of(context).pop(),
          onComplete: () {
            _completeGame(id);
            Navigator.of(context).pop();
          },
        );
        break;
      case 'inspeccion':
        gameWidget = HomeInspectionChallenge(
          onBack: () => Navigator.of(context).pop(),
          onComplete: () {
            _completeGame(id);
            Navigator.of(context).pop();
          },
        );
        break;
      case 'sopa':
        gameWidget = WordSearchChallenge(
          onBack: () => Navigator.of(context).pop(),
          onComplete: () {
            _completeGame(id);
            Navigator.of(context).pop();
          },
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

  void _completeGame(String id) {
    _completedNotifier.value = {..._completedNotifier.value, id};
    if (mounted) {
      CelebrationConfetti.show(context);
      LevelService.checkAndShowLevelUp(context);
      _cargarRachaSemanal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = SessionService().currentUser?.rachaDias ?? 3;

    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Desafíos de Hoy',
          subtitulo: '🎮 ¡Completa desafíos y gana XP!',
          useDefaultBackground: false,
          headerActions: [
            _StreakBadge(streak: streak),
          ],
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
                                child: _WeeklyStreak(days: _streakDays),
                              ),

                              // Bono del día
                              Positioned(
                                left: 16,
                                right: 16,
                                top: 140,
                                child: ValueListenableBuilder<Set<String>>(
                                  valueListenable: _completedNotifier,
                                  builder: (context, completed, _) {
                                    return _DailyBonus(
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
                                  selectedNotifier: _selectedChallengeIdNotifier,
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
                              : _buildBottomDetailPanel(selectedId),
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

  Widget _buildBottomDetailPanel(String selectedId) {
    final challenge = _challenges.firstWhere((c) => c.id == selectedId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey(selectedId),
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
                    Text(
                      challenge.displayTitle,
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.desc,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textLight,
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
              GestureDetector(
                onTap: () {
                  AudioService.playSFX('click.mp3');
                  final id = _selectedChallengeIdNotifier.value!;
                  _onSelectChallenge(null);
                  _playGame(id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _btnColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _btnShadow,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    '¡JUGAR!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
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

class _WeeklyStreak extends StatelessWidget {
  final List<bool> days;
  const _WeeklyStreak({required this.days});

  @override
  Widget build(BuildContext context) {
    final labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: HabitikColors.fireStreak,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.colored(HabitikColors.orange400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              GameFireIcon(size: 16),
              SizedBox(width: 6),
              Text(
                'Racha Semanal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((e) {
              final done = e.value;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: _kAnimFast,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: done ? Colors.white : Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labels[e.key],
                      style: TextStyle(
                        color: done ? HabitikColors.orange400 : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[e.key],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DailyBonus extends StatelessWidget {
  final bool claimed;
  const _DailyBonus({required this.claimed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: _kAnimMedium,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: claimed ? null : HabitikColors.xpGold,
        color: claimed
            ? (isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC))
            : null,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: isDark ? 4.0 : 3.0),
        boxShadow: claimed
            ? []
            : HabitikShadows.colored(HabitikColors.amber400),
      ),
      child: Row(
        children: [
          claimed
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: HabitikColors.green500,
                  size: 28,
                )
              : const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 28,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claimed ? 'Bonus reclamado' : 'Bonus del Día',
                  style: TextStyle(
                    color: claimed
                        ? (isDark ? Colors.white70 : HabitikColors.green600)
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      claimed
                          ? '¡Completaste 3 retos hoy!'
                          : 'Completa 3 retos hoy → +50 ',
                      style: TextStyle(
                        color: claimed
                            ? (isDark ? Colors.white54 : HabitikColors.textLight)
                            : Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                    if (!claimed) const GameCoinIcon(size: 11),
                    if (!claimed)
                      Text(
                        ' extra',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
