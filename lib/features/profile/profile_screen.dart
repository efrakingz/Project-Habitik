import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/navigation/app_router.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';
import 'package:habitik/features/auth/splash_screen.dart';
import 'package:habitik/features/profile/widgets/profile_dialogs.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? user;

  const ProfileScreen({
    super.key,
    this.user,
  });

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
      final list = data.map((json) => FamilyMember.fromJson(json)).toList();

      setState(() {
        _familyMembers = list;
        _loadingMembers = false;
      });
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
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          bottom: false,
          child: ScreenShell(
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
              onRefresh: _fetchFamilyMembers,
              color: HabitikColors.green600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  children: [
                    // Tarjeta de Identidad de Perfil
                    Container(
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
                        children: [
                          UserAvatar(
                            letra: _user.avatarLetra,
                            colorHex: _user.avatarColor,
                            avatarUrl: _user.avatarUrl,
                            radius: 42,
                            showBorder: true,
                          ).animate().scale(
                                begin: const Offset(0.8, 0.8),
                                duration: 500.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(height: 12),
                          Text(
                            _user.nombre,
                            style: TextStyle(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (_user.email != null && _user.email!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _user.email!,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : HabitikColors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          RolBadge(_user.rol, fontSize: 11),
                          const SizedBox(height: 16),
                          XpProgressBar(xp: _user.xp, nivel: _user.nivel),
                          if (_user.familyName != null && _user.familyName!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              '🏡 Hogar: ${_user.familyName}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : HabitikColors.textMid,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta VIP de Invitación (Solo para Jefe)
                    if (_user.isJefe) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isDark 
                              ? const LinearGradient(colors: [Color(0xFF1B3B2B), Color(0xFF14241A)]) 
                              : const LinearGradient(
                                  colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: HabitikRadius.lg_,
                          border: Border.all(
                            color: HabitikColors.green500.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: HabitikShadows.card,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: HabitikColors.heroGreen,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: HabitikShadows.colored(HabitikColors.green600),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('🏡', style: TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Invitar a mi Familia',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : HabitikColors.textDark,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Conecta a tus seres queridos para compartir metas de ahorro y retos en equipo.',
                                        style: TextStyle(
                                          color: isDark ? HabitikColors.green200 : HabitikColors.textMid,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _handleInvite,
                              icon: _generatingInvite 
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                    )
                                  : const Icon(Icons.qr_code_rounded, size: 18),
                              label: Text(
                                _generatingInvite ? 'Generando Invitación...' : '✨ Mostrar QR y Enlace de Invitación',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HabitikColors.green600,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: HabitikColors.green600.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, curve: Curves.easeOutQuad),
                      const SizedBox(height: 20),
                    ],

                    // Gestión de Cuenta
                    Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚙️ Gestión de Cuenta',
                            style: TextStyle(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: HabitikColors.green50.withAlpha(isDark ? 20 : 255),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_outline_rounded, color: isDark ? HabitikColors.green400 : HabitikColors.green700),
                              ),
                              title: Text(
                                'Editar Perfil',
                                style: TextStyle(
                                  color: isDark ? Colors.white : HabitikColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'Cambia tu nombre, letra y color de avatar',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : HabitikColors.textLight,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.grey.shade400),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('La edición de perfil estará disponible en la próxima actualización.'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: HabitikColors.green700,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Ajustes de Modo Oscuro
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                        borderRadius: HabitikRadius.lg_,
                        border: Border.all(
                          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: HabitikShadows.card,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                isDark ? '🌙' : '☀️',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tema Oscuro',
                                style: TextStyle(
                                  color: isDark ? Colors.white : HabitikColors.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: isDarkModeNotifier,
                            builder: (context, isDarkTheme, _) {
                              return Switch(
                                value: isDarkTheme,
                                onChanged: (val) {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, anim1, anim2) => ThemeTransitionScreen(targetIsDark: val),
                                      transitionsBuilder: (context, anim1, anim2, child) {
                                        return FadeTransition(opacity: anim1, child: child);
                                      },
                                      transitionDuration: 400.ms,
                                    ),
                                  );
                                },
                                activeThumbColor: HabitikColors.green500,
                                activeTrackColor: HabitikColors.green900,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Encabezado de Miembros del Hogar
                    Row(
                      children: [
                        const Text('👥', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          'Miembros del Hogar',
                          style: TextStyle(
                            color: isDark ? Colors.white : HabitikColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Listado de Miembros
                    if (_loadingMembers)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: CircularProgressIndicator(color: HabitikColors.green600),
                        ),
                      )
                    else if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C1E1E) : Colors.red.shade50,
                          borderRadius: HabitikRadius.md_,
                          border: Border.all(
                            color: isDark ? Colors.redAccent.withAlpha(50) : Colors.red.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Error al cargar miembros: $_errorMessage',
                              style: TextStyle(
                                color: isDark ? Colors.redAccent : Colors.red.shade800,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SecondaryButton(
                              label: 'Reintentar',
                              onTap: _fetchFamilyMembers,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      )
                    else if (_familyMembers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                          borderRadius: HabitikRadius.md_,
                          border: Border.all(
                            color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          ),
                        ),
                        child: const Text(
                          'No hay otros miembros en la familia todavía.',
                          style: TextStyle(color: HabitikColors.textLight, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _familyMembers.length,
                        itemBuilder: (context, index) {
                          final member = _familyMembers[index];
                          final maxXP = _familyMembers.fold<int>(
                            1,
                            (prev, elem) => elem.xp > prev ? elem.xp : prev,
                          );
                          return RankingCard(
                            position: index + 1,
                            member: member,
                            maxXp: maxXP,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
