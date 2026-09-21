import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';

/// Modal bottom sheet reutilizable para secciones, retos o funciones en desarrollo.
class ComingSoonModal extends StatelessWidget {
  final String title;
  final String emoji;
  final String? description;
  final String buttonLabel;

  const ComingSoonModal({
    super.key,
    required this.title,
    this.emoji = '🌱',
    this.description,
    this.buttonLabel = '¡Entendido!',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String emoji = '🌱',
    String? description,
    String buttonLabel = '¡Entendido!',
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ComingSoonModal(
        title: title,
        emoji: emoji,
        description: description,
        buttonLabel: buttonLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
        borderRadius: HabitikRadius.xl_,
        border: Border.all(
          color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green500.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Emoji animado
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 14),

          // Título
          Text(
            '¡Próximamente!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : HabitikColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Descripción
          Text(
            description ??
                'La función o reto "$title" está actualmente en desarrollo y estará disponible en una próxima actualización.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : HabitikColors.textMid,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Botón entendido
          GestureDetector(
            onTap: () {
              AudioService.playSFX('click.mp3');
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [HabitikColors.green500, HabitikColors.green700],
                ),
                borderRadius: HabitikRadius.md_,
                boxShadow: [
                  BoxShadow(
                    color: HabitikColors.green600.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                buttonLabel,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
