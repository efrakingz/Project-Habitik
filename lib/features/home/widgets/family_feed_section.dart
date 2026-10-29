import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'family_feed_card.dart';

/// Sección de Feed Familiar en Tiempo Real (CA-4.1-3).
/// Diseñada con estética Glassmorphism semitransparente dejando traslucir el fondo verde.
/// Soporta scroll continuo vertical independiente deslizándose por debajo del Top fijo.
class FamilyFeedSection extends StatefulWidget {
  final List<FamilyFeedItem> items;
  final void Function(String feedId, String emoji)? onReactionTap;
  final bool loading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isScrollable;

  const FamilyFeedSection({
    super.key,
    required this.items,
    this.onReactionTap,
    this.loading = false,
    this.errorMessage,
    this.onRetry,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isScrollable = false,
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
        // En modo scrollable continuo se muestran todas las actividades
        final displayedItems = widget.isScrollable || _expanded || !hasMoreThanTwo
            ? widget.items
            : widget.items.take(2).toList();

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B2E22).withValues(alpha: 0.82)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : HabitikColors.green700.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: widget.isScrollable ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  // ── Encabezado del Feed con Indicador de Tiempo Real ──
                  _buildHeader(isDark),

                  const SizedBox(height: 12),

                  if (widget.loading && widget.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: HabitikColors.green500,
                        ),
                      ),
                    )
                  else if (widget.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                  else if (widget.isScrollable) ...[
                    // ── Modo Scroll Continuo Independiente ──
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 95),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: displayedItems.length + (widget.hasMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index < displayedItems.length) {
                            final item = displayedItems[index];
                            return FamilyFeedCard(
                              item: item,
                              margin: EdgeInsets.zero,
                              onReactionTap: (emoji) => widget.onReactionTap?.call(item.id, emoji),
                            );
                          } else {
                            // Paginación al final del feed continuo
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: widget.isLoadingMore
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: HabitikColors.green500,
                                        ),
                                      )
                                    : TextButton.icon(
                                        onPressed: widget.onLoadMore,
                                        icon: const Icon(Icons.history_rounded, size: 16),
                                        label: Text(
                                          'Cargar actividades anteriores',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ] else ...[
                    // ── Modo Clásico (no scrollable / shrinkWrap) ──
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 16),
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

                    if (hasMoreThanTwo) ...[
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('📢', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Feed de Actividad',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : HabitikColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        // Badge 'EN VIVO'
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF122C1D) : const Color(0xFFDCFCE7),
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
                width: 6.5,
                height: 6.5,
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
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
