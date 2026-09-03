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
import 'package:habitik/features/profile/widgets/profile_dialogs.dart';

// Import newly created widgets
import 'package:habitik/features/profile/widgets/profile_identity_card.dart';
import 'package:habitik/features/profile/widgets/profile_invite_card.dart';
import 'package:habitik/features/profile/widgets/profile_settings_card.dart';
import 'package:habitik/features/profile/widgets/profile_family_list.dart';

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
    _user = widget.user ?? SessionService().currentUser ?? UserProfile.mock;
    _fetchFamilyMembers();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await ApiClient().get('/auth/perfil/${_user.id}');
      if (!mounted) return;

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['ok'] == true && jsonResponse['data'] != null) {
        final gamifiedData = jsonResponse['data'];

        final newNivel = gamifiedData['nivel'] is num
            ? (gamifiedData['nivel'] as num).toInt()
            : int.tryParse('${gamifiedData['nivel']}') ?? _user.nivel;

        final rawXp = gamifiedData['xp_total'] ?? gamifiedData['total_xp'] ?? gamifiedData['xp'];
        final newXp = rawXp is num
            ? (rawXp as num).toInt()
            : int.tryParse('$rawXp') ?? _user.xp;

        final rawMonedas = gamifiedData['saldo_monedas'] ?? gamifiedData['monedas'];
        final newMonedas = rawMonedas is num
            ? (rawMonedas as num).toInt()
            : int.tryParse('$rawMonedas') ?? _user.monedas;

        final newRacha = gamifiedData['racha_dias'] is num
            ? (gamifiedData['racha_dias'] as num).toInt()
            : int.tryParse('${gamifiedData['racha_dias']}') ?? _user.rachaDias;

        final levelUp = newNivel > _user.nivel;

        setState(() {
          _user = _user.copyWith(
            nivel: newNivel,
            xp: newXp,
            monedas: newMonedas,
            rachaDias: newRacha,
          );
        });

        // Persistir la data gamificada en la caché local
        await SessionService().updateRewardsAndXp(
          xp: newXp,
          monedas: newMonedas,
          nivel: newNivel,
          rachaDias: newRacha,
        );

        if (levelUp && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Felicidades! Has subido al nivel $newNivel',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: HabitikColors.green600,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
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
      
      final List<FamilyMember> enrichedList = [];
      for (final json in data) {
        var member = FamilyMember.fromJson(json);
        
        // Si el miembro es el usuario actual, usamos sus métricas cacheadas de la sesión actual
        if (member.id == _user.id) {
          member = member.copyWith(xp: _user.xp, nivel: _user.nivel);
        } else if (member.xp == 0) {
          // Si el backend no proveyó XP (porque solo existe en endpoints gamificados), lo enriquecemos
          try {
            final perfRes = await ApiClient().get('/auth/perfil/${member.id}');
            final perfData = jsonDecode(perfRes.body);
            if (perfData['ok'] == true && perfData['data'] != null) {
              final gData = perfData['data'];
              final rawXp = gData['xp_total'] ?? gData['total_xp'] ?? gData['xp'];
              final mXp = rawXp is num ? (rawXp as num).toInt() : int.tryParse('$rawXp') ?? member.xp;
              final mNivel = gData['nivel'] is num ? (gData['nivel'] as num).toInt() : int.tryParse('${gData['nivel']}') ?? member.nivel;
              member = member.copyWith(xp: mXp, nivel: mNivel);
            }
          } catch (e) {
            // Ignorar y mantener el 0 por defecto si falla el enriquecimiento
          }
        }
        enrichedList.add(member);
      }
      
      // Ordenar por ranking de XP (descendente)
      enrichedList.sort((a, b) => b.xp.compareTo(a.xp));

      if (mounted) {
        setState(() {
          _familyMembers = enrichedList;
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
    await ProfileDialogs.showInviteQRDialog(context);
    if (mounted) {
      setState(() => _generatingInvite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenShell(
        titulo: 'Mi Perfil',
        subtitulo: '${_user.nombre} · ${_user.rol.toUpperCase()}',
        showBackButton: true,
        headerActions: [
          IconActionButton(
            icon: Icons.logout_rounded,
            onTap: () => RootRouter.logout(context),
            bgColor: HabitikColors.orange500,
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchUserProfile();
            await _fetchFamilyMembers();
          },
          color: HabitikColors.green600,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                ProfileIdentityCard(user: _user, isDark: isDark),
                const SizedBox(height: 20),

                ProfileInviteCard(
                  user: _user,
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
  }
}
