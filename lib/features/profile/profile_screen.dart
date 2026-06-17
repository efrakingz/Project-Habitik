import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/constants/screen_headers.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/light_clear_background.dart';
import 'package:habitik/features/auth/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _user = UserProfile.mock;

  void _toggleTheme(BuildContext context, bool isDark) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim1, anim2) => FadeTransition(
          opacity: anim1,
          child: SplashScreen(
            onFinish: () => Navigator.pop(context),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      isDarkModeNotifier.value = isDark;
    });
  }
  final _achievements = AchievementItem.mockList;
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  int get _xpForNextLevel => _user.nivel * 500;
  double get _xpPct => (_user.xp / _xpForNextLevel).clamp(0.0, 1.0);
  int get _unlockedCount => _achievements.where((a) => a.desbloqueado).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Profile header ─────────────────────────────────────────────
              buildProfileHeader(
                context: context,
                nombre: _user.nombre,
                rol: _user.rol,
                familyName: _user.familyName,
                avatarLetra: _user.avatarLetra,
                avatarColor: _user.avatarColor,
                avatarUrl: _user.avatarUrl,
                avatarRadius: 34,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // ── Stats row ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        label: 'Nivel',
                        value: '${_user.nivel}',
                        icon: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatPill(
                        label: 'XP',
                        value: '${_user.xp}',
                        icon: const GameStarIcon(size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatPill(
                        label: 'Monedas',
                        value: '${_user.monedas}',
                        icon: const GameCoinIcon(size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatPill(
                        label: 'Logros',
                        value: '$_unlockedCount',
                        icon: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
              ),

              const SizedBox(height: 12),

              // XP bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_user.xp} / $_xpForNextLevel XP',
                          style: const TextStyle(
                            color: HabitikColors.green200,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Nivel ${_user.nivel + 1} →',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: HabitikRadius.xs_,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _xpPct),
                        duration: 800.ms,
                        curve: Curves.easeOut,
                        builder: (_, v, _) => LinearProgressIndicator(
                          value: v,
                          backgroundColor: HabitikColors.green600,
                          valueColor: const AlwaysStoppedAnimation(
                            HabitikColors.amber400,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Tab bar ───────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                decoration: BoxDecoration(
                  color: HabitikColors.green600,
                  borderRadius: HabitikRadius.md_,
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: HabitikRadius.sm_,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: HabitikColors.green700,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Nunito',
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Logros'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Ajustes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Body ──────────────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: Stack(
                      children: [
                        // Fondo interactivo claro de Flame
                        const Positioned.fill(
                          child: LightClearBackground(),
                        ),
                        TabBarView(
                          controller: _tabs,
                          children: [
                            // Logros
                            ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              children: [
                                Text(
                                  '$_unlockedCount / ${_achievements.length} logros desbloqueados',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._achievements.asMap().entries.map(
                                  (e) => AchievementCard(
                                    achievement: e.value,
                                    index: e.key,
                                  ),
                                ),
                              ],
                            ),

                            // Ajustes
                            ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              children: [
                                _SettingsGroup(
                                  title: '👤 Cuenta',
                                  items: [
                                    _SettingsItem(
                                      icon: Icons.person_outline,
                                      label: 'Editar Perfil',
                                      onTap: () {},
                                    ),
                                    _SettingsItem(
                                      icon: Icons.lock_outline,
                                      label: 'Cambiar contraseña',
                                      onTap: () {},
                                    ),
                                    _SettingsItem(
                                      icon: Icons.qr_code,
                                      label: 'Mi código QR familiar',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SettingsGroup(
                                  title: '🔔 Notificaciones',
                                  items: [
                                    _SettingsItem(
                                      icon: Icons.notifications_outlined,
                                      label: 'Notificaciones de retos',
                                      onTap: () {},
                                      trailing: Switch(
                                        value: true,
                                        onChanged: (_) {},
                                        activeThumbColor: HabitikColors.green600,
                                      ),
                                    ),
                                    _SettingsItem(
                                      icon: Icons.emoji_events_outlined,
                                      label: 'Logros desbloqueados',
                                      onTap: () {},
                                      trailing: Switch(
                                        value: true,
                                        onChanged: (_) {},
                                        activeThumbColor: HabitikColors.green600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SettingsGroup(
                                  title: '🎨 Tema de la App',
                                  items: [
                                    ValueListenableBuilder<bool>(
                                      valueListenable: isDarkModeNotifier,
                                      builder: (context, isDark, child) {
                                        return _SettingsItem(
                                          icon: Icons.dark_mode_outlined,
                                          label: 'Modo Oscuro',
                                          onTap: () {
                                            _toggleTheme(context, !isDark);
                                          },
                                          trailing: Switch(
                                            value: isDark,
                                            onChanged: (val) {
                                              _toggleTheme(context, val);
                                            },
                                            activeThumbColor: HabitikColors.green600,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SettingsGroup(
                                  title: '🔊 Sonido y Volumen',
                                  items: [
                                    _SettingsVolumeItem(
                                      icon: Icons.music_note_rounded,
                                      label: 'Música de fondo',
                                      volume: AudioService.bgmVolume,
                                      onChanged: (newVol) {
                                        setState(() {
                                          AudioService.setBGMVolume(newVol);
                                        });
                                      },
                                    ),
                                    _SettingsVolumeItem(
                                      icon: Icons.volume_up_rounded,
                                      label: 'Efectos de sonido',
                                      volume: AudioService.sfxVolume,
                                      onChanged: (newVol) {
                                        setState(() {
                                          AudioService.setSFXVolume(newVol);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SettingsGroup(
                                  title: '🌿 Sobre Habitik',
                                  items: [
                                    _SettingsItem(
                                      icon: Icons.info_outline,
                                      label: 'Acerca de la app',
                                      onTap: () {},
                                    ),
                                    _SettingsItem(
                                      icon: Icons.help_outline,
                                      label: 'Ayuda y soporte',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {},
                                  child: Builder(
                                    builder: (context) {
                                      final isDark = Theme.of(context).brightness == Brightness.dark;
                                      return Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF3A1F1F) : Colors.red.shade50,
                                          borderRadius: HabitikRadius.md_,
                                          border: Border.all(color: isDark ? const Color(0xFF6E2B2B) : Colors.red.shade200),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Cerrar sesión',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Widget icon;
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: HabitikColors.whiteOverlay20,
        borderRadius: HabitikRadius.md_,
      ),
      child: Column(
        children: [
          SizedBox(height: 20, child: icon),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: HabitikColors.green200, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC),
            borderRadius: HabitikRadius.lg_,
            border: Border.all(color: isDark ? const Color(0x30FFFFFF) : Colors.white, width: 3.0),
            boxShadow: HabitikShadows.card,
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: HabitikRadius.md_,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isDark ? HabitikColors.green400 : HabitikColors.green600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white38 : HabitikColors.textHint,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}

class _SettingsVolumeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double volume;
  final ValueChanged<double> onChanged;

  const _SettingsVolumeItem({
    required this.icon,
    required this.label,
    required this.volume,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (volume * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: isDark ? HabitikColors.green400 : HabitikColors.green600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : HabitikColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Decrement button
          GestureDetector(
            onTap: volume > 0.0
                ? () {
                    AudioService.playSFX('click.mp3');
                    onChanged((volume - 0.1).clamp(0.0, 1.0));
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: volume > 0.0
                    ? (isDark ? const Color(0xFF141F17) : HabitikColors.green100)
                    : (isDark ? const Color(0xFF161E1A) : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_rounded,
                color: volume > 0.0
                    ? (isDark ? HabitikColors.green400 : HabitikColors.green700)
                    : (isDark ? Colors.white10 : Colors.grey.shade400),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Volume level text
          SizedBox(
            width: 42,
            child: Text(
              '$pct%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : HabitikColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Increment button
          GestureDetector(
            onTap: volume < 1.0
                ? () {
                    AudioService.playSFX('click.mp3');
                    onChanged((volume + 0.1).clamp(0.0, 1.0));
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: volume < 1.0
                    ? (isDark ? const Color(0xFF141F17) : HabitikColors.green100)
                    : (isDark ? const Color(0xFF161E1A) : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: volume < 1.0
                    ? (isDark ? HabitikColors.green400 : HabitikColors.green700)
                    : (isDark ? Colors.white10 : Colors.grey.shade400),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
