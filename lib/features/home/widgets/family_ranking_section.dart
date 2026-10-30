import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';

/// Sección de Ranking Familiar (CA-4.1-2).
/// Diseñada con estética Glassmorphism semitransparente dejando traslucir el fondo verde.
/// Admite modo minimalista (podio horizontal compacto) para fijarse en el tope del Muro.
class FamilyRankingSection extends StatefulWidget {
  final List<FamilyMember> members;
  final bool loading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool compact;
  final VoidCallback? onViewAll;

  const FamilyRankingSection({
    super.key,
    required this.members,
    this.loading = false,
    this.errorMessage,
    this.onRetry,
    this.compact = false,
    this.onViewAll,
  });

  @override
  State<FamilyRankingSection> createState() => _FamilyRankingSectionState();
}

class _FamilyRankingSectionState extends State<FamilyRankingSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final isMinimal = widget.compact && !_expanded;
        final hasMoreThanTwo = widget.members.length > 2;
        final displayedMembers = _expanded || !hasMoreThanTwo
            ? widget.members
            : widget.members.take(2).toList();

        final maxScore = widget.members.fold<int>(
          1,
          (prev, m) => m.xp > prev ? m.xp : prev,
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: isMinimal ? 10 : 16,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2E22) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? const Color(0x25FFFFFF)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : HabitikColors.green700.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Encabezado del Ranking ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Ranking Familiar',
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontSize: isMinimal ? 15 : 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (widget.members.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF122C1D).withValues(alpha: 0.9)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? HabitikColors.green700.withValues(alpha: 0.4)
                                      : HabitikColors.green300.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '${widget.members.length} ${widget.members.length == 1 ? "miembro" : "miembros"}',
                                style: GoogleFonts.outfit(
                                  color: isDark ? HabitikColors.green300 : HabitikColors.green800,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.compact)
                        InkWell(
                          onTap: () {
                            if (widget.onViewAll != null) {
                              widget.onViewAll!();
                            } else {
                              setState(() => _expanded = !_expanded);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _expanded ? 'Compactar' : 'Ver todos',
                                  style: GoogleFonts.outfit(
                                    color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  _expanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 16,
                                  color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: isMinimal ? 10 : 14),

                  if (widget.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: HabitikColors.green500,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else if (widget.errorMessage != null)
                    HabitikErrorView.compact(
                      message: 'Error al cargar miembros: ${widget.errorMessage}',
                      onRetry: widget.onRetry,
                    )
                  else if (widget.members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No hay otros miembros en la familia todavía.',
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white60 : HabitikColors.textLight,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    )
                  else if (isMinimal) ...[
                    // ── Podio Minimalista Horizontal (Top 1, 2, 3) ──
                    _buildMinimalPodio(isDark),
                  ] else ...[
                    // ── Lista Detallada con Barras y Racha ──
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedMembers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = displayedMembers[index];
                        return _buildRankingRow(
                          position: index + 1,
                          member: member,
                          score: member.xp,
                          maxScore: maxScore,
                          isDark: isDark,
                        );
                      },
                    ),

                    // ── Botón para Expandir / Contraer Ranking si hay más de 2 ──
                    if (hasMoreThanTwo && !widget.compact) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => setState(() => _expanded = !_expanded),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF132217) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _expanded
                                    ? 'Mostrar menos'
                                    : 'Ver ranking completo (${widget.members.length - 2} más)',
                                style: GoogleFonts.outfit(
                                  color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
      },
    );
  }

  /// Podio horizontal minimalista: distribuye los primeros puestos en columnas compactas
  Widget _buildMinimalPodio(bool isDark) {
    final topMembers = widget.members.take(3).toList();

    return Row(
      children: [
        for (int i = 0; i < topMembers.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _buildPodioCard(
              position: i + 1,
              member: topMembers[i],
              isDark: isDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPodioCard({
    required int position,
    required FamilyMember member,
    required bool isDark,
  }) {
    final isTop1 = position == 1;
    final isTop2 = position == 2;

    final String crownEmoji = isTop1 ? '👑' : (isTop2 ? '🥈' : '🥉');

    return InkWell(
      onTap: widget.onViewAll,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: isTop1
            ? (isDark ? const Color(0xFF2C2410) : const Color(0xFFFFFBEB))
            : (isDark ? const Color(0xFF142419).withValues(alpha: 0.8) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop1
              ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
              : (isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0)),
          width: isTop1 ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar con insignia de podio
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                letra: member.avatarLetra,
                colorHex: member.avatarColor,
                avatarUrl: member.avatarUrl,
                radius: 16,
              ),
              Positioned(
                top: -8,
                child: Text(
                  crownEmoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Nombre truncado
          Text(
            member.nombre.split(' ').first,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : HabitikColors.textDark,
              fontSize: 11.5,
              fontWeight: isTop1 ? FontWeight.w800 : FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Pill con XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: isTop1
                  ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.15)
                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${member.xp} XP',
              style: GoogleFonts.outfit(
                color: isTop1
                    ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                    : (isDark ? Colors.white70 : HabitikColors.textMid),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildRankingRow({
    required int position,
    required FamilyMember member,
    required int score,
    required int maxScore,
    required bool isDark,
  }) {
    final isTop1 = position == 1;
    final isTop2 = position == 2;
    final isTop3 = position == 3;

    Color badgeColor;
    String badgeEmoji;

    if (isTop1) {
      badgeColor = const Color(0xFFFFB300);
      badgeEmoji = '👑';
    } else if (isTop2) {
      badgeColor = const Color(0xFF90A4AE);
      badgeEmoji = '🥈';
    } else if (isTop3) {
      badgeColor = const Color(0xFFB08D57);
      badgeEmoji = '🥉';
    } else {
      badgeColor = isDark ? Colors.white24 : Colors.grey.shade400;
      badgeEmoji = '#$position';
    }

    final double barRatio = maxScore > 0 ? (score / maxScore).clamp(0.05, 1.0) : 0.05;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132217) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop1
              ? const Color(0xFFFFD54F).withValues(alpha: 0.6)
              : (isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0)),
          width: isTop1 ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Medalla o Número de Posición
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                badgeEmoji,
                style: TextStyle(
                  fontSize: (isTop1 || isTop2 || isTop3) ? 18 : 13,
                  fontWeight: FontWeight.w800,
                  color: (isTop1 || isTop2 || isTop3) ? null : badgeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar de Usuario
          UserAvatar(
            letra: member.avatarLetra,
            colorHex: member.avatarColor,
            avatarUrl: member.avatarUrl,
            radius: 18,
          ),
          const SizedBox(width: 10),

          // Nombre, Nivel y Racha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.nombre,
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isJefe || member.rol == 'jefe') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Jefe',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Nv. ${member.nivel}',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white60 : HabitikColors.textLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (member.rachaDias > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 9)),
                            const SizedBox(width: 2),
                            Text(
                              '${member.rachaDias} d',
                              style: const TextStyle(
                                color: Color(0xFFC2410C),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Puntos XP y Barra Proporcional
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score XP',
                style: GoogleFonts.outfit(
                  color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                height: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barRatio,
                    backgroundColor: isDark
                        ? const Color(0xFF203324)
                        : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop1
                          ? const Color(0xFFF59E0B)
                          : HabitikColors.green500,
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
