import 'package:flutter/material.dart';

enum AnswerOptionState { defaultState, selected, correct, incorrect, dimmed }

class AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final AnswerOptionState state;
  final bool isDisabled;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    required this.isDisabled,
    required this.onTap,
  });

  static const List<String> _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final letter = index >= 0 && index < _letters.length
        ? _letters[index]
        : '${index + 1}';

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = const Color(0xFF212121);
    Color badgeBgColor = const Color(0xFFF3E5F5);
    Color badgeTextColor = const Color(0xFF7B1FA2);
    Widget? trailingIcon;
    double opacity = 1.0;

    switch (state) {
      case AnswerOptionState.defaultState:
        bgColor = Colors.white;
        borderColor = const Color(0xFFE0E0E0);
        break;
      case AnswerOptionState.selected:
        bgColor = const Color(0xFFF3E5F5);
        borderColor = const Color(0xFF9C27B0);
        badgeBgColor = const Color(0xFF9C27B0);
        badgeTextColor = Colors.white;
        break;
      case AnswerOptionState.correct:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF43A047);
        textColor = const Color(0xFF1B5E20);
        badgeBgColor = const Color(0xFF43A047);
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF2E7D32),
          size: 24,
        );
        break;
      case AnswerOptionState.incorrect:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFE53935);
        textColor = const Color(0xFFB71C1C);
        badgeBgColor = const Color(0xFFE53935);
        badgeTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFC62828),
          size: 24,
        );
        break;
      case AnswerOptionState.dimmed:
        opacity = 0.45;
        break;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
          highlightColor: const Color(0xFF9C27B0).withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Badge letra A, B, C, D
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: badgeTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Texto de la opción
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                ),

                // Icono trailing (check o cross)
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
