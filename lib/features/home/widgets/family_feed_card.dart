import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

/// Tarjeta individual del Feed Social Familiar (CA-4.1-3).
/// Informa la finalización de retos e integra botones de reacciones rápidas interactivas.
class FamilyFeedCard extends StatelessWidget {
  final FamilyFeedItem item;
  final void Function(String emoji)? onReactionTap;

  final EdgeInsetsGeometry? margin;

  const FamilyFeedCard({
    super.key,
    required this.item,
    this.onReactionTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Container(
          width: double.infinity,
          margin: margin ?? const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132217).withValues(alpha: 0.88) : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0x25FFFFFF)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Cabecera: Avatar, Nombre, Rol y Tiempo ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar con insignia destacada (CA-4.2C-3)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        letra: item.avatarLetra,
                        colorHex: item.avatarColor,
                        avatarUrl: item.avatarUrl,
                        radius: 18,
                      ),
                      if (item.badgeDestacado != null)
                        Positioned(
                          bottom: -2,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFB300), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              item.badgeDestacado!,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.nombreUsuario,
                                style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : HabitikColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1F3827)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.rolUsuario,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? HabitikColors.green200
                                      : HabitikColors.green800,
                                ),
                              ),
                            ),
                            if (item.badgeDestacado != null) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF282310) : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  item.badgeDestacado!,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          item.tiempoRelativo,
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white54 : HabitikColors.textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icono insignia del reto completado
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3224)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: GameChallengeIcon(
                      challengeId: item.tipoReto,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── 2. Mensaje y Contenido del Reto ──
              Text(
                item.tituloReto,
                style: GoogleFonts.outfit(
                  color: isDark ? const Color(0xFF34D399) : HabitikColors.green700,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.descripcion.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  item.descripcion,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white70 : HabitikColors.textDark,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],

              // ── 2.1 Imagen de Evidencia Fotográfica (si aplica) ──
              if (item.imagenUrl != null && item.imagenUrl!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    width: double.infinity,
                    color: isDark ? const Color(0xFF0F1B12) : const Color(0xFFF1F5F9),
                    child: Image.network(
                      item.imagenUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 140,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: HabitikColors.green500,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // ── 3. Recompensas Obtenidas ──
              Row(
                children: [
                  if (item.xpGanada > 0)
                    XpBadge(item.xpGanada),
                  if (item.xpGanada > 0 && item.monedasGanadas > 0)
                    const SizedBox(width: 8),
                  if (item.monedasGanadas > 0)
                    MonedasBadge(item.monedasGanadas),
                ],
              ),

              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark ? const Color(0x20FFFFFF) : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 10),

              // ── 4. Barra de Reacciones Rápidas (👏, 🔥, 💧, ❤️) ──
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: ['👏', '🔥', '💧', '❤️'].map((emoji) {
                  final backendKey = FamilyFeedItem.emojiToKey[emoji];
                  final count = item.reacciones[emoji] ?? (backendKey != null ? item.reacciones[backendKey] ?? 0 : 0);
                  final yaReacciono = item.misReacciones.contains(emoji) ||
                      (backendKey != null && item.misReacciones.contains(backendKey)) ||
                      (item.miReaccion != null && (item.miReaccion == backendKey || item.miReaccion == emoji));

                  return _buildReactionPill(
                    emoji: emoji,
                    count: count,
                    isSelected: yaReacciono,
                    isDark: isDark,
                    onTap: () => onReactionTap?.call(emoji),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionPill({
    required String emoji,
    required int count,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF285437) : const Color(0xFFDCFCE7))
              : (isDark ? const Color(0xFF18281D) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? HabitikColors.green400 : const Color(0xFF86EFAC))
                : (isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: HabitikColors.green500.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: GoogleFonts.outfit(
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF166534))
                    : (isDark ? Colors.white60 : HabitikColors.textLight),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
