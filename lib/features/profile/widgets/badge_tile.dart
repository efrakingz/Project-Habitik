import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/core/services/badge_service.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'badge_svg_icons.dart';

const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0,      0,      0,      1, 0,
]);

/// Tarjeta minimalista de medalla y logro (HU 4.2C.2) adaptada al diseño oficial de Vitrina de Trofeos.
/// - Tarjeta horizontal con contenedor cuadrado redondeado con arte vectorial temático SVG.
/// - Desbloqueada: a todo color, con detalles de categoría / escalón y estado. Tocarla abre modal con fecha y acción de reclamar.
/// - Bloqueada: diseño oscuro forestal con candado esmeralda estilizado, requisitos e indicador de progreso del backend.
class BadgeTile extends StatelessWidget {
  final AchievementItem badge;
  final bool isDark;
  final VoidCallback? onBadgeUpdated;

  const BadgeTile({
    super.key,
    required this.badge,
    required this.isDark,
    this.onBadgeUpdated,
  });

  ({Color bg, Color border, Color text, String icon}) _getCategoryStyle(String categoria, bool isDark) {
    final cat = categoria.toUpperCase();
    if (cat.contains('AGUA') || cat.contains('DUCHA')) {
      return (
        bg: isDark ? const Color(0xFF092938) : const Color(0xFFE0F2FE),
        border: isDark ? const Color(0xFF0284C7) : const Color(0xFF38BDF8),
        text: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
        icon: '💧',
      );
    }
    if (cat.contains('RECICL') || cat.contains('PUZZLE')) {
      return (
        bg: isDark ? const Color(0xFF0A2E1D) : const Color(0xFFDCFCE7),
        border: isDark ? const Color(0xFF059669) : const Color(0xFF34D399),
        text: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
        icon: '🔄',
      );
    }
    if (cat.contains('RACHA') || cat.contains('CONSTANCIA')) {
      return (
        bg: isDark ? const Color(0xFF2E1B0A) : const Color(0xFFFEF3C7),
        border: isDark ? const Color(0xFFD97706) : const Color(0xFFFBBF24),
        text: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
        icon: '🔥',
      );
    }
    if (cat.contains('TRIVIA') || cat.contains('MENTE') || cat.contains('CEREBRO')) {
      return (
        bg: isDark ? const Color(0xFF1E1430) : const Color(0xFFF3E8FF),
        border: isDark ? const Color(0xFF7C3AED) : const Color(0xFFA855F7),
        text: isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9),
        icon: '🧠',
      );
    }
    if (cat.contains('BOLETA') || cat.contains('ENERGIA') || cat.contains('GUARDIAN')) {
      return (
        bg: isDark ? const Color(0xFF0C2626) : const Color(0xFFCCFBF1),
        border: isDark ? const Color(0xFF0D9488) : const Color(0xFF2DD4BF),
        text: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
        icon: '🧾',
      );
    }
    if (cat.contains('FAMILIAR') || cat.contains('EQUIPO') || cat.contains('HOGAR')) {
      return (
        bg: isDark ? const Color(0xFF0C2530) : const Color(0xFFE0F2FE),
        border: isDark ? const Color(0xFF0284C7) : const Color(0xFF38BDF8),
        text: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
        icon: '👨‍👩‍👧‍👦',
      );
    }
    return (
      bg: isDark ? const Color(0xFF0A2E1D) : const Color(0xFFDCFCE7),
      border: isDark ? const Color(0xFF059669) : const Color(0xFF34D399),
      text: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
      icon: '🌱',
    );
  }

  Widget _buildProgressChip(AchievementItem badge, bool isDark) {
    final isRacha = badge.key.toUpperCase().contains('RACHA') || badge.categoria.toUpperCase().contains('RACHA');
    final Color bg = isRacha
        ? (isDark ? const Color(0xFF2B1A08) : const Color(0xFFFEF3C7))
        : (isDark ? const Color(0xFF0A271E) : const Color(0xFFE8F5E9));
    final Color border = isRacha
        ? (isDark ? const Color(0xFF9A3412) : const Color(0xFFF59E0B).withValues(alpha: 0.5))
        : (isDark ? const Color(0xFF134E3C) : const Color(0xFFA5DCB6));
    final Color textColor = isRacha
        ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
        : (isDark ? const Color(0xFF34D399) : const Color(0xFF166534));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        badge.progresoDisplay,
        style: GoogleFonts.outfit(
          color: textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = badge.desbloqueado;
    final bool isClaimed = badge.reclamado;
    final bool isDestacado = badge.destacado;
    final catStyle = _getCategoryStyle(badge.categoria, isDark);

    final cardBg = isDark
        ? const Color(0xFF10281D)
        : (isUnlocked ? const Color(0xFFF7FBF8) : const Color(0xFFF8FAFC));

    final cardBorder = isDark
        ? (isDestacado ? const Color(0xFFF59E0B) : const Color(0xFF1A3D2D))
        : (isDestacado
            ? const Color(0xFFF59E0B)
            : (isUnlocked ? const Color(0xFFBCE0C8) : const Color(0xFFE2E8F0)));

    final iconBg = isDark
        ? const Color(0xFF0B2218)
        : (isUnlocked ? const Color(0xFFD8EFE1) : const Color(0xFFF1F5F9));

    final iconBorder = isDark
        ? const Color(0xFF174330)
        : (isUnlocked ? const Color(0xFFA5DCB6) : const Color(0xFFCBD5E1));

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: cardBorder,
          width: isDestacado ? 1.5 : 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Contenedor de Ícono SVG temático (52x52) ──
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: iconBorder, width: 1.2),
            ),
            alignment: Alignment.center,
            child: isUnlocked
                ? BadgeSvgIcons.buildSvg(badge.key, isLocked: false, size: 34)
                : BadgeSvgIcons.buildSvg(badge.key, isLocked: true, size: 28),
          ),

          const SizedBox(width: 12),

          // ── 2. Información del Logro y Progresión ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: Chip de Categoría & Nivel + Estado
                Row(
                  children: [
                    // Chip de Categoría & Nivel con icono temático
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: catStyle.bg,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: catStyle.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(catStyle.icon, style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            '${badge.categoria} · ${badge.nivelTier}',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: catStyle.text,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Chip / Estado a la derecha
                    if (isUnlocked && isClaimed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            'Desbloqueada',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      )
                    else if (isUnlocked && !isClaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1B0A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD97706),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 3),
                            Text(
                              'Reclamar',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 13,
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Bloqueada',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                // Título
                Text(
                  badge.nombre,
                  style: GoogleFonts.outfit(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF0F291E),
                  ),
                ),

                const SizedBox(height: 2),

                // Descripción
                Text(
                  badge.descripcion.isNotEmpty
                      ? badge.descripcion
                      : (isUnlocked ? 'Logro completado con éxito' : 'Toca para ver los requisitos pendientes'),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Fila de recompensa y progreso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Monedas y XP
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF271C0A) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFB45309),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                '+${badge.monedas}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (badge.xp > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF132A1C) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${badge.xp} XP',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? HabitikColors.green300 : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],

                        if (isDestacado) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFD97706)),
                                const SizedBox(width: 2),
                                Text(
                                  'Destacada',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Badge de Progreso del backend (ej. 0/1 completado, Racha 0/3 dias)
                    _buildProgressChip(badge, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // CA-4.2C.2-2: En modo claro legacy aplica opacidad 40% y escala de grises
    if (!isUnlocked && !isDark) {
      cardContent = Opacity(
        opacity: 0.4,
        child: ColorFiltered(
          colorFilter: _grayscaleFilter,
          child: cardContent,
        ),
      );
    }

    return InkWell(
      onTap: () => _showBadgeDetailModal(context),
      borderRadius: BorderRadius.circular(16),
      child: cardContent,
    );
  }

  void _showBadgeDetailModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _BadgeDetailSheet(
        badge: badge,
        isDark: isDark,
        onBadgeUpdated: onBadgeUpdated,
      ),
    );
  }
}

