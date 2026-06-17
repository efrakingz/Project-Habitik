import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/constants/screen_headers.dart';
import 'package:habitik/shared/widgets/interactive_backgrounds/light_clear_background.dart';

export 'package:habitik/core/constants/nav_items.dart';
export 'package:habitik/core/constants/screen_headers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScreenShell – shell base de todas las pantallas (header verde + body blanco)
// ─────────────────────────────────────────────────────────────────────────────
class ScreenShell extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget body;
  final List<Widget>? headerActions;
  final Widget? headerLeft;
  final bool roundedTop;

  const ScreenShell({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.body,
    this.headerActions,
    this.headerLeft,
    this.roundedTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // ── Header ───────────────────────────────────────────────────────────
        buildScreenHeader(
          context: context,
          titulo: titulo,
          subtitulo: subtitulo,
          headerLeft: headerLeft,
          headerActions: headerActions,
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111D15) : HabitikColors.bgWhite,
              borderRadius: roundedTop
                  ? const BorderRadius.vertical(top: Radius.circular(28))
                  : BorderRadius.zero,
            ),
            child: ClipRRect(
              borderRadius: roundedTop
                  ? const BorderRadius.vertical(top: Radius.circular(28))
                  : BorderRadius.zero,
              child: Stack(
                children: [
                  // Fondo interactivo claro de Flame
                  const Positioned.fill(
                    child: LightClearBackground(),
                  ),
                  body,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GameSectionTitle – encabezado de sección con alta visibilidad y sombra
// ─────────────────────────────────────────────────────────────────────────────
class GameSectionTitle extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? emoji;

  const GameSectionTitle({
    super.key,
    this.icon,
    required this.title,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon!, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
