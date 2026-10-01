import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';

enum RankingPeriodFilter { semanal, mensual }

/// Sección de Ranking Familiar (CA-4.1-2).
/// Muestra avatar, nivel, racha y posición con ordenamiento semanal y mensual.
class FamilyRankingSection extends StatefulWidget {
  final List<FamilyMember> members;

  const FamilyRankingSection({
    super.key,
    required this.members,
  });

  @override
  State<FamilyRankingSection> createState() => _FamilyRankingSectionState();
}

class _FamilyRankingSectionState extends State<FamilyRankingSection> {
  RankingPeriodFilter _selectedFilter = RankingPeriodFilter.semanal;

  List<FamilyMember> get _sortedMembers {
    final list = List<FamilyMember>.from(widget.members);
    if (_selectedFilter == RankingPeriodFilter.semanal) {
      list.sort((a, b) => b.xpSemanal.compareTo(a.xpSemanal));
    } else {
      list.sort((a, b) => b.xp.compareTo(a.xp));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final sorted = _sortedMembers;
        final maxScore = sorted.fold<int>(
          1,
          (prev, m) {
            final score = _selectedFilter == RankingPeriodFilter.semanal
                ? m.xpSemanal
                : m.xp;
            return score > prev ? score : prev;
          },
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            children: [
              // ── 1. Encabezado y Filtro Semanal / Mensual ──
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
                  // Selector de Periodo
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF102015)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterChip(
                          label: 'Semanal',
                          filter: RankingPeriodFilter.semanal,
                          isDark: isDark,
                        ),
                        _buildFilterChip(
                          label: 'Mensual',
                          filter: RankingPeriodFilter.mensual,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (sorted.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No hay datos de miembros disponibles',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white54 : HabitikColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sorted.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final member = sorted[index];
                    final position = index + 1;
                    final currentXp = _selectedFilter == RankingPeriodFilter.semanal
                        ? member.xpSemanal
                        : member.xp;

                    return _buildRankingRow(
                      position: position,
                      member: member,
                      score: currentXp,
                      maxScore: maxScore,
                      isDark: isDark,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required RankingPeriodFilter filter,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? HabitikColors.green500
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: HabitikColors.green500.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white60 : HabitikColors.textLight),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
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
            width: 32,
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
            radius: 19,
          ),
          const SizedBox(width: 12),

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
                    if (member.rol == 'jefe') ...[
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
                    const SizedBox(width: 8),
                    // Racha de días (fuego)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 2),
                          Text(
                            '${member.rachaDias} d',
                            style: const TextStyle(
                              color: Color(0xFFC2410C),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                width: 65,
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