/// Modal minimalista que muestra los detalles de una medalla (desbloqueada o bloqueada)
/// Inspirado en la sobriedad y limpieza de create_reward_dialog.dart de Canjes.
class _BadgeDetailSheet extends StatefulWidget {
  final AchievementItem badge;
  final bool isDark;
  final VoidCallback? onBadgeUpdated;

  const _BadgeDetailSheet({
    required this.badge,
    required this.isDark,
    this.onBadgeUpdated,
  });

  @override
  State<_BadgeDetailSheet> createState() => _BadgeDetailSheetState();
}

class _BadgeDetailSheetState extends State<_BadgeDetailSheet> {
  late AchievementItem _badge;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _badge = widget.badge;
  }

  Future<void> _handleClaim() async {
    if (_isClaiming || _badge.reclamado || _badge.id == null) return;

    setState(() => _isClaiming = true);
    final result = await BadgeService().reclamarRecompensa(_badge.id!);
    if (!mounted) return;

    setState(() {
      _isClaiming = false;
      if (result.exito) {
        _badge = _badge.copyWith(reclamado: true);
      }
    });

    if (result.exito) {
      HabitikFeedback.showSuccess(
        context,
        '¡Reclamaste ${result.monedasGanadas} monedas con éxito! 🪙',
      );
      widget.onBadgeUpdated?.call();
    } else {
      HabitikFeedback.showError(context, result.mensaje);
    }
  }

  Future<void> _handleToggleDestacado() async {
    await BadgeService().alternarBadgeDestacado(_badge);
    if (!mounted) return;
    setState(() {
      _badge = _badge.copyWith(destacado: !_badge.destacado);
    });
    HabitikFeedback.showInfo(
      context,
      _badge.destacado
          ? '¡Insignia destacada en tu perfil y Feed Familiar! ⭐'
          : 'Insignia removida de tu avatar.',
    );
    widget.onBadgeUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = _badge.desbloqueado;
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B261D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked
              ? (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFBCE0C8))
              : (isDark ? const Color(0x20FFFFFF) : const Color(0xFFCBD5E1)),
          width: 1.2,
        ),
        boxShadow: HabitikShadows.floating,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tirador superior discreto
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Contenedor de ícono cuadrado redondeado minimalista (56x56)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (isDark ? HabitikColors.green900.withValues(alpha: 0.5) : const Color(0xFFD8EFE1))
                    : (isDark ? const Color(0xFF222824) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? (isDark ? HabitikColors.green700 : const Color(0xFFA5DCB6))
                      : (isDark ? const Color(0x30FFFFFF) : const Color(0xFFCBD5E1)),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: BadgeSvgIcons.buildSvg(
                  _badge.key,
                  isLocked: !isUnlocked,
                  size: isUnlocked ? 38 : 30,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chip de Categoría y Nivel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF142E1F) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? HabitikColors.green700 : const Color(0xFFA5DCB6),
                  width: 1,
                ),
              ),
              child: Text(
                '${_badge.categoria} · ${_badge.nivelTier}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? HabitikColors.green300 : const Color(0xFF166534),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Título
            Text(
              _badge.nombre,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF0F291E),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            // CA-4.2C.2-2:
            // Desbloqueada: "¡Desbloqueaste este logro el [Fecha]!"
            // Bloqueada: "Requisitos pendientes"
            if (isUnlocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF142E1F) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? HabitikColors.green700 : const Color(0xFFA5DCB6),
                    width: 1,
                  ),
                ),
                child: Text(
                  '🎉 ¡Desbloqueaste este logro el ${_badge.fechaFormateada}!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: isDark ? HabitikColors.green300 : const Color(0xFF166534),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF261D10) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 5),
                    Text(
                      'Requisitos Pendientes',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFB45309),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Descripción o Requisito
            Text(
              isUnlocked ? _badge.descripcion : _badge.requisitoPendiente,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Badges de recompensa
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_badge.xp > 0) ...[
                  XpBadge(_badge.xp),
                  const SizedBox(width: 8),
                ],
                MonedasBadge(_badge.monedas),
                const SizedBox(width: 8),
                DificultadBadge(_badge.dificultad),
              ],
            ),

            const SizedBox(height: 20),

            // ── Botones de Acción (Reclamar / Destacar) ──
            if (isUnlocked) ...[
              // Botón 1: Reclamar monedas (Indicación de Flujo 2 del backend)
              if (!_badge.reclamado)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _isClaiming ? null : _handleClaim,
                    icon: _isClaiming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('🎁', style: TextStyle(fontSize: 16)),
                    label: Text(
                      _isClaiming ? 'Reclamando...' : 'Reclamar ${_badge.monedas} Monedas',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF122C1B) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Reclamado',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF166534),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Botón 2: Destacar insignia junto al avatar en el Feed Familiar (CA-4.2C-3)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _handleToggleDestacado,
                  icon: Icon(
                    _badge.destacado ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 19,
                  ),
                  label: Text(
                    _badge.destacado ? 'Insignia Destacada en Avatar' : 'Destacar en Feed y Perfil',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : const Color(0xFF0F291E),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _badge.destacado ? const Color(0xFFF59E0B) : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    'Entendido, ¡voy a lograrlo!',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF264630) : HabitikColors.green600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
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
