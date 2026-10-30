import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';

/// Tarjeta principal de acciones para el inicio de Scan de Boletas (HU 3.2).
/// Reemplaza el modal 'próximamente' por opciones directas de captura y entrada manual.
class ScanActionCard extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onPickImage;
  final VoidCallback onPickPdf;
  final VoidCallback onManualInput;

  const ScanActionCard({
    super.key,
    required this.onTakePhoto,
    required this.onPickImage,
    required this.onPickPdf,
    required this.onManualInput,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? HabitikColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : HabitikColors.green200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : HabitikColors.green900.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? HabitikColors.darkBgAlert
                      : HabitikColors.green50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? HabitikColors.green600.withValues(alpha: 0.3)
                        : HabitikColors.green300,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('📄', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escáner de Boletas',
                      style: GoogleFonts.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : HabitikColors.green900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Audita y registra tu consumo mensual',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : HabitikColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cuadrícula / Opciones de acción
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Tomar foto',
                  subtitle: 'Cámara',
                  badgeColor: HabitikColors.green600,
                  onTap: onTakePhoto,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.photo_library_rounded,
                  label: 'Elegir imagen',
                  subtitle: 'JPG, PNG, HEIC',
                  badgeColor: HabitikColors.blue500,
                  onTap: onPickImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Elegir PDF',
                  subtitle: '1ª página',
                  badgeColor: HabitikColors.orange500,
                  onTap: onPickPdf,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.edit_note_rounded,
                  label: 'Ingresar manual',
                  subtitle: 'Sin documento',
                  badgeColor: HabitikColors.purple500,
                  onTap: onManualInput,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: isDark
                ? HabitikColors.darkInputFill
                : HabitikColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : HabitikColors.divider,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : HabitikColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : HabitikColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

