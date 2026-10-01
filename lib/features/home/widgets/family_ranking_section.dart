import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';

/// Sección de Ranking Familiar (CA-4.1-2).
/// Diseñada en un cuadro idéntico al Feed de Actividad, compacto y sin espacios sobrantes.
/// Muestra por defecto los 2 primeros puestos y permite expandir para ver a todos.
class FamilyRankingSection extends StatefulWidget {
  final List<FamilyMember> members;
  final bool loading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const FamilyRankingSection({
    super.key,
    required this.members,
    this.loading = false,
    this.errorMessage,
    this.onRetry,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2E22) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? HabitikColors.green700.withValues(alpha: 0.5)
                  : HabitikColors.green300.withValues(alpha: 0.7),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : HabitikColors.green600.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                      const Text('🏆', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'Ranking Familiar',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (widget.members.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF122C1D)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.members.length} ${widget.members.length == 1 ? "miembro" : "miembros"}',
                        style: GoogleFonts.outfit(
                          color: isDark ? HabitikColors.green300 : HabitikColors.green800,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              if (widget.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: HabitikColors.green500,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (widget.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Error al cargar miembros: ${widget.errorMessage}',
                          style: TextStyle(
                            color: isDark ? Colors.redAccent : Colors.red.shade800,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.onRetry != null) ...[
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: widget.onRetry,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else if (widget.members.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No hay otros miembros en la familia todavía.',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white60 : HabitikColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else ...[
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
                if (hasMoreThanTwo) ...[
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
