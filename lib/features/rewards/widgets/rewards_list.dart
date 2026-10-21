import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/modals/confirm_dialog.dart';
import 'reward_icon_helper.dart';

class RewardsList extends StatelessWidget {
  final List<RewardItem> rewards;
  final Function(RewardItem) onRedeem;
  final Function(RewardItem)? onContributeColecta;

  const RewardsList({
    super.key,
    required this.rewards,
    required this.onRedeem,
    this.onContributeColecta,
  });

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return const _EmptyRewardsView();
    }

    final currentUserId = SessionService().currentUser?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < rewards.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _RewardCard(
            reward: rewards[i],
            currentUserId: currentUserId,
            onRedeem: onRedeem,
            onContributeColecta: onContributeColecta,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyRewardsView extends StatelessWidget {
  const _EmptyRewardsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;
    return Container(
      height: 95,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFEDF7F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFBFE0C8),
        ),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: isDark ? HabitikColors.green300 : HabitikColors.green600,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            'Aún no hay recompensas aquí.',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white70 : const Color(0xFF2E4A35),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reward card — tinte cromático pastel, borde orgánico y tipografía Outfit
// ─────────────────────────────────────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final RewardItem reward;
  final String currentUserId;
  final Function(RewardItem) onRedeem;
  final Function(RewardItem)? onContributeColecta;

  const _RewardCard({
    required this.reward,
    required this.currentUserId,
    required this.onRedeem,
    this.onContributeColecta,
  });

  @override
  Widget build(BuildContext context) {
    final isCooldown = reward.isCooldownActive;
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;
    final colecta = reward.colectaActiva;
    final esFamiliar = reward.esFamiliar;

    // Tintes claros y limpios para las tarjetas interiores del grupo
    final cardBg = isDark
        ? HabitikColors.darkCardBg
        : (esFamiliar ? const Color(0xFFF7FBF8) : const Color(0xFFF6FAFE));

    final cardBorder = isCooldown
        ? HabitikColors.orange500.withValues(alpha: 0.55)
        : isDark
            ? Colors.white.withValues(alpha: 0.08)
            : (esFamiliar ? const Color(0xFFBCE0C8) : const Color(0xFFB8D9F6));

    final iconBg = isDark
        ? HabitikColors.green900.withValues(alpha: 0.5)
        : (esFamiliar ? const Color(0xFFD8EFE1) : const Color(0xFFDBEDFC));

    final iconBorder = isDark
        ? HabitikColors.green700.withValues(alpha: 0.5)
        : (esFamiliar ? const Color(0xFFA5DCB6) : const Color(0xFFA5CEF7));

    final iconColor = isDark
        ? HabitikColors.green300
        : (esFamiliar ? const Color(0xFF16522B) : const Color(0xFF15538C));

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : (esFamiliar ? const Color(0xFFDCEFE2) : const Color(0xFFDBEAF7));

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: cardBorder,
          width: isCooldown ? 1.4 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cabecera: icono + título + badge tipo ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono cuadrado redondeado con tinte temático
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconBorder,
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    getRewardCategoryIcon(reward.emoji, reward.titulo),
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                // Título + descripción con GoogleFonts.outfit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              reward.titulo,
                              style: GoogleFonts.outfit(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F291E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge Familiar / Personal
                          _TypeBadge(
                            esFamiliar: reward.esFamiliar,
                            isDark: isDark,
                          ),
                        ],
                      ),
                      if (reward.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          reward.descripcion,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF37474F),
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Estado en enfriamiento ────────────────────────────────
          if (isCooldown) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: HabitikColors.orange500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: HabitikColors.orange500.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: HabitikColors.orange500,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'En enfriamiento (canjeado recientemente)',
                      style: GoogleFonts.outfit(
                        color: HabitikColors.orange500,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Divider sutil ─────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: dividerColor,
          ),

          // ── Sección inferior: colecta o canje personal ────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: reward.esFamiliar
                ? _FamilyColectaProgressSection(
                    reward: reward,
                    colecta: colecta,
                    currentUserId: currentUserId,
                    isDark: isDark,
                    cardBg: cardBg,
                    onContribute: onContributeColecta != null
                        ? () => onContributeColecta!(reward)
                        : null,
                  )
                : _PersonalRedeemRow(
                    reward: reward,
                    isCooldown: isCooldown,
                    isDark: isDark,
                    onRedeem: onRedeem,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge Familiar / Personal
// ─────────────────────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final bool esFamiliar;
  final bool isDark;

  const _TypeBadge({required this.esFamiliar, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = esFamiliar ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1);
    final bgColor = esFamiliar
        ? (isDark ? const Color(0xFF14301A) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF0D253F) : const Color(0xFFE3F2FD));
    final borderColor = esFamiliar
        ? (isDark ? const Color(0xFF2E7D32) : const Color(0xFFA5D6A7))
        : (isDark ? const Color(0xFF1E88E5) : const Color(0xFF90CAF9));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        esFamiliar ? 'Familiar' : 'Personal',
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isDark
              ? (esFamiliar ? HabitikColors.green300 : Colors.lightBlueAccent)
              : color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de canje personal
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalRedeemRow extends StatelessWidget {
  final RewardItem reward;
  final bool isCooldown;
  final bool isDark;
  final Function(RewardItem) onRedeem;

  const _PersonalRedeemRow({
    required this.reward,
    required this.isCooldown,
    required this.isDark,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable =
        reward.disponible && !isCooldown && reward.estado == 'activo';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '1 canje diario por miembro',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : const Color(0xFF37474F),
          ),
        ),
        if (!isAvailable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_clock_rounded,
                  size: 13,
                  color: isDark ? Colors.white38 : HabitikColors.textMid,
                ),
                const SizedBox(width: 5),
                Text(
                  'No disponible',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white54 : HabitikColors.textMid,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () async {
              final result = await HabitikConfirmDialog.show(
                context,
                title: 'Canjear Premio Personal',
                description:
                    '¿Deseas canjear ${reward.costo} 🪙 por "${reward.titulo}"?',
                confirmLabel: '¡Canjear ahora!',
                cancelLabel: 'Cancelar',
              );
              if (result == true) onRedeem(reward);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: HabitikColors.green600,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: HabitikColors.green600.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${reward.costo} 🪙',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sección de colecta familiar — barra de progreso al estilo de la imagen
// ─────────────────────────────────────────────────────────────────────────────
class _FamilyColectaProgressSection extends StatelessWidget {
  final RewardItem reward;
  final FamilyColecta? colecta;
  final String currentUserId;
  final bool isDark;
  final Color cardBg;
  final VoidCallback? onContribute;

  const _FamilyColectaProgressSection({
    required this.reward,
    required this.colecta,
    required this.currentUserId,
    required this.isDark,
    required this.cardBg,
    required this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    // ── Sin colecta iniciada ──────────────────────────────────────
    if (colecta == null) {
      final isAvailable =
          reward.disponible && !reward.isCooldownActive && reward.estado == 'activo';

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colecta colaborativa',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0F291E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${reward.costo} 🪙 divididas entre todos',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark
                        ? HabitikColors.green300
                        : const Color(0xFF1B5E20),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 13,
                    color: isDark ? Colors.white38 : HabitikColors.textMid,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'No disponible',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : HabitikColors.textMid,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () async {
                final confirmed = await HabitikConfirmDialog.show(
                  context,
                  title: 'Iniciar Colecta Familiar',
                  description:
                      '¿Deseas iniciar la colecta para "${reward.titulo}"? Tu cuota calculada se descontará de tus monedas y tus familiares podrán aportar la suya.',
                  confirmLabel: 'Iniciar colecta',
                  cancelLabel: 'Cancelar',
                );
                if (confirmed == true && onContribute != null) {
                  onContribute!();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: HabitikColors.green600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: HabitikColors.green600.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Iniciar',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // ── Colecta activa ────────────────────────────────────────────
    final miAporte = colecta!.miAporte(currentUserId);
    final yaPague = miAporte?.pagado == true;
    final completada = colecta!.estaCompletada;
    final progreso = colecta!.progreso;
    final porcentaje = (progreso * 100).toStringAsFixed(0);
    final recaudado = colecta!.totalRecaudado;
    final requerido = colecta!.totalRequerido;
    final faltan = requerido - recaudado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Etiqueta "Progreso de colecta" ────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              completada ? '🏆 Colecta completada' : '🤝 Progreso de colecta',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: completada
                    ? (isDark ? Colors.amber[300] : const Color(0xFFB45309))
                    : (isDark ? Colors.white : const Color(0xFF0F291E)),
              ),
            ),
            Text(
              '$recaudado / $requerido 🪙 ($porcentaje%)',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? HabitikColors.green300 : const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),

        // ── Barra de progreso ─────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 7,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.07),
            valueColor: AlwaysStoppedAnimation<Color>(
              completada ? HabitikColors.amber400 : HabitikColors.green500,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Avatares superpuestos + Faltan + Acción ───────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Grupo izquierdo: Avatares superpuestos y monedas restantes
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatarStack(colecta!.aportes, cardBg),
                  if (!completada && faltan > 0) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Faltan $faltan 🪙',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF37474F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ── Botón de acción o estado ──────────────────────────
            if (completada)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: HabitikColors.amber400.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: HabitikColors.amber400.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 13, color: HabitikColors.amber400),
                    const SizedBox(width: 4),
                    Text(
                      'Canjeado',
                      style: GoogleFonts.outfit(
                        color: HabitikColors.amber400,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              )
            else if (yaPague)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: HabitikColors.green500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: HabitikColors.green500.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 13, color: HabitikColors.green500),
                    const SizedBox(width: 4),
                    Text(
                      'Aportaste ${miAporte?.montoPagado ?? 0} 🪙',
                      style: GoogleFonts.outfit(
                        color: HabitikColors.green600,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () async {
                  final cuota = miAporte?.montoAsignado ?? 0;
                  final confirmed = await HabitikConfirmDialog.show(
                    context,
                    title: 'Aportar a la Colecta',
                    description:
                        '¿Deseas aportar tu cuota de $cuota 🪙 para "${reward.titulo}"?',
                    confirmLabel: 'Aportar $cuota 🪙',
                    cancelLabel: 'Cancelar',
                  );
                  if (confirmed == true && onContribute != null) {
                    onContribute!();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: HabitikColors.green600,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            HabitikColors.green600.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Aportar (${miAporte?.montoAsignado ?? 0} 🪙)',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 13, color: Colors.white),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Construye una pila de avatares superpuestos moderna que no desborda la pantalla
  Widget _buildAvatarStack(List<ColectaAporte> aportes, Color cardBg) {
    const maxVisible = 4;
    final visibleAportes = aportes.take(maxVisible).toList();
    final remaining = aportes.length - maxVisible;

    return SizedBox(
      height: 26,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < visibleAportes.length; i++)
            Align(
              widthFactor: i == 0 ? 1.0 : 0.65,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cardBg, width: 1.8),
                ),
                child: Tooltip(
                  message: visibleAportes[i].pagado
                      ? '${visibleAportes[i].nombre}: Aportó ${visibleAportes[i].montoPagado} 🪙'
                      : '${visibleAportes[i].nombre}: Pendiente ${visibleAportes[i].montoAsignado} 🪙',
                  child: Stack(
                    children: [
                      UserAvatar(
                        letra: visibleAportes[i].nombre.isNotEmpty
                            ? visibleAportes[i].nombre[0].toUpperCase()
                            : 'U',
                        colorHex:
                            visibleAportes[i].pagado ? '#43A047' : '#9E9E9E',
                        radius: 11,
                      ),
                      if (visibleAportes[i].pagado)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.check_circle,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (remaining > 0)
            Align(
              widthFactor: 0.65,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF78909C),
                  shape: BoxShape.circle,
                  border: Border.all(color: cardBg, width: 1.8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
