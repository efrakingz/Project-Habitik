import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/features/rewards/game/rewards_controller.dart';
import 'rewards_list.dart';

class RewardsHudOverlay extends StatelessWidget {
  final RewardsController controller;

  const RewardsHudOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final propuesta = controller.propuestaHoy;
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return RefreshIndicator(
      onRefresh: controller.loadRewards,
      color: HabitikColors.green500,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Intro card con tinte orgánico suave ──────────────────
            _IntroCard(isDark: isDark),

            if (propuesta != null) ...[
              const SizedBox(height: 16),
              _DailyProposalBanner(propuesta: propuesta, isDark: isDark),
            ],

            const SizedBox(height: 24),

            // ── Cuadro Agrupado: Metas familiares colaborativas (Verde) ──
            _SectionGroupCard(
              title: 'Metas familiares colaborativas',
              subtitle: 'Financiadas colectivamente mediante hábitos del hogar',
              count: controller.premiosFamiliares.length,
              icon: Icons.diversity_3_rounded,
              accentColor: HabitikColors.green600,
              isDark: isDark,
              child: RewardsList(
                rewards: controller.premiosFamiliares,
                onRedeem: (r) => controller.redeemReward(r, context),
                onContributeColecta: (r) =>
                    controller.contributeColecta(r, context),
              ),
            ),

            // ── Separación amplia y visible entre secciones (verde visible) ──
            const SizedBox(height: 36),

            // ── Cuadro Agrupado: Premios personales (Azul) ────────────
            _SectionGroupCard(
              title: 'Premios personales',
              subtitle: 'Canjeables individualmente con tus monedas',
              count: controller.premiosPersonales.length,
              icon: Icons.person_rounded,
              accentColor: HabitikColors.blue500,
              isDark: isDark,
              child: RewardsList(
                rewards: controller.premiosPersonales,
                onRedeem: (r) => controller.redeemReward(r, context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Intro card — tinte suave, borde orgánico y tipografía Outfit
// ─────────────────────────────────────────────────────────────────────────────
class _IntroCard extends StatelessWidget {
  final bool isDark;
  const _IntroCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E21) : const Color(0xFFE4F4EA),
        borderRadius: BorderRadius.circular(18),
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF9EDAB1),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? HabitikColors.green900.withValues(alpha: 0.5)
                  : const Color(0xFFCEECD7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? HabitikColors.green700.withValues(alpha: 0.5)
                    : const Color(0xFF8CD4A2),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.storefront_rounded,
              color: isDark ? HabitikColors.green300 : const Color(0xFF16522B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Canjea tus monedas acumuladas en hábitos sostenibles por experiencias compartidas o incentivos personales.',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? Colors.white : const Color(0xFF0F351E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Group Card — Cuadro contenedor que agrupa cada sección
// ─────────────────────────────────────────────────────────────────────────────
class _SectionGroupCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final bool isDark;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _SectionGroupCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.isDark,
    required this.child,
    this.icon = Icons.stars_rounded,
    this.accentColor = HabitikColors.green600,
  });

  @override
  Widget build(BuildContext context) {
    final isBlue = accentColor == HabitikColors.blue500;

    // Fondo del cuadro contenedor que agrupa toda la sección
    final groupBg = isDark
        ? (isBlue ? const Color(0xFF132230) : const Color(0xFF15261B))
        : (isBlue ? const Color(0xFFE3EFFB) : const Color(0xFFE1F2E7));

    final groupBorder = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : (isBlue ? const Color(0xFF9CC8F4) : const Color(0xFF93D6AC));

    final iconBg = isDark
        ? (isBlue ? const Color(0xFF1B334B) : const Color(0xFF1C3A24))
        : (isBlue ? const Color(0xFFCFE5FA) : const Color(0xFFC7EBD3));

    final iconBorder = isDark
        ? accentColor.withValues(alpha: 0.4)
        : (isBlue ? const Color(0xFF67AEEA) : const Color(0xFF6DC48B));

    final titleColor = isDark
        ? Colors.white
        : (isBlue ? const Color(0xFF092B4F) : const Color(0xFF0B381D));

    final subtitleColor = isDark
        ? (isBlue ? const Color(0xFF90CAF9) : HabitikColors.green200)
        : (isBlue ? const Color(0xFF1C5385) : const Color(0xFF1B5932));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: groupBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: groupBorder,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Encabezado de la sección ──
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: iconBorder,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count activas',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // ── Separador sutil de cabecera ──
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : (isBlue ? const Color(0xFFC0DAF5) : const Color(0xFFB5E2C4)),
          ),
          const SizedBox(height: 14),
          // ── Contenido de la sección (las tarjetas de recompensa) ──
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily proposal banner
// ─────────────────────────────────────────────────────────────────────────────
class _DailyProposalBanner extends StatelessWidget {
  final RewardItem propuesta;
  final bool isDark;
  const _DailyProposalBanner({required this.propuesta, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final esPendiente = propuesta.estado == 'propuesto';
    final esAprobado = propuesta.estado == 'activo';

    Color bg;
    Color border;
    Color textColor;
    String estadoTexto;
    IconData icon;

    if (esPendiente) {
      bg = isDark ? const Color(0xFF2C220E) : const Color(0xFFFFF8E1);
      border = HabitikColors.amber400;
      textColor = const Color(0xFFFFB300);
      estadoTexto = 'Propuesta de hoy en revisión por el Jefe';
      icon = Icons.hourglass_top_rounded;
    } else if (esAprobado) {
      bg = isDark ? const Color(0xFF1B2E1F) : const Color(0xFFE8F5E9);
      border = HabitikColors.green500;
      textColor = HabitikColors.green600;
      estadoTexto = '¡Propuesta aprobada! ${propuesta.costo} 🪙';
      icon = Icons.check_circle_rounded;
    } else {
      bg = isDark ? const Color(0xFF331A1A) : const Color(0xFFFFEBEE);
      border = Colors.redAccent;
      textColor = Colors.redAccent;
      estadoTexto = 'Propuesta de hoy no aprobada';
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estadoTexto,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  propuesta.titulo,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : HabitikColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
