import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/navigation/app_router.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/modals/modals.dart';

import 'package:habitik/core/services/badge_service.dart';

// Import newly created widgets
import 'package:habitik/features/profile/widgets/profile_identity_card.dart';
import 'package:habitik/features/profile/widgets/profile_invite_card.dart';
import 'package:habitik/features/profile/widgets/profile_settings_card.dart';
import 'package:habitik/features/profile/widgets/profile_family_list.dart';
import 'package:habitik/features/profile/widgets/profile_badges_card.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _user;
  List<FamilyMember> _familyMembers = [];
  bool _loadingMembers = false;
  bool _generatingInvite = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? SessionService().currentUser ?? UserProfile.empty;
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchUserProfile(),
      _fetchFamilyMembers(),
    ]);
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await ApiClient().get('/auth/perfil/${_user.id}');
      if (!mounted) return;

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['ok'] == true && jsonResponse['data'] != null) {
        final updatedUser = UserProfile.fromJson(jsonResponse['data']);

        setState(() {
          _user = updatedUser;
        });

        // Persistir la data gamificada en la caché local
        await SessionService().updateRewardsAndXp(
          xp: updatedUser.xp,
          monedas: updatedUser.monedas,
          nivel: updatedUser.nivel,
          rachaDias: updatedUser.rachaDias,
        );


      }
    } catch (e) {
      debugPrint('Error al obtener perfil: $e');
    }
  }

  Future<void> _fetchFamilyMembers() async {
    if (_user.familyId == null || _user.familyId!.isEmpty) return;

    setState(() {
      _loadingMembers = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient().get('/familia/miembros');
      if (!mounted) return;

      final List<dynamic> data = jsonDecode(response.body);
      final rawMembers = data.map((json) {
        return FamilyMember.fromJson(json as Map<String, dynamic>);
      }).toList();

      // Enriquecer defensivamente desde la base de datos (/auth/perfil y /logros)
      final enriched = await BadgeService().enrichMembers(rawMembers);
      enriched.sort((a, b) => b.xp.compareTo(a.xp));

      if (mounted) {
        setState(() {
          _familyMembers = enriched;
          _loadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _loadingMembers = false;
        });
      }
    }
  }

  void _handleInvite() async {
    if (_generatingInvite) return;
    setState(() => _generatingInvite = true);
    await QrInviteModal.show(context);
    if (mounted) {
      setState(() => _generatingInvite = false);
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

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: ScreenShell(
                titulo: 'Mi Perfil',
                subtitulo: '${activeUser.nombre} · ${activeUser.rol.toUpperCase()}',
                showBackButton: true,
                headerActions: [
                  IconActionButton(
                    icon: Icons.info_outline_rounded,
                    onTap: () => ProfileStatsInfoModal.show(context, isDark: isDark),
                    bgColor: Colors.white.withAlpha(50),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  IconActionButton(
                    icon: Icons.logout_rounded,
                    onTap: () => RootRouter.logout(context),
                    bgColor: HabitikColors.orange500,
                  ),
                ],
                body: RefreshIndicator(
                  onRefresh: _loadData,
                  color: HabitikColors.green600,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      children: [
                        ProfileIdentityCard(user: activeUser, isDark: isDark),
                        const SizedBox(height: 20),

                        ProfileBadgesCard(
                          user: activeUser,
                          isDark: isDark,
                          onDataChanged: _loadData,
                        ),
                        const SizedBox(height: 20),

                        ProfileInviteCard(
                          user: activeUser,
                          isDark: isDark,
                          isGenerating: _generatingInvite,
                          onInvite: _handleInvite,
                        ),

                        ProfileSettingsCard(isDark: isDark),

                        ProfileFamilyList(
                          loading: _loadingMembers,
                          errorMessage: _errorMessage,
                          familyMembers: _familyMembers,
                          onRetry: _fetchFamilyMembers,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
