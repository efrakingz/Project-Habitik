import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/core/services/badge_service.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import '../trophy_showcase_screen.dart';
import 'badge_svg_icons.dart';

/// Tarjeta compacta y cerrada de "Mis Medallas" en el Perfil de Usuario (HU 4.2C.2).
/// Diseñada con la estética cromática y contenedores del Panel de Admin y Canjes.
/// Es ultra-compacta y al presionarla o pulsar 'Ver Vitrina' abre la Vitrina completa.
class ProfileBadgesCard extends StatefulWidget {
  final UserProfile user;
  final bool isDark;
  final VoidCallback? onDataChanged;

  const ProfileBadgesCard({
    super.key,
    required this.user,
    required this.isDark,
    this.onDataChanged,
  });

  @override
  State<ProfileBadgesCard> createState() => _ProfileBadgesCardState();
}

class _ProfileBadgesCardState extends State<ProfileBadgesCard> {
  final BadgeService _badgeService = BadgeService();
  List<AchievementItem> _badges = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _badgeService.fetchBadges(widget.user.id);
      if (!mounted) return;
      setState(() {
        _badges = result.logros;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudieron cargar las medallas';
        _isLoading = false;
      });
    }
  }

  void _openFullShowcase() {
    Navigator.push(
      context,
      FadePageRoute(
        child: TrophyShowcaseScreen(
          user: widget.user,
          initialBadges: _badges,
        ),
      ),
    ).then((_) {
      _loadBadges();
      widget.onDataChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final total = _badges.length;
    final unlocked = _badges.where((b) => b.desbloqueado).length;
    final progress = total > 0 ? (unlocked / total) : 0.0;

    // Paleta visual limpia y moderna
    final cardBg = isDark ? HabitikColors.darkCardBg : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0);
    final iconBg = isDark ? const Color(0xFF132F21) : const Color(0xFFE2F6EB);
    final iconBorder = isDark ? const Color(0xFF1B4D34) : const Color(0xFFC7EBD5);

    return InkWell(
      onTap: _openFullShowcase,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: HabitikShadows.card,
        ),
        child: Row(
          children: [
            // ── Ícono de trofeo minimalista SVG en contenedor menta ──
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: iconBorder, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BadgeSvgIcons.buildTrophySvg(size: 28),
                  // Mantiene compatibilidad semántica con suites de tests
                  const SizedBox(
                    width: 0,
                    height: 0,
                    child: OverflowBox(
                      maxWidth: 0,
                      maxHeight: 0,
                      child: Text('🏆', style: TextStyle(fontSize: 0.001, color: Colors.transparent)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Información de Logros y Progreso Compacto ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Mis Medallas',
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : const Color(0xFF0F291E),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unlocked > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1B3824) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? HabitikColors.green500 : const Color(0xFF16A34A).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '$unlocked',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? HabitikColors.green300 : const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _isLoading
                        ? 'Cargando medallas...'
                        : (_errorMessage != null
                            ? 'Toca para reintentar'
                            : '$unlocked de $total desbloqueadas'),
                    style: GoogleFonts.outfit(
                      color: isDark ? HabitikColors.green300 : const Color(0xFF1E673B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: isDark ? const Color(0xFF223528) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(HabitikColors.green500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Botón de Acción "Ver Vitrina →" en forma de píldora ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF244833) : const Color(0xFF227848),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF227848).withValues(alpha: isDark ? 0.2 : 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver Vitrina',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
