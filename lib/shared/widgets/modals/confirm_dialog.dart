import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';

/// Modal de confirmación estilizado estilo videojuego casual (Habitik 3D).
/// 
/// Reemplaza los AlertDialog genéricos y unifica diálogos como:
/// - Salir de minijuegos perdiendo progreso
/// - Limpiar historial o notificaciones
/// - Cerrar sesión
class HabitikConfirmDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const HabitikConfirmDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'CONFIRMAR',
    this.cancelLabel = 'CANCELAR',
    this.icon = Icons.warning_rounded,
    this.iconColor,
    this.iconBgColor,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  /// Muestra el diálogo y retorna `true` si el usuario confirmó la acción.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'CONFIRMAR',
    String cancelLabel = 'CANCELAR',
    IconData icon = Icons.warning_rounded,
    Color? iconColor,
    Color? iconBgColor,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => HabitikConfirmDialog(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultIconColor = isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final defaultIconBgColor = isDestructive
        ? (isDark ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2))
        : (isDark ? const Color(0xFF382C13) : const Color(0xFFFEF3C7));

    final effectiveIconColor = iconColor ?? defaultIconColor;
    final effectiveIconBgColor = iconBgColor ?? defaultIconBgColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16251B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? const Color(0x30FFFFFF)
                : HabitikColors.green500.withValues(alpha: 0.25),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            if (!isDark)
              BoxShadow(
                color: HabitikColors.green100.withValues(alpha: 0.5),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono animado superior
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: effectiveIconBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveIconColor.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 38,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.08, 1.08),
                  duration: 1200.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 18),

            // Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : HabitikColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),

            // Descripción
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : HabitikColors.textMid,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Botón Principal
            GestureDetector(
              onTap: () {
                AudioService.playSFX('click.mp3');
                if (onConfirm != null) {
                  onConfirm!();
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isDestructive
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        )
                      : const LinearGradient(
                          colors: [HabitikColors.green500, HabitikColors.green700],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDestructive ? Colors.red : HabitikColors.green600)
                          .withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  confirmLabel,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón Secundario (Cancelar)
            GestureDetector(
              onTap: () {
                AudioService.playSFX('click.mp3');
                if (onCancel != null) {
                  onCancel!();
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: Container(
                width: double.infinity,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF223528) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white70 : HabitikColors.textMid,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.92, 0.92)),
    );
  }
}
