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
/// - CA-4.1-1: Barra de Energía Colectiva animada y meta mensual.
/// - CA-4.1-2: Ranking Familiar con avatares, nivel, rachas y filtros semanal/mensual.
/// - CA-4.1-3: Feed de actividad con emisión de retos y reacciones rápidas (👏, 🔥, 💧, ❤️).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final familyTitle = (_user.familyName != null && _user.familyName!.isNotEmpty)
            ? 'Hogar: ${_user.familyName}'
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
              letra: (_user.familyName ?? 'F').isNotEmpty
                  ? (_user.familyName ?? 'F')[0]
                  : 'F',
              colorHex: _user.avatarColor,
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
                letra: _user.avatarLetra,
                colorHex: _user.avatarColor,
                radius: 20,
                showBorder: true,
              ),
            ),
          ],
          body: ListenableBuilder(
            listenable: _wallService,
            builder: (context, _) {
              return RefreshIndicator(
                color: HabitikColors.green500,
                backgroundColor: isDark ? const Color(0xFF1B2E22) : Colors.white,
                onRefresh: () => _wallService.loadWallData(notify: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    children: [
                      // ── Ranking Familiar (En cuadrito como el feed) ──
                      FamilyRankingSection(
                        members: _wallService.members,
                        loading: _wallService.membersLoading,
                        errorMessage: _wallService.membersError,
                        onRetry: () => _wallService.loadWallData(notify: true),
                      ),

                      const SizedBox(height: 18),

                      // ── CA-4.1-3: Feed Social en Tiempo Real con Reacciones ──
                      FamilyFeedSection(
                        items: _wallService.feed,
                        onReactionTap: (feedId, emoji) {
                          _wallService.toggleReaction(feedId, emoji);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
