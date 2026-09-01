import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

class StatBadge extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const StatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3E32) : color.withAlpha(25),
        borderRadius: HabitikRadius.md_,
        border: Border.all(
          color: isDark ? color.withAlpha(50) : color.withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : HabitikColors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
