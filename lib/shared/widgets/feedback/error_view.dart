import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';

/// Componente centralizado para visualización de estados de error.
/// Permite modo pantalla completa (por defecto) o modo compacto para tarjetas y secciones.
class HabitikErrorView extends StatelessWidget {
  final String? message;
  final String? title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final bool isCompact;

  const HabitikErrorView({
    super.key,
    this.message,
    this.title,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    this.icon = Icons.error_outline_rounded,
  }) : isCompact = false;

  const HabitikErrorView.compact({
    super.key,
    this.message,
    this.title,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    this.icon = Icons.error_outline_rounded,
  }) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayMessage = (message != null && message!.trim().isNotEmpty)
        ? message!.replaceAll('Exception: ', '').trim()
        : 'Ocurrió un problema inesperado. Por favor, intenta de nuevo.';

    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: HabitikColors.orange400),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    displayMessage,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white70 : HabitikColors.textMid,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: Text(
                    retryLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : HabitikColors.orange400).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: HabitikColors.orange500,
              ),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              displayMessage,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : HabitikColors.textMid,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  retryLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HabitikColors.green500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
