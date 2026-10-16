import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/features/rewards/services/rewards_service.dart';
import 'package:habitik/features/rewards/widgets/coin_value_guide.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late final UserProfile _user;
  final RewardsService _rewardsService = RewardsService();

  List<FamilyMember> _members = [];
  bool _loadingMembers = true;

  List<RewardProposal> _proposals = [];
  bool _loadingProposals = true;

  List<PendingCanje> _pendingCanjes = [];
  bool _loadingCanjes = true;

  List<FamilyColecta> _colectas = [];
  bool _loadingColectas = true;

  late final VoidCallback _unsubscribeSocket;

  @override
  void initState() {
    super.initState();
    _user = SessionService().currentUser ?? UserProfile.empty;
    _refreshAll();
    _unsubscribeSocket = SocketService.subscribe(_onSocketEvent);
  }

  void _onSocketEvent(Map<String, dynamic> data) {
    final tipo = data['tipo']?.toString() ?? '';
    if (tipo == 'PROPUESTA_NUEVA' || 
        tipo == 'CANJE_SOLICITADO' || 
        tipo == 'COLECTA_INICIADA' || 
        tipo == 'COLECTA_APORTE' || 
        tipo == 'COLECTA_COMPLETADA') {
      if (mounted) {
        _refreshAll();
      }
    }
  }

  @override
  void dispose() {
    _unsubscribeSocket();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadMembers(),
      _loadProposals(),
      _loadPendingCanjes(),
      _loadColectas(),
    ]);
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

  Future<void> _loadProposals() async {
    setState(() => _loadingProposals = true);
    try {
      final props = await _rewardsService.getPendingProposals();
      if (!mounted) return;
      setState(() {
        _proposals = props;
        _loadingProposals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingProposals = false);
      debugPrint('⚠️ [ControlScreen] Error cargando propuestas: $e');
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

  Future<void> _loadColectas() async {
    setState(() => _loadingColectas = true);
    try {
      final catalog = await _rewardsService.getCatalog();
      if (!mounted) return;
      setState(() {
        _colectas = catalog.colectasActivas;
        _loadingColectas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingColectas = false);
      debugPrint('⚠️ [ControlScreen] Error cargando colectas activas: $e');
    }
  }

  Future<void> _aprobarPropuesta(RewardProposal proposal, int costo) async {
    try {
      await _rewardsService.approveProposal(proposal.id, costo);
      if (!mounted) return;
      HabitikFeedback.showSuccess(
        context, 
        '¡Propuesta "${proposal.titulo}" aprobada por $costo 🪙 y publicada en la tienda!',
      );
      _loadProposals();
    } catch (e) {
      if (!mounted) return;
      HabitikFeedback.showError(context, 'Error al aprobar: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _rechazarPropuesta(RewardProposal proposal) async {
    try {
      await _rewardsService.rejectProposal(proposal.id);
      if (!mounted) return;
      HabitikFeedback.showSuccess(context, 'Propuesta rechazada con éxito.');
      _loadProposals();
    } catch (e) {
      if (!mounted) return;
      HabitikFeedback.showError(context, 'Error al rechazar: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _aprobarCanje(String canjeId) async {
    try {
      await _rewardsService.approveCanje(canjeId);
      if (!mounted) return;
      HabitikFeedback.showSuccess(context, 'Canje aprobado exitosamente');
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
      HabitikFeedback.showSuccess(context, 'Canje rechazado (monedas reembolsadas al integrante)');
      _loadPendingCanjes();
    } catch (e) {
      if (!mounted) return;
      HabitikFeedback.showError(context, 'Error al rechazar: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titulo: 'Panel de Control',
      subtitulo: '👑 Jefe de Familia',
      headerActions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          onPressed: _refreshAll,
          tooltip: 'Refrescar datos',
        ),
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
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: HabitikColors.green500,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroBannerCard(
                emoji: '👑',
                title: 'Administrar Familia',
                description: _loadingMembers
                    ? 'Gestiona las propuestas de premios de tus familiares, asigna monedas justas y modera los canjes del hogar.'
                    : 'Familia con ${_members.length + 1} integrantes. Gestiona las propuestas de premios, asigna monedas justas y modera los canjes del hogar.',
                actionLabel: 'Actualizar',
                onAction: _refreshAll,
              ),
              const SizedBox(height: 20),

              // ── Guía de valor de monedas ─────────────────────────────────
              const CoinValueGuide(initialExpanded: false),
              const SizedBox(height: 24),

              // ── Sección: Propuestas de Premios Pendientes ────────────────
              _SectionHeader(
                title: '💡 Propuestas de Premios',
                subtitle: 'Asigna el valor en monedas y aprueba los premios que proponen tus familiares',
              ),
              const SizedBox(height: 12),
              if (_loadingProposals)
                const Center(child: CircularProgressIndicator())
              else if (_proposals.isEmpty)
                const _EmptySectionCard(
                  emoji: '🙌',
                  mensaje: 'No hay propuestas de premios pendientes.',
                  detalle: 'Cuando un familiar proponga un premio, aparecerá aquí para que le fijes el costo.',
                )
              else
                ..._proposals.map((prop) => _ProposalModerationCard(
                      proposal: prop,
                      onApprove: (costo) => _aprobarPropuesta(prop, costo),
                      onReject: () => _rechazarPropuesta(prop),
                    )),
              
              const SizedBox(height: 28),

              // ── Sección: Solicitudes de Canje Personal ───────────────────
              _SectionHeader(
                title: '🎁 Solicitudes de Canje Personal',
                subtitle: 'Revisa y confirma cuando un integrante reclame un premio en la tienda',
              ),
              const SizedBox(height: 12),
              if (_loadingCanjes)
                const Center(child: CircularProgressIndicator())
              else if (_pendingCanjes.isEmpty)
                const _EmptySectionCard(
                  emoji: '✨',
                  mensaje: 'No hay solicitudes de canje pendientes.',
                  detalle: 'Todos los canjes personales solicitados han sido procesados.',
                )
              else
                ..._pendingCanjes.map((canje) => _PendingCanjeCard(
                      canje: canje,
                      onApprove: () => _aprobarCanje(canje.id),
                      onReject: () => _rechazarCanje(canje.id),
                    )),

              const SizedBox(height: 28),

              // ── Sección: Colectas Familiares Activas ─────────────────────
              _SectionHeader(
                title: '👨‍👩‍👧 Colectas Familiares en Curso',
                subtitle: 'Premios colaborativos que se auto-canjean al alcanzar el 100% de aportes',
              ),
              const SizedBox(height: 12),
              if (_loadingColectas)
                const Center(child: CircularProgressIndicator())
              else if (_colectas.isEmpty)
                const _EmptySectionCard(
                  emoji: '🤝',
                  mensaje: 'No hay colectas familiares activas.',
                  detalle: 'Crea un premio familiar desde la tienda de canjes para iniciar una meta compartida.',
                )
              else
                ..._colectas.map((col) => _ColectaStatusCard(colecta: col)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets independientes (Clean Code Habitik)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : HabitikColors.textDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.5, color: HabitikColors.textMid),
        ),
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  final String emoji;
  final String mensaje;
  final String detalle;

  const _EmptySectionCard({
    required this.emoji,
    required this.mensaje,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16251B) : Colors.white,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: HabitikShadows.card,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : HabitikColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detalle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : HabitikColors.textMid,
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

class _ProposalModerationCard extends StatefulWidget {
  final RewardProposal proposal;
  final ValueChanged<int> onApprove;
  final VoidCallback onReject;

  const _ProposalModerationCard({
    required this.proposal,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_ProposalModerationCard> createState() => _ProposalModerationCardState();
}

class _ProposalModerationCardState extends State<_ProposalModerationCard> {
  int _costoAsignado = 15; // Costo por defecto

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final prop = widget.proposal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B271E) : Colors.white,
        borderRadius: HabitikRadius.lg_,
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: HabitikColors.amber400.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E381C) : const Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(prop.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          letra: prop.usuarioNombre.isNotEmpty ? prop.usuarioNombre[0].toUpperCase() : 'U',
                          colorHex: '#43A047',
                          radius: 10,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Propuesto por: ${prop.usuarioNombre}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HabitikColors.green500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      prop.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : HabitikColors.textDark,
                      ),
                    ),
                    if (prop.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        prop.descripcion,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : HabitikColors.textMid,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Slider de costo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFFF9FBE7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: HabitikColors.amber400.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Asignar costo en monedas:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: HabitikColors.amber400.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_costoAsignado 🪙',
                        style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _costoAsignado.toDouble(),
                  min: 5,
                  max: 200,
                  divisions: 39,
                  activeColor: HabitikColors.green500,
                  inactiveColor: isDark ? Colors.white12 : Colors.black12,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _costoAsignado = v.round());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('5 🪙 (1-2 días)', style: TextStyle(fontSize: 10, color: HabitikColors.textLight)),
                    Text('200 🪙 (meta grande)', style: TextStyle(fontSize: 10, color: HabitikColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const Text('Rechazar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onApprove(_costoAsignado),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Aprobar por $_costoAsignado 🪙',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A222C) : Colors.white,
        borderRadius: HabitikRadius.lg_,
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: HabitikColors.blue500.withValues(alpha: 0.2),
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
                        UserAvatar(
                          letra: canje.usuarioNombre.isNotEmpty ? canje.usuarioNombre[0].toUpperCase() : 'U',
                          colorHex: '#1E88E5',
                          radius: 10,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Canjeado por: ${canje.usuarioNombre}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                      '${canje.costoPagado} 🪙 pagadas · ${_formatDate(canje.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HabitikColors.amber400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                  child: const Text('Aprobar Canje', style: TextStyle(fontWeight: FontWeight.bold)),
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

class _ColectaStatusCard extends StatelessWidget {
  final FamilyColecta colecta;
  const _ColectaStatusCard({required this.colecta});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2F23) : const Color(0xFFF1F8E9),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: HabitikColors.green500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🤝 Colecta Activa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: HabitikColors.green500,
                ),
              ),
              Text(
                '${colecta.totalRecaudado} de ${colecta.totalRequerido} 🪙',
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
              value: colecta.progreso,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(HabitikColors.green500),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Aportes de la familia:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : HabitikColors.textMid,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: colecta.aportes.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: a.pagado 
                      ? HabitikColors.green500.withValues(alpha: 0.2)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      a.pagado ? Icons.check_circle : Icons.schedule,
                      size: 13,
                      color: a.pagado ? HabitikColors.green500 : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${a.nombre}: ${a.pagado ? "${a.montoPagado} 🪙 (Listo)" : "${a.montoAsignado} 🪙 (Pendiente)"}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: a.pagado ? HabitikColors.green400 : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
