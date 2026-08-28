import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';

class OptionChipGroup extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final double fontSize;

  const OptionChipGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((op) {
        final selected = selectedValue == op;
        return GestureDetector(
          onTap: () => onSelected(op),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected
                  ? HabitikColors.heroGreen
                  : const LinearGradient(colors: [HabitikColors.green50, HabitikColors.green50]),
              borderRadius: HabitikRadius.md_,
              border: Border.all(color: selected ? HabitikColors.green600 : HabitikColors.divider),
            ),
            child: Text(
              op,
              style: TextStyle(
                color: selected ? Colors.white : HabitikColors.textDark,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
