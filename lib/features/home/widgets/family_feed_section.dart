import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'family_feed_card.dart';

/// Sección de Feed Familiar en Tiempo Real (CA-4.1-3).
/// - Título "Feed Familiar" en formato Card independiente.
/// - Contenedor general transparente dejando ver el fondo de la pantalla.
/// - Cards de actividades individuales manteniendo su diseño original.
/// - Carga bajo demanda paginada (máximo 4 cards por lote).
class FamilyFeedSection extends StatelessWidget {
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

  Widget _buildTitleCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x25FFFFFF) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : HabitikColors.green700.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('📢', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'Feed Familiar',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : HabitikColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isScrollable ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // ── 1. Card del Título "Feed Familiar" ──
            _buildTitleCard(isDark),

            const SizedBox(height: 12),

            // ── 2. Contenido del Feed (Fondo Transparente, Cards Independientes) ──
            if (loading && items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: HabitikColors.green500,
                  ),
                ),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B2E22) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0x25FFFFFF) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
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
            else if (isScrollable) ...[
              // ── Modo Scroll Continuo Independiente (Paginado a demanda) ──
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 95),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: items.length + (hasMore ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index < items.length) {
                      final item = items[index];
                      return FamilyFeedCard(
                        item: item,
                        margin: EdgeInsets.zero,
                        onReactionTap: (emoji) => onReactionTap?.call(item.id, emoji),
                      );
                    } else {
                      // Paginación a demanda al final de los cards
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: isLoadingMore
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: HabitikColors.green500,
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: onLoadMore,
                                  style: TextButton.styleFrom(
                                    backgroundColor: isDark ? const Color(0xFF1B2E22) : Colors.white,
                                    foregroundColor: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isDark ? const Color(0x25FFFFFF) : const Color(0xFFE2E8F0),
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.history_rounded, size: 16),
                                  label: Text(
                                    'Cargar más actividades',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
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
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return FamilyFeedCard(
                    item: item,
                    margin: EdgeInsets.zero,
                    onReactionTap: (emoji) => onReactionTap?.call(item.id, emoji),
                  );
                },
              ),
              if (hasMore) ...[
                const SizedBox(height: 8),
                Center(
                  child: isLoadingMore
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: HabitikColors.green500,
                          ),
                        )
                      : TextButton.icon(
                          onPressed: onLoadMore,
                          style: TextButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF1B2E22) : Colors.white,
                            foregroundColor: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark ? const Color(0x25FFFFFF) : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.history_rounded, size: 16),
                          label: Text(
                            'Cargar más actividades',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}
