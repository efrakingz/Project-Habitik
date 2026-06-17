import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RolBadge – etiqueta de rol con color e ícono
// ─────────────────────────────────────────────────────────────────────────────
class RolBadge extends StatelessWidget {
  final String rol;
  final double fontSize;

  const RolBadge(this.rol, {super.key, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final (text, bg, fg) = _rolStyle(rol.toLowerCase());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.6, vertical: fontSize * 0.2),
      decoration: BoxDecoration(color: bg, borderRadius: HabitikRadius.xxl_),
      child: Text(text, style: TextStyle(color: fg, fontSize: fontSize, fontWeight: FontWeight.w800)),
    );
  }

  static (String, Color, Color) _rolStyle(String r) {
    if (r == 'jefe')    return ('👑 Jefe',   const Color(0xFFFFECB3), const Color(0xFFF57C00));
    if (r == 'jefa')    return ('👑 Jefa',   const Color(0xFFFFECB3), const Color(0xFFF57C00));
    if (r == 'papa' || r == 'papá') return ('👨 Papá', const Color(0xFFBBDEFB), const Color(0xFF1976D2));
    if (r == 'mama' || r == 'mamá') return ('👩 Mamá', const Color(0xFFF8BBD0), const Color(0xFFC2185B));
    if (r == 'hija')    return ('👧 Hija',   const Color(0xFFF8BBD0), const Color(0xFFC2185B));
    if (r == 'hijo')    return ('👦 Hijo',   const Color(0xFFE1BEE7), const Color(0xFF7B1FA2));
    if (r == 'co-admin' || r == 'coadmin') return ('⭐ Co-Admin', const Color(0xFFBBDEFB), const Color(0xFF1976D2));
    return ('👤 Miembro', const Color(0xFFE1BEE7), const Color(0xFF7B1FA2));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XpBadge – badge de XP ganado
// ─────────────────────────────────────────────────────────────────────────────
class XpBadge extends StatelessWidget {
  final int xp;
  final bool positive;

  const XpBadge(this.xp, {super.key, this.positive = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: positive ? HabitikColors.amber100 : Colors.red.shade100,
        borderRadius: HabitikRadius.xxl_,
      ),
      child: Text(
        '${positive ? '+' : '-'}$xp XP',
        style: TextStyle(
          color: positive ? const Color(0xFFE65100) : Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MonedasBadge – badge de monedas
// ─────────────────────────────────────────────────────────────────────────────
class MonedasBadge extends StatelessWidget {
  final int monedas;
  final bool positive;

  const MonedasBadge(this.monedas, {super.key, this.positive = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: positive ? HabitikColors.amber200 : Colors.red.shade100,
        borderRadius: HabitikRadius.xxl_,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${positive ? '+' : '-'}$monedas ',
            style: TextStyle(
              color: positive ? const Color(0xFFBF360C) : Colors.red.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const GameCoinIcon(size: 11),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DificultadBadge – badge de dificultad de logro
// ─────────────────────────────────────────────────────────────────────────────
class DificultadBadge extends StatelessWidget {
  final String dificultad;

  const DificultadBadge(this.dificultad, {super.key});

  @override
  Widget build(BuildContext context) {
    final (text, bg, fg) = _style(dificultad.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: HabitikRadius.xs_),
      child: Text(text, style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  static (String, Color, Color) _style(String d) {
    if (d == 'fácil' || d == 'facil') return ('FÁCIL', HabitikColors.green100, HabitikColors.green700);
    if (d == 'medio')   return ('MEDIO', HabitikColors.blue100, HabitikColors.blue500);
    if (d == 'difícil' || d == 'dificil') return ('DIFÍCIL', HabitikColors.amber200, const Color(0xFFE65100));
    return ('BASE', HabitikColors.green100, HabitikColors.green700);
  }
}
