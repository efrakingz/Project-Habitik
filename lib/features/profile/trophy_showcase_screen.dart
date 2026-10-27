import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/badge_service.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'widgets/badge_tile.dart';

/// Pantalla de Vitrina de Trofeos y Logros Familiares (HU 4.2C.2 y CA-4.2C-3).
/// Diseñada con estética minimalista, sobria y humana inspirada en Canjes y Panel de Control:
/// - Tarjetas horizontales de 1.2px de borde con iconografía pastel organizada.
/// - Métricas gamificadas limpias y selector de insignia destacada para el Feed Familiar.
/// - Cero animaciones invasivas ni sobrecarga de gradientes artificiales.
class TrophyShowcaseScreen extends StatefulWidget {
  final UserProfile? user;
  final List<AchievementItem>? initialBadges;

  const TrophyShowcaseScreen({
    super.key,
    this.user,
    this.initialBadges,
  });

  @override
  State<TrophyShowcaseScreen> createState() => _TrophyShowcaseScreenState();
}

class _TrophyShowcaseScreenState extends State<TrophyShowcaseScreen> {
  late UserProfile _user;
  final BadgeService _badgeService = BadgeService();
  List<AchievementItem> _allBadges = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'todas'; // 'todas', 'desbloqueadas', 'pendientes'

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? SessionService().currentUser ?? UserProfile.empty;
    if (widget.initialBadges != null && widget.initialBadges!.isNotEmpty) {
      _allBadges = widget.initialBadges!;
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _badgeService.fetchBadges(_user.id);
      if (!mounted) return;
      setState(() {
        _allBadges = result.logros;
        _isLoading = false;
        // Refrescar perfil con nivel actualizado
        _user = SessionService().currentUser ?? _user;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo conectar a la vitrina de trofeos';
        _isLoading = false;
      });
    }
  }

  List<AchievementItem> get _filteredBadges {
    return switch (_selectedFilter) {
      'desbloqueadas' => _allBadges.where((b) => b.desbloqueado).toList(),
      'pendientes' => _allBadges.where((b) => !b.desbloqueado).toList(),
      _ => _allBadges,
    };
  }

  AchievementItem? get _destacadoBadge {
    final key = _badgeService.badgeDestacado ?? _user.badgeDestacado;
    if (key == null) return null;
    try {
      return _allBadges.firstWhere((b) => b.key == key || b.emoji == key);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final total = _allBadges.length;
        final unlocked = _allBadges.where((b) => b.desbloqueado).length;
        final monedasLogros = _allBadges
            .where((b) => b.desbloqueado && b.reclamado)
            .fold<int>(0, (sum, b) => sum + b.monedas);
        final destacado = _destacadoBadge;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ScreenShell(
            titulo: 'Vitrina de Trofeos',
            subtitulo: '🏆 Colecciona medallas por tus hábitos sustentables',
            showBackButton: true,
            useDefaultBackground: false,
            body: RefreshIndicator(
              onRefresh: _loadData,
              color: HabitikColors.green600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Banner Superior: Selector de Insignia Destacada (CA-4.2C-3) ──
                    _FeaturedBadgeBanner(
                      user: _user,
                      destacado: destacado,
                      isDark: isDark,
                      onClear: () async {
                        await _badgeService.removerBadgeDestacado();
                        _loadData();
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── 2. Resumen de Estadísticas Gamificadas (Minimalista) ──
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Desbloqueadas',
                            value: '$unlocked / $total',
                            icon: '🏅',
                            color: isDark ? const Color(0xFF162A1D) : const Color(0xFFE8F5E9),
                            textColor: isDark ? HabitikColors.green300 : const Color(0xFF1B5E20),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Monedas de Logros',
                            value: '+$monedasLogros',
                            icon: '🪙',
                            color: isDark ? const Color(0xFF261D10) : const Color(0xFFFFF8E7),
                            textColor: isDark ? HabitikColors.amber300 : const Color(0xFFB78103),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'Nivel Jugador',
                            value: 'Nv. ${_user.nivel}',
                            icon: '⭐',
                            color: isDark ? const Color(0xFF1D2230) : const Color(0xFFF3E5F5),
                            textColor: isDark ? const Color(0xFF93C5FD) : const Color(0xFF6A1B9A),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── 3. Filtros: Todas, Desbloqueadas, Por Desbloquear ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todas ($total)', 'todas', isDark),
                          const SizedBox(width: 8),
                          _buildFilterChip('Desbloqueadas ($unlocked)', 'desbloqueadas', isDark),
                          const SizedBox(width: 8),
                          _buildFilterChip('Por Desbloquear (${total - unlocked})', 'pendientes', isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 4. Lista Principal de Medallas (Diseño Canjes / Admin) ──
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: HabitikColors.green600),
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: isDark ? Colors.white60 : HabitikColors.textMid),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _loadData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HabitikColors.green600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_filteredBadges.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No hay medallas en esta categoría.',
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white54 : HabitikColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredBadges.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final badge = _filteredBadges[index];
                          return BadgeTile(
                            badge: badge,
                            isDark: isDark,
                            onBadgeUpdated: _loadData,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? HabitikColors.green600
              : (isDark ? const Color(0xFF1B261D) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? HabitikColors.green600
                : (isDark ? const Color(0x25FFFFFF) : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : HabitikColors.textDark),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Banner que exhibe la insignia actualmente destacada al lado del avatar.
/// Rediseñado con la estética limpia y sobria de Canjes y Panel de Control.
class _FeaturedBadgeBanner extends StatelessWidget {
  final UserProfile user;
  final AchievementItem? destacado;
  final bool isDark;
  final VoidCallback onClear;

  const _FeaturedBadgeBanner({
    required this.user,
    required this.destacado,
    required this.isDark,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? HabitikColors.darkCardBg : const Color(0xFFF7FBF8);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFBCE0C8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: HabitikShadows.card,
      ),
      child: Row(
        children: [
          // Avatar con Badge Destacado anclado de forma sutil
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                letra: user.avatarLetra,
                colorHex: user.avatarColor,
                avatarUrl: user.avatarUrl,
                radius: 24,
                showBorder: true,
              ),
              if (destacado != null)
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF261D10) : Colors.white,
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.4),
                    ),
                    child: Text(
                      destacado!.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // Texto descriptivo con jerarquía Outfit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'INSIGNIA DESTACADA',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  destacado != null
                      ? '${destacado!.nombre} ${destacado!.emoji}'
                      : 'Ninguna insignia seleccionada',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF0F291E),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  destacado != null
                      ? 'Visible en tu avatar del Feed Familiar'
                      : 'Toca una medalla para lucirla con tu familia',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          if (destacado != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Remover insignia destacada',
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

/// Tarjeta simple y minimalista de estadística
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final Color textColor;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withValues(alpha: isDark ? 0.25 : 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: textColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white54 : HabitikColors.textMid,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
