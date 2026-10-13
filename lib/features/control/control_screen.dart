import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/features/rewards/services/rewards_service.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

import 'widgets/notificacion_personalizada_sheet.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late final UserProfile _user;
  List<FamilyMember> _members = [];
  bool _loadingMembers = true;

  final RewardsService _rewardsService = RewardsService();
  List<PendingCanje> _pendingCanjes = [];
  bool _loadingCanjes = true;

  @override
  void initState() {
    super.initState();
    _user = SessionService().currentUser ?? UserProfile.empty;
    _loadMembers();
    _loadPendingCanjes();
  }

  Future<void> _loadMembers() async {
    try {
      final response = await ApiClient().get('/familia/miembros');
      if (!mounted) return;
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _members = data
            .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .where((m) => m.id != _user.id)
            .toList();
        _loadingMembers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMembers = false);
      debugPrint('⚠️ [ControlScreen] Error cargando miembros: $e');
    }
  }

  Future<void> _loadPendingCanjes() async {
    setState(() => _loadingCanjes = true);
    try {
      final canjes = await _rewardsService.getPendingCanjes();
      if (!mounted) return;
      setState(() {
        _pendingCanjes = canjes;
        _loadingCanjes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCanjes = false);
      debugPrint('⚠️ [ControlScreen] Error cargando canjes pendientes: $e');
    }
  }

  Future<void> _aprobarCanje(String canjeId) async {
    try {
      await _rewardsService.approveCanje(canjeId);
      if (!mounted) return;
      HabitikFeedback.showSuccess(context, 'Solicitud aprobada');
      _loadPendingCanjes();
    } catch (e) {
      if (!mounted) return;
      HabitikFeedback.showError(context, 'Error al aprobar: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _rechazarCanje(String canjeId) async {
    try {
      await _rewardsService.rejectCanje(canjeId);
      if (!mounted) return;
      HabitikFeedback.showSuccess(context, 'Solicitud rechazada (monedas reembolsadas)');
      _loadPendingCanjes();
    } catch (e) {
      if (!mounted) return;
      HabitikFeedback.showError(context, 'Error al rechazar: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _abrirEnviarNotificacion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificacionPersonalizadaSheet(
        members: _members,
        familyId: _user.familyId ?? '',
        senderName: _user.nombre,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titulo: 'Panel de Control',
      subtitulo: '👑 Jefe de Familia',
      headerActions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: HabitikColors.amber400,
            borderRadius: HabitikRadius.xxl_,
          ),
          child: const Text(
            'ADMIN',
            style: TextStyle(
              color: Color(0xFF5D4037),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroBannerCard(
              emoji: '👑',
              title: 'Administrar Familia',
              description:
                  'Gestiona las metas de ahorro mensual de luz y agua, y aprueba evidencias de retos familiares.',
              actionLabel: '👑 Configurar Metas',
              onAction: () {},
            ),
            const SizedBox(height: 24),

            // Sección Moderación Canjes
            _SectionHeader(title: '🎁 Solicitudes de Canje', subtitle: 'Aprueba o rechaza los canjes de tu familia'),
            const SizedBox(height: 12),
            if (_loadingCanjes)
              const Center(child: CircularProgressIndicator())
            else if (_pendingCanjes.isEmpty)
              _EmptyCanjesCard()
            else
              ..._pendingCanjes.map((canje) => _PendingCanjeCard(
                    canje: canje,
                    onApprove: () => _aprobarCanje(canje.id),
                    onReject: () => _rechazarCanje(canje.id),
                  )),
            
            const SizedBox(height: 24),

            // Sección Notificaciones
            _SectionHeader(title: '🔔 Notificaciones', subtitle: 'Envía mensajes a tu familia'),
            const SizedBox(height: 12),
            _NotificacionCard(
              onEnviar: _abrirEnviarNotificacion,
              membersLoaded: !_loadingMembers,
              memberCount: _members.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCanjesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251B) : Colors.white,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'No hay solicitudes pendientes 🙌',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PendingCanjeCard extends StatelessWidget {
  const _PendingCanjeCard({
    required this.canje,
    required this.onApprove,
    required this.onReject,
  });

  final PendingCanje canje;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A222C) : Colors.white,
        borderRadius: HabitikRadius.lg_,
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: HabitikColors.blue500.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C3E50) : HabitikColors.bgLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(canje.rewardEmoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: HabitikColors.blue500.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            canje.usuarioNombre.isNotEmpty
                                ? canje.usuarioNombre[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: HabitikColors.blue500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Canjeado por: ${canje.usuarioNombre}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: HabitikColors.blue500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canje.rewardTitulo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : HabitikColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${canje.costoPagado} 🪙 · ${_formatDate(canje.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HabitikColors.amber400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                  ),
                  child: const Text('Rechazar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                  ),
                  child: const Text('Aprobar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets privados
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : HabitikColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: HabitikColors.textMid),
        ),
      ],
    );
  }
}

class _NotificacionCard extends StatelessWidget {
  const _NotificacionCard({
    required this.onEnviar,
    required this.membersLoaded,
    required this.memberCount,
  });
  final VoidCallback onEnviar;
  final bool membersLoaded;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2A3A), const Color(0xFF0D1B2A)]
              : [const Color(0xFFE8F5FF), const Color(0xFFF0F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(
          color: isDark
              ? const Color(0x30FFFFFF)
              : HabitikColors.blue500.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: HabitikColors.blue500.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: HabitikRadius.lg_,
          onTap: onEnviar,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        HabitikColors.blue500,
                        HabitikColors.blue500.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: HabitikRadius.md_,
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificación Personalizada',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : HabitikColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        membersLoaded
                            ? 'Enviar a toda la familia o a un miembro específico ($memberCount miembros)'
                            : 'Cargando miembros...',
                        style: TextStyle(
                          fontSize: 12,
                          color: HabitikColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HabitikColors.blue500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

