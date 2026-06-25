import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/navigation/app_router.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/core/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserProfile _user;

  @override
  void initState() {
    super.initState();
    _user = SessionService().currentUser ?? UserProfile.mock;
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
            headerLeft: Navigator.canPop(context)
                ? null
                : GestureDetector(
                    onTap: () {},
                    child: UserAvatar(
                      letra: _user.avatarLetra,
                      colorHex: _user.avatarColor,
                      radius: 18,
                    ),
                  ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
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
                        const Text('👤', style: TextStyle(fontSize: 54))
                            .animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        const Text(
                          'Ajustes de Perfil',
                          style: TextStyle(
                            color: HabitikColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Administra los datos de tu cuenta, logros ecológicos, volumen del juego y tema visual.',
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
                              '👤 Editar Ajustes',
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
                  const SizedBox(height: 20),
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
                        const Text('🚪', style: TextStyle(fontSize: 54))
                            .animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        const Text(
                          'Sesión de Pruebas',
                          style: TextStyle(
                            color: HabitikColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cierra la sesión actual para volver a probar los flujos de Login y Onboarding.',
                          style: TextStyle(
                            color: HabitikColors.textLight,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => RootRouter.logout(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: HabitikColors.fireStreak,
                              borderRadius: HabitikRadius.md_,
                              boxShadow: HabitikShadows.colored(const Color(0xFFFF1744)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Cerrar Sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
