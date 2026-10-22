import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'game/rewards_controller.dart';
import 'widgets/rewards_hud_overlay.dart';
import 'widgets/create_reward_dialog.dart';

class RewardsScreen extends StatefulWidget {
  final bool isActive;
  const RewardsScreen({super.key, this.isActive = true});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late final RewardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RewardsController();
    _controller.onCanjeResuelto = (titulo, mensaje, esExito) {
      if (!mounted) return;
      _mostrarDialogoCanjeResuelto(titulo, mensaje, esExito);
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.loadRewards();
    });
  }

  @override
  void didUpdateWidget(covariant RewardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Se activó la pestaña de Canjes: actualizar en segundo plano automáticamente
      _controller.loadRewards(showLoading: false);
    }
  }

  void _mostrarDialogoCanjeResuelto(String titulo, String mensaje, bool esExito) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: esExito
                  ? [const Color(0xFF1C3D28), const Color(0xFF172F1F)]
                  : [const Color(0xFF3A1C1C), const Color(0xFF2A1010)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                esExito ? '🎉' : '❌',
                style: const TextStyle(fontSize: 52),
              ),
              const SizedBox(height: 16),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: esExito
                        ? HabitikColors.green500
                        : Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    esExito ? '¡Entendido!' : 'Cerrar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentUser = _controller.currentUser;
        final isJefe = currentUser.isJefe;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ScreenShell(
          titulo: 'Canjes',
          subtitulo: 'RECOMPENSAS',
          useDefaultBackground: true,
          headerActions: [
            // ── Botón Crear / Proponer (verde sólido) ───────────────
            GestureDetector(
              onTap: () {
                if (isJefe) {
                  showCreateRewardDialog(
                    context,
                    mode: RewardDialogMode.admin,
                    onCreate: (reward) =>
                        _controller.createReward(reward, context),
                  );
                } else {
                  if (_controller.yaPropusoHoy) {
                    HabitikFeedback.showInfo(
                      context,
                      'Ya has enviado tu propuesta de hoy. El Jefe la revisará pronto.',
                    );
                    return;
                  }
                  showCreateRewardDialog(
                    context,
                    mode: RewardDialogMode.memberProposal,
                    onCreate: (propuesta) => _controller.proposeReward(
                      titulo: propuesta.titulo,
                      descripcion: propuesta.descripcion,
                      emoji: propuesta.emoji,
                      context: context,
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: HabitikColors.green700,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      isJefe ? 'Nueva meta' : 'Proponer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ── Tarjeta de Monedas Original ──────────────────────────
            _buildCoinsCard(context, currentUser.monedas, isDark),
          ],
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildCoinsCard(BuildContext context, int monedas, bool isDark) {
    return GestureDetector(
      onTap: () => _mostrarDetalleMonedas(context, monedas, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2F23).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? HabitikColors.amber400.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF382D12) : const Color(0xFFFFF8E1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('🪙', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 7),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monedas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    height: 1.1,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'disponibles',
                  style: TextStyle(
                    color: isDark
                        ? HabitikColors.green200
                        : Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                    height: 1.0,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleMonedas(BuildContext context, int monedas, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? HabitikColors.darkCardBg : const Color(0xFFEDF7F1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFBCE0C7),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFA5DCB6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF382D12) : const Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🪙', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 14),
              Text(
                '$monedas Monedas Disponibles',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : const Color(0xFF0F291E),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gana monedas completando tus retos y hábitos ecológicos diarios. Puedes usarlas para canjear cualquiera de los premios de la tienda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : const Color(0xFF2C4A36),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.state == RewardsState.loading) {
      return const LoadingOverlay(isLoading: true, message: 'Cargando tienda...');
    }
    if (_controller.state == RewardsState.error) {
      return HabitikErrorView(
        message: _controller.errorMessage ?? 'Error desconocido',
        onRetry: _controller.loadRewards,
      );
    }
    return RewardsHudOverlay(controller: _controller);
  }
}
