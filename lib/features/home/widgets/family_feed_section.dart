import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'family_feed_card.dart';

/// Sección de Feed Familiar en Tiempo Real (CA-4.1-3).
/// Despliega las tarjetas de retos completados con indicador en vivo y reacciones rápidas.
/// Muestra por defecto los 2 primeros retos y permite expandir para ver más.
class FamilyFeedSection extends StatefulWidget {
  final List<FamilyFeedItem> items;
  final void Function(String feedId, String emoji)? onReactionTap;

  const FamilyFeedSection({
    super.key,
    required this.items,
    this.onReactionTap,
  });

  @override
  State<FamilyFeedSection> createState() => _FamilyFeedSectionState();
}

class _FamilyFeedSectionState extends State<FamilyFeedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final hasMoreThanTwo = widget.items.length > 2;
        final displayedItems = _expanded || !hasMoreThanTwo
            ? widget.items
            : widget.items.take(2).toList();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2E22) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? HabitikColors.green700.withValues(alpha: 0.5)
                  : HabitikColors.green300.withValues(alpha: 0.7),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : HabitikColors.green600.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Encabezado del Feed con Indicador de Tiempo Real ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📢', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        'Feed de Actividad',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // Badge 'EN VIVO'
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF122C1D)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'EN VIVO',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF15803D),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (widget.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 34)),
                        const SizedBox(height: 8),
                        Text(
                          'Aún no hay retos completados hoy',
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : HabitikColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¡Completa un reto para inaugurar el muro!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white54 : HabitikColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = displayedItems[index];
                    return FamilyFeedCard(
                      item: item,
                      margin: EdgeInsets.zero,
                      onReactionTap: (emoji) => widget.onReactionTap?.call(item.id, emoji),
                    );
                  },
                ),

                // ── Botón para Cargar / Mostrar más actividades ──
                if (hasMoreThanTwo) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF132217) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _expanded
                                ? 'Mostrar menos'
                                : 'Ver más actividades (${widget.items.length - 2} más)',
                            style: GoogleFonts.outfit(
                              color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
