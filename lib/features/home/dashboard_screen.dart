import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/features/notifications/notifications_screen.dart';
import 'package:habitik/features/profile/profile_screen.dart';
import 'package:habitik/features/home/family_screen.dart';
import 'package:habitik/features/home/services/family_wall_service.dart';
import 'package:habitik/features/home/widgets/family_ranking_section.dart';
import 'package:habitik/features/home/widgets/family_feed_section.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/level_service.dart';

/// Dashboard y Muro Social Familiar en Tiempo Real (HU 4.1).
/// Incorpora:
/// - Top Familiar Fijo minimalista con podio horizontal semitransparente.
/// - Feed de actividad continuo independiente deslizándose por debajo del top.
/// - Glassmorphism en contenedores dejando entrever el fondo verde de la app.
class DashboardScreen extends StatefulWidget {
  final bool isActive;
  const DashboardScreen({super.key, this.isActive = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final UserProfile _user;
  late final FamilyWallService _wallService;

  @override
  void initState() {
    super.initState();
    _user = SessionService().currentUser ?? UserProfile.empty;
    _wallService = FamilyWallService();
    _wallService.loadWallData(notify: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LevelService.checkAndShowLevelUp(context);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _wallService.loadWallData(notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<UserProfile?>(
          valueListenable: SessionService().currentUserNotifier,
          builder: (context, liveUser, _) {
            final activeUser = liveUser ?? _user;
            final familyTitle = (activeUser.familyName != null && activeUser.familyName!.isNotEmpty)
                ? 'Hogar: ${activeUser.familyName}'
                : 'Muro del Hogar';

            return ScreenShell(
              titulo: 'Muro Familiar',
              subtitulo: familyTitle,
              headerLeft: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  FadePageRoute(child: const FamilyScreen()),
                ),
                child: UserAvatar(
                  letra: (activeUser.familyName ?? 'F').isNotEmpty
                      ? (activeUser.familyName ?? 'F')[0]
                      : 'F',
                  colorHex: activeUser.avatarColor,
                  radius: 22,
                ),
              ),
              headerActions: [
                IconActionButton(
                  icon: Icons.notifications_outlined,
                  onTap: () => Navigator.push(
                    context,
                    FadePageRoute(child: const NotificationsScreen()),
                  ),
                  hasBadge: false,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    FadePageRoute(child: const ProfileScreen()),
                  ),
                  child: UserAvatar(
                    letra: activeUser.avatarLetra,
                    colorHex: activeUser.avatarColor,
                    avatarUrl: activeUser.avatarUrl,
                    radius: 20,
                    showBorder: true,
                  ),
                ),
              ],
          body: ListenableBuilder(
            listenable: _wallService,
            builder: (context, _) {
              return Column(
                children: [
                  // ── 1. Top Familiar Fijo (Estático en la parte superior) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: FamilyRankingSection(
                      members: _wallService.members,
                      loading: _wallService.membersLoading,
                      errorMessage: _wallService.membersError,
                      onRetry: () => _wallService.loadWallData(notify: true),
                      compact: true,
                      onViewAll: () => Navigator.push(
                        context,
                        FadePageRoute(child: const FamilyScreen()),
                      ),
                    ),
                  ),

                  // ── 2. Feed de Actividad Continuo (Scroll independiente) ──
                  Expanded(
                    child: RefreshIndicator(
                      color: HabitikColors.green500,
                      backgroundColor: isDark ? const Color(0xFF1B2E22) : Colors.white,
                      onRefresh: () => _wallService.loadWallData(notify: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FamilyFeedSection(
                          items: _wallService.feed,
                          loading: _wallService.feedLoading,
                          hasMore: _wallService.hasMore,
                          isLoadingMore: _wallService.isLoadingMore,
                          onLoadMore: () => _wallService.fetchMoreFeed(),
                          onReactionTap: (feedId, emoji) {
                            _wallService.toggleReaction(feedId, emoji);
                          },
                          isScrollable: true,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
            );
          },
        );
      },
    );
  }
}
