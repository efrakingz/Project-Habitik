import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EcoWordleKeyboard extends StatelessWidget {
  final Map<String, String> letterStates;
  final Function(String) onKeyPressed;
  final VoidCallback onEnterPressed;
  final VoidCallback onBackspacePressed;
  final bool disabled;

  const EcoWordleKeyboard({
    super.key,
    required this.letterStates,
    required this.onKeyPressed,
    required this.onEnterPressed,
    required this.onBackspacePressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
      ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE']
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF143320).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key == 'ENTER') {
                return _buildKey(
                  context: context,
                  label: 'ENTER',
                  flex: 2,
                  isSpecial: true,
                  onTap: disabled ? null : onEnterPressed,
                );
              } else if (key == 'BACKSPACE') {
                return _buildKey(
                  context: context,
                  icon: Icons.backspace_rounded,
                  flex: 2,
                  isSpecial: true,
                  onTap: disabled ? null : onBackspacePressed,
                );
              } else {
                return _buildKey(
                  context: context,
                  label: key,
                  state: letterStates[key],
                  onTap: disabled ? null : () => onKeyPressed(key),
                );
              }
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey({
    required BuildContext context,
    String? label,
    IconData? icon,
    int flex = 1,
    String? state,
    bool isSpecial = false,
    VoidCallback? onTap,
  }) {
    Color bgColor = const Color(0xFF2A533A); // Verde bosque cálido táctil
    Color shadowColor = const Color(0xFF1B3B28);
    Color textColor = Colors.white;

    if (state == 'verde') {
      bgColor = const Color(0xFF10B981);
      shadowColor = const Color(0xFF047857);
      textColor = Colors.white;
    } else if (state == 'amarillo') {
      bgColor = const Color(0xFFF59E0B);
      shadowColor = const Color(0xFFB45309);
      textColor = Colors.white;
    } else if (state == 'gris') {
      bgColor = const Color(0xFF334155);
      shadowColor = const Color(0xFF1E293B);
      textColor = Colors.white54;
    } else if (isSpecial) {
      if (label == 'ENTER') {
        bgColor = const Color(0xFF059669);
        shadowColor = const Color(0xFF047857);
      } else {
        bgColor = const Color(0xFF3B5B46);
        shadowColor = const Color(0xFF284131);
      }
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, color: textColor, size: 20)
                : Text(
                    label ?? '',
                    style: GoogleFonts.outfit(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: label == 'ENTER' ? 11.5 : 15.5,
                      letterSpacing: label == 'ENTER' ? 0.5 : 0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
