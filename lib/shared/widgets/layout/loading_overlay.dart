import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';

/// Overlay de carga reutilizable con estética y colores de Habitik.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.message = 'Cargando...',
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16251B) : Colors.white,
              borderRadius: HabitikRadius.xl_,
              border: Border.all(
                color: isDark
                    ? const Color(0x30FFFFFF)
                    : HabitikColors.green500.withValues(alpha: 0.35),
                width: 2.0,
              ),
              boxShadow: HabitikShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                    valueColor: const AlwaysStoppedAnimation<Color>(HabitikColors.green500),
                    backgroundColor: HabitikColors.green100.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : HabitikColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
      ),
    );
  }
}
