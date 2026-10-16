import 'package:flutter/material.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/modals/confirm_dialog.dart';

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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewards.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _RewardCard(
          reward: reward,
          currentUserId: currentUserId,
          onRedeem: onRedeem,
          onContributeColecta: onContributeColecta,
        );
      },
    );
  }
}

class _EmptyRewardsView extends StatelessWidget {
  const _EmptyRewardsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay recompensas aquí.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Los premios activos aparecerán en esta lista.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final colecta = reward.colectaActiva;

    return Opacity(
      opacity: isCooldown ? 0.65 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16251B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: HabitikShadows.card,
          border: isCooldown
              ? Border.all(color: HabitikColors.orange500.withValues(alpha: 0.8), width: 1.5)
              : Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3524) : HabitikColors.bgLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(reward.emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reward.titulo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : HabitikColors.textDark,
                                decoration: isCooldown ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: reward.esFamiliar
                                  ? HabitikColors.green500.withValues(alpha: 0.18)
                                  : HabitikColors.blue500.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reward.esFamiliar ? '👨‍👩‍👧 Familiar' : '👤 Personal',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: reward.esFamiliar ? HabitikColors.green400 : HabitikColors.blue500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (reward.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reward.descripcion,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : HabitikColors.textMid,
                            height: 1.3,
                          ),
                        ),
                      ],
                      if (isCooldown) ...[
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: HabitikColors.orange500),
                            SizedBox(width: 4),
                            Text(
                              'En enfriamiento (ya canjeado)',
                              style: TextStyle(
                                color: HabitikColors.orange500,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Sección colaborativa para premios familiares
            if (reward.esFamiliar) ...[
              const SizedBox(height: 14),
              _FamilyColectaProgressSection(
                reward: reward,
                colecta: colecta,
                currentUserId: currentUserId,
                isDark: isDark,
                onContribute: onContributeColecta != null 
                    ? () => onContributeColecta!(reward) 
                    : null,
              ),
            ] else ...[
              // Sección de canje individual para premios personales
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 canje diario por miembro',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : HabitikColors.textLight,
                    ),
                  ),
                  InkWell(
                    onTap: isCooldown
                        ? null
                        : () async {
                            final result = await HabitikConfirmDialog.show(
                              context,
                              title: 'Canjear Premio Personal',
                              description: '¿Deseas canjear ${reward.costo} monedas por "${reward.titulo}"?',
                              confirmLabel: '¡Canjear ahora!',
                              cancelLabel: 'Cancelar',
                            );
                            if (result == true) {
                              onRedeem(reward);
                            }
                          },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCooldown ? Colors.grey.withValues(alpha: 0.2) : HabitikColors.orange500,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isCooldown ? [] : [
                          BoxShadow(
                            color: HabitikColors.orange500.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${reward.costo}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🪙 Canjear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FamilyColectaProgressSection extends StatelessWidget {
  final RewardItem reward;
  final FamilyColecta? colecta;
  final String currentUserId;
  final bool isDark;
  final VoidCallback? onContribute;

  const _FamilyColectaProgressSection({
    required this.reward,
    required this.colecta,
    required this.currentUserId,
    required this.isDark,
    required this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    if (colecta == null) {
      // Colecta no iniciada aún
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HabitikColors.green500.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Colecta Colaborativa',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isDark ? Colors.white : HabitikColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: ${reward.costo} 🪙 divididos entre todos',
                    style: const TextStyle(
                      fontSize: 11,
                      color: HabitikColors.green600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: reward.isCooldownActive
                  ? null
                  : () async {
                      final confirmed = await HabitikConfirmDialog.show(
                        context,
                        title: 'Iniciar Colecta Familiar',
                        description: '¿Deseas iniciar la colecta para "${reward.titulo}"? Tu cuota calculada se descontará de tus monedas y tus familiares podrán aportar la suya.',
                        confirmLabel: 'Iniciar colecta',
                        cancelLabel: 'Cancelar',
                      );
                      if (confirmed == true && onContribute != null) {
                        onContribute!();
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: HabitikColors.green500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_add_rounded, size: 16),
                  SizedBox(width: 5),
                  Text('Iniciar Colecta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Colecta activa
    final miAporte = colecta!.miAporte(currentUserId);
    final yaPague = miAporte?.pagado == true;
    final completada = colecta!.estaCompletada;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2F22) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completada ? HabitikColors.amber400 : HabitikColors.green500.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                completada ? '🏆 ¡Colecta Completada!' : '🤝 Colecta en Progreso',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: completada ? const Color(0xFFFFA000) : HabitikColors.green600,
                ),
              ),
              Text(
                '${colecta!.totalRecaudado} / ${colecta!.totalRequerido} 🪙',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Color(0xFFFFA000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: colecta!.progreso,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                completada ? const Color(0xFFFFA000) : HabitikColors.green500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Avatares de integrantes que aportaron
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: colecta!.aportes.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Tooltip(
                          message: '${a.nombre}: ${a.pagado ? "Aportó ${a.montoPagado} 🪙" : "Pendiente ${a.montoAsignado} 🪙"}',
                          child: Stack(
                            children: [
                              UserAvatar(
                                letra: a.nombre.isNotEmpty ? a.nombre[0].toUpperCase() : 'U',
                                colorHex: a.pagado ? '#43A047' : '#9E9E9E',
                                radius: 14,
                              ),
                              if (a.pagado)
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Icon(Icons.check_circle, size: 12, color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (completada)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: HabitikColors.amber400.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '¡Canjeado!',
                    style: TextStyle(
                      color: Color(0xFFFFB300),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                )
              else if (yaPague)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: HabitikColors.green500.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '✓ Tu aporte listo (${miAporte?.montoPagado} 🪙)',
                    style: const TextStyle(
                      color: HabitikColors.green400,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    final cuota = miAporte?.montoAsignado ?? 0;
                    final confirmed = await HabitikConfirmDialog.show(
                      context,
                      title: 'Aportar a la Colecta',
                      description: '¿Deseas aportar tu cuota de $cuota 🪙 para "${reward.titulo}"?',
                      confirmLabel: 'Aportar $cuota 🪙',
                      cancelLabel: 'Cancelar',
                    );
                    if (confirmed == true && onContribute != null) {
                      onContribute!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: HabitikColors.orange500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  child: Text(
                    'Aportar (${miAporte?.montoAsignado ?? 0} 🪙)',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
