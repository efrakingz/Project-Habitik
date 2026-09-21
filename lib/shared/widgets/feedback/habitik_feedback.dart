import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';

/// Sistema unificado de feedback visual (SnackBars / Banners flotantes).
/// 
/// Reemplaza la creación manual de `ScaffoldMessenger.of(context).showSnackBar`
/// en pantallas individuales, garantizando coherencia visual y sonora.
class HabitikFeedback {
  HabitikFeedback._();

  /// Muestra un aviso de éxito (verde esmeralda con icono de verificación).
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    AudioService.playSFX('click.mp3');
    _show(
      context: context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: HabitikColors.green700,
      duration: duration,
    );
  }

  /// Muestra un aviso de error (rojo con icono de advertencia).
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context: context,
      message: message.replaceAll('Exception:', '').trim(),
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFD32F2F),
      duration: duration,
    );
  }

  /// Muestra un aviso informativo o neutro (azul/verde con icono de información).
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    AudioService.playSFX('click.mp3');
    _show(
      context: context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: HabitikColors.green900,
      duration: duration,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: HabitikRadius.md_,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        elevation: 6,
      ),
    );
  }
}
