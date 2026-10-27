import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/effects/celebration_confetti.dart';

/// Diálogo emergente que se muestra al desbloquear un logro (CA-4.2C.2-3 y CP-POPUP-01).
/// Diseñado con estética minimalista, sobria y humana acorde a Canjes y Panel de Administración:
/// - Fondo calmado con desenfoque elegante, confeti moderado y vibración háptica.
/// - Tarjeta limpia de 1.2px de borde sin auras de neón ni efectos artificiales de IA.
class BadgeUnlockedDialog extends StatefulWidget {
  final AchievementItem badge;
  final VoidCallback? onDismiss;

  const BadgeUnlockedDialog({
    super.key,
    required this.badge,
    this.onDismiss,
  });

  /// Muestra el diálogo modal asegurando la vibración háptica y confeti
  static Future<void> show(
    BuildContext context, {
    required AchievementItem badge,
    VoidCallback? onDismiss,
  }) async {
    // Vibración háptica requerida por CA-4.2C.2-3 (disparo inmediato)
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BadgeUnlockedDialog(
        badge: badge,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<BadgeUnlockedDialog> createState() => _BadgeUnlockedDialogState();
}

class _BadgeUnlockedDialogState extends State<BadgeUnlockedDialog> {
  @override
  void initState() {
    super.initState();
    // Refuerzo háptico tras medio segundo para simular impacto de logro
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        HapticFeedback.vibrate();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Desenfoque oscuro de fondo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),

          // 2. Confeti festivo en pantalla completa
          const Positioned.fill(
            child: RepaintBoundary(
              child: CelebrationConfetti(
                autoPlay: true,
                duration: Duration(seconds: 4),
                numberOfParticles: 35,
              ),
            ),
          ),

          // 3. Tarjeta central minimalista de celebración de logro
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: const Color(0xFF14241B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: HabitikShadows.floating,
              ),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Etiqueta superior minimalista (estilo chip de Canjes)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '¡NUEVO LOGRO DESBLOQUEADO!',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFB45309),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Emblema cuadrado redondeado 68x68 con tinte orgánico
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D3826),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFA5DCB6).withValues(alpha: 0.6),
                        width: 1.4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.badge.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ).animate().scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack, duration: 400.ms),

                  const SizedBox(height: 14),

                  // Título de la medalla
                  Text(
                    widget.badge.nombre,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Categoría y Nivel
                  Text(
                    '${widget.badge.categoria} · ${widget.badge.nivelTier}',
                    style: GoogleFonts.outfit(
                      color: HabitikColors.green300,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Descripción del logro
                  Text(
                    widget.badge.descripcion,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Caja de Recompensas otorgadas limpia
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (widget.badge.xp > 0)
                          XpBadge(widget.badge.xp),
                        if (widget.badge.monedas > 0)
                          MonedasBadge(widget.badge.monedas),
                        DificultadBadge(widget.badge.dificultad),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón "¡GENIAL! 🏆" sólido y sobrio
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          HapticFeedback.lightImpact();
                        } catch (_) {}
                        Navigator.of(context).pop();
                        widget.onDismiss?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HabitikColors.green600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '¡GENIAL! 🏆',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.92, 0.92)),
        ],
      ),
    );
  }
}
