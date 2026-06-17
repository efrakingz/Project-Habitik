import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EnergyBar – barra de energía familiar con ahorro de luz y agua
// ─────────────────────────────────────────────────────────────────────────────
class EnergyBar extends StatelessWidget {
  final double pct; // 0.0 a 1.0
  final String luzLabel;
  final String aguaLabel;
  final String luzSaving;
  final String aguaSaving;

  const EnergyBar({
    super.key,
    required this.pct,
    required this.luzLabel,
    required this.aguaLabel,
    required this.luzSaving,
    required this.aguaSaving,
  });

  @override
  Widget build(BuildContext context) {
    final pctDisplay = (pct * 100).round();
    final barColor = pct >= 0.75
        ? HabitikColors.amber400
        : pct >= 0.4
            ? HabitikColors.orange400
            : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.colored(HabitikColors.green800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚡ Energía Familiar', style: TextStyle(color: HabitikColors.green200, fontSize: 11, fontWeight: FontWeight.w600)),
                  Text('Contribución colectiva del mes', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
              Text(
                '$pctDisplay%',
                style: const TextStyle(color: HabitikColors.amber400, fontSize: 28, fontWeight: FontWeight.w900),
              ).animate().scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.elasticOut),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: HabitikRadius.xs_,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: 800.ms,
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor: HabitikColors.green700,
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SavingsChip(icon: Icons.bolt, color: HabitikColors.amber400, title: 'Ahorro Luz', saving: luzSaving, label: luzLabel)),
              const SizedBox(width: 8),
              Expanded(child: _SavingsChip(icon: Icons.water_drop, color: HabitikColors.blue400, title: 'Ahorro Agua', saving: aguaSaving, label: aguaLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String saving;
  final String label;

  const _SavingsChip({required this.icon, required this.color, required this.title, required this.saving, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: HabitikColors.green700, borderRadius: HabitikRadius.md_),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 14), const SizedBox(width: 4), Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 4),
          Text(saving, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: HabitikRadius.xs_),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XpProgressBar – barra de progreso de XP del usuario
// ─────────────────────────────────────────────────────────────────────────────
class XpProgressBar extends StatelessWidget {
  final int xp;
  final int nivel;

  const XpProgressBar({super.key, required this.xp, required this.nivel});

  @override
  Widget build(BuildContext context) {
    final maxXp = nivel * 500;
    final pct = (xp / maxXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: HabitikColors.xpGold,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.colored(HabitikColors.amber400),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Nivel $nivel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ]),
              Text('$xp / $maxXp XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: HabitikRadius.xs_,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: 600.ms,
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor: Colors.white.withAlpha(60),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${maxXp - xp} XP para nivel ${nivel + 1}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RankingCard – fila de ranking de miembro familiar
// ─────────────────────────────────────────────────────────────────────────────
class RankingCard extends StatelessWidget {
  final int position;
  final FamilyMember member;
  final int maxXp;

  const RankingCard({super.key, required this.position, required this.member, required this.maxXp});

  @override
  Widget build(BuildContext context) {
    final isTop3 = position <= 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC),
        borderRadius: HabitikRadius.md_,
        border: Border.all(color: isDark ? const Color(0x30FFFFFF) : Colors.white, width: 3.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: isTop3
                ? Text(_medal(position), style: const TextStyle(fontSize: 18))
                : Text('$position', style: TextStyle(color: isDark ? Colors.white60 : HabitikColors.textLight, fontSize: 13, fontWeight: FontWeight.w800)),
          ),
          UserAvatar(letra: member.avatarLetra, colorHex: member.avatarColor, avatarUrl: member.avatarUrl, radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(member.nombre, style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  RolBadge(member.rol),
                ]),
                Text('Nivel ${member.nivel}', style: TextStyle(color: isDark ? Colors.white60 : HabitikColors.textLight, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${member.xp} XP', style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: HabitikRadius.xs_,
                child: SizedBox(
                  width: 50, height: 4,
                  child: LinearProgressIndicator(
                    value: maxXp > 0 ? (member.xp / maxXp).clamp(0.0, 1.0) : 0,
                    backgroundColor: isDark ? const Color(0xFF141F17) : HabitikColors.green100,
                    valueColor: AlwaysStoppedAnimation(isDark ? HabitikColors.green400 : HabitikColors.green600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (position * 80).ms).slideX(begin: 0.05, duration: 300.ms);
  }

  String _medal(int pos) => ['🥇', '🥈', '🥉'][pos - 1];
}
