import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:habitik/features/rewards/widgets/reward_icon_helper.dart';

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

  Future<void> _aprobarPropuesta(
    RewardProposal proposal, 
    int costo, {
    required bool esFamiliar,
    String? titulo,
    String? descripcion,
    String? icono,
  }) async {
    try {
      await _rewardsService.approveProposal(
        proposal.id, 
        costo,
        esFamiliar: esFamiliar,
        titulo: titulo,
        descripcion: descripcion,
        icono: icono,
      );
      if (!mounted) return;
      final finalTitulo = (titulo != null && titulo.isNotEmpty) ? titulo : proposal.titulo;
      final tipoMensaje = esFamiliar 
          ? 'como Colecta Familiar Colaborativa' 
          : 'como Premio Personal';
      HabitikFeedback.showSuccess(
        context, 
        '¡"$finalTitulo" aprobada $tipoMensaje por $costo 🪙!',
      );
      _refreshAll();
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
      subtitulo: 'ADMINISTRACIÓN',
      headerActions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          onPressed: _refreshAll,
          tooltip: 'Refrescar datos',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 12, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'JEFE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: HabitikColors.green500,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroBannerCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Administrar Familia',
                subtitle: 'MODERACIÓN DE RECOMPENSAS',
                description: _loadingMembers
                    ? 'Gestiona las propuestas de premios de tus familiares, asigna monedas justas y modera los canjes del hogar.'
                    : 'Hogar con ${_members.length + 1} integrantes. Gestiona las propuestas de premios, asigna monedas justas y modera los canjes del hogar.',
                actionLabel: 'Actualizar',
                onAction: _refreshAll,
              ),
              const SizedBox(height: 20),

              // ── Guía de valor de monedas ─────────────────────────────────
              const CoinValueGuide(initialExpanded: false),
              const SizedBox(height: 28),

              // ── Sección 1: Propuestas de Premios Pendientes (Ámbar) ───────
              _AdminSectionGroupCard(
                title: 'Propuestas de Premios',
                subtitle: 'Asigna el valor en monedas y aprueba propuestas',
                icon: Icons.lightbulb_rounded,
                count: _proposals.length,
                badgeLabel: 'pendientes',
                accentColor: const Color(0xFFD97706),
                child: _loadingProposals
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _proposals.isEmpty
                        ? const _EmptySectionCard(
                            icon: Icons.inbox_outlined,
                            mensaje: 'No hay propuestas de premios pendientes.',
                            detalle: 'Cuando un familiar proponga un premio, aparecerá aquí para que le fijes el costo.',
                            accentColor: Color(0xFFD97706),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < _proposals.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _ProposalModerationCard(
                                  proposal: _proposals[i],
                                  onApprove: (costo, {required bool esFamiliar, String? titulo, String? descripcion, String? icono}) {
                                    _aprobarPropuesta(
                                      _proposals[i], 
                                      costo,
                                      esFamiliar: esFamiliar,
                                      titulo: titulo,
                                      descripcion: descripcion,
                                      icono: icono,
                                    );
                                  },
                                  onReject: () => _rechazarPropuesta(_proposals[i]),
                                ),
                              ],
                            ],
                          ),
              ),

              const SizedBox(height: 32),

              // ── Sección 2: Solicitudes de Canje Personal (Azul) ───────────
              _AdminSectionGroupCard(
                title: 'Solicitudes de Canje Personal',
                subtitle: 'Revisa y confirma cuando un integrante reclame un premio',
                icon: Icons.redeem_rounded,
                count: _pendingCanjes.length,
                badgeLabel: 'por revisar',
                accentColor: const Color(0xFF2563EB),
                child: _loadingCanjes
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _pendingCanjes.isEmpty
                        ? const _EmptySectionCard(
                            icon: Icons.check_circle_outline_rounded,
                            mensaje: 'No hay solicitudes de canje pendientes.',
                            detalle: 'Todos los canjes personales solicitados han sido procesados.',
                            accentColor: Color(0xFF2563EB),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < _pendingCanjes.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _PendingCanjeCard(
                                  canje: _pendingCanjes[i],
                                  onApprove: () => _aprobarCanje(_pendingCanjes[i].id),
                                  onReject: () => _rechazarCanje(_pendingCanjes[i].id),
                                ),
                              ],
                            ],
                          ),
              ),

              const SizedBox(height: 32),

              // ── Sección 3: Colectas Familiares Activas (Esmeralda) ─────────
              _AdminSectionGroupCard(
                title: 'Colectas Familiares en Curso',
                subtitle: 'Metas colaborativas que se canjean al 100% de aportes',
                icon: Icons.diversity_3_rounded,
                count: _colectas.length,
                badgeLabel: 'activas',
                accentColor: const Color(0xFF059669),
                child: _loadingColectas
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _colectas.isEmpty
                        ? const _EmptySectionCard(
                            icon: Icons.groups_outlined,
                            mensaje: 'No hay colectas familiares activas.',
                            detalle: 'Crea un premio familiar desde la tienda de canjes para iniciar una meta compartida.',
                            accentColor: Color(0xFF059669),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < _colectas.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                _ColectaStatusCard(colecta: _colectas[i]),
                              ],
                            ],
                          ),
              ),
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

class _AdminSectionGroupCard extends StatelessWidget {
  const _AdminSectionGroupCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.count,
    this.badgeLabel = 'activas',
    this.accentColor = HabitikColors.green600,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int? count;
  final String badgeLabel;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final hasItems = count != null && count! > 0;
    final isAmber = accentColor == const Color(0xFFD97706);
    final isBlue = accentColor == const Color(0xFF2563EB);

    final groupBg = isDark
        ? (isAmber
            ? const Color(0xFF241C12)
            : isBlue
                ? const Color(0xFF132230)
                : const Color(0xFF15261B))
        : (isAmber
            ? const Color(0xFFFDF5E8)
            : isBlue
                ? const Color(0xFFE8F2FC)
                : const Color(0xFFE3F3E8));

    final groupBorder = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : (isAmber
            ? const Color(0xFFF3CE85)
            : isBlue
                ? const Color(0xFFA0C9F4)
                : const Color(0xFF96D7AE));

    final iconBg = isDark
        ? accentColor.withValues(alpha: 0.18)
        : (isAmber
            ? const Color(0xFFFDE8C0)
            : isBlue
                ? const Color(0xFFD5E7FA)
                : const Color(0xFFD0EEDB));

    final iconBorder = isDark
        ? accentColor.withValues(alpha: 0.35)
        : (isAmber
            ? const Color(0xFFF5BE58)
            : isBlue
                ? const Color(0xFF7CB8F3)
                : const Color(0xFF6DC491));

    final titleColor = isDark
        ? Colors.white
        : (isAmber
            ? const Color(0xFF563503)
            : isBlue
                ? const Color(0xFF0C3056)
                : const Color(0xFF0A361D));

    final subtitleColor = isDark
        ? HabitikColors.green200
        : (isAmber
            ? const Color(0xFF865306)
            : isBlue
                ? const Color(0xFF1E5B94)
                : const Color(0xFF1E673B));

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : (isAmber
            ? const Color(0xFFF5D698)
            : isBlue
                ? const Color(0xFFBFDAF8)
                : const Color(0xFFB5E2C4));

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
          // ── Cabecera de la sección ──
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
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasItems
                        ? accentColor
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: hasItems
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    hasItems ? '$count $badgeLabel' : 'Al día',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: hasItems
                          ? Colors.white
                          : (isDark ? Colors.white54 : HabitikColors.textMid),
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
            color: dividerColor,
          ),
          const SizedBox(height: 14),
          // ── Contenido de la sección ──
          child,
        ],
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  final String detalle;
  final Color accentColor;

  const _EmptySectionCard({
    required this.icon,
    required this.mensaje,
    required this.detalle,
    this.accentColor = HabitikColors.green600,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final isAmber = accentColor == const Color(0xFFD97706);
    final isBlue = accentColor == const Color(0xFF2563EB);

    final bgColor = isDark
        ? HabitikColors.darkCardBg
        : (isAmber
            ? const Color(0xFFFFF9ED)
            : isBlue
                ? const Color(0xFFF2F8FE)
                : const Color(0xFFF0F9F3));

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : (isAmber
            ? const Color(0xFFF6CE7B)
            : isBlue
                ? const Color(0xFFA8CEF6)
                : const Color(0xFF9BD9B5));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: HabitikShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0F291E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : const Color(0xFF455A64),
                    height: 1.3,
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

typedef OnApproveProposalCallback = void Function(
  int costo, {
  required bool esFamiliar,
  String? titulo,
  String? descripcion,
  String? icono,
});

class _ProposalModerationCard extends StatefulWidget {
  final RewardProposal proposal;
  final OnApproveProposalCallback onApprove;
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
  late int _costoAsignado;
  late bool _esFamiliar;
  late String _titulo;
  late String _descripcion;
  late String _emoji;

  @override
  void initState() {
    super.initState();
    _costoAsignado = widget.proposal.esFamiliar ? 40 : 15;
    _esFamiliar = widget.proposal.esFamiliar;
    _titulo = widget.proposal.titulo;
    _descripcion = widget.proposal.descripcion;
    _emoji = widget.proposal.emoji;
  }

  @override
  void didUpdateWidget(_ProposalModerationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proposal.id != widget.proposal.id) {
      _costoAsignado = widget.proposal.esFamiliar ? 40 : 15;
      _esFamiliar = widget.proposal.esFamiliar;
      _titulo = widget.proposal.titulo;
      _descripcion = widget.proposal.descripcion;
      _emoji = widget.proposal.emoji;
    }
  }

  Future<void> _abrirDialogoEdicion() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _EditProposalDialog(
        initialTitulo: _titulo,
        initialDescripcion: _descripcion,
        initialEmoji: _emoji,
        initialEsFamiliar: _esFamiliar,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _titulo = result['titulo']?.toString() ?? _titulo;
        _descripcion = result['descripcion']?.toString() ?? _descripcion;
        _emoji = result['emoji']?.toString() ?? _emoji;
        _esFamiliar = result['esFamiliar'] == true;
        if (_esFamiliar && _costoAsignado < 20) {
          _costoAsignado = 30;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final prop = widget.proposal;

    final cardBg = isDark
        ? const Color(0xFF1B271E)
        : (_esFamiliar ? const Color(0xFFF7FBF8) : const Color(0xFFFFFDF8));

    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : (_esFamiliar ? const Color(0xFFBCE0C8) : const Color(0xFFF6D38B));

    final iconBg = isDark
        ? HabitikColors.green900.withValues(alpha: 0.5)
        : (_esFamiliar ? const Color(0xFFD6EEDF) : const Color(0xFFFCEBCA));

    final iconBorder = isDark
        ? HabitikColors.green700.withValues(alpha: 0.5)
        : (_esFamiliar ? const Color(0xFFA5DCB6) : const Color(0xFFF7CF76));

    final iconColor = isDark
        ? HabitikColors.green300
        : (_esFamiliar ? const Color(0xFF16522B) : const Color(0xFF8C5300));

    final sliderBg = isDark
        ? Colors.black.withValues(alpha: 0.25)
        : (_esFamiliar ? const Color(0xFFE2F4E7) : const Color(0xFFFFF2D6));

    final sliderBorder = _esFamiliar ? const Color(0xFFA5DCB6) : const Color(0xFFF7CE76);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: cardBorder,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _abrirDialogoEdicion,
                child: Container(
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
                    getRewardCategoryIcon(_emoji, _titulo),
                    size: 22,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: HabitikColors.green600,
                              ),
                            ),
                          ],
                        ),
                        // Botón para editar detalles
                        InkWell(
                          onTap: _abrirDialogoEdicion,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : HabitikColors.amber400.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: HabitikColors.amber400.withValues(alpha: 0.6),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_rounded, size: 12, color: HabitikColors.amber400),
                                const SizedBox(width: 4),
                                Text(
                                  'Editar',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.amber[200] : const Color(0xFF8D5300),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _titulo,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F291E),
                      ),
                    ),
                    if (_descripcion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _descripcion,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : const Color(0xFF37474F),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Selector de Tipo: Personal vs Familiar Colaborativo ───────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFFE5ECE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _esFamiliar = false);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_esFamiliar
                            ? (isDark ? const Color(0xFF2C3E50) : const Color(0xFFFFF6E5))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: !_esFamiliar && !isDark
                            ? Border.all(color: const Color(0xFFF7D186), width: 1)
                            : null,
                        boxShadow: !_esFamiliar ? HabitikShadows.card : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: !_esFamiliar
                                ? (isDark ? Colors.white : const Color(0xFF5D3800))
                                : HabitikColors.textMid,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Personal',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: !_esFamiliar ? FontWeight.w800 : FontWeight.w600,
                              color: !_esFamiliar
                                  ? (isDark ? Colors.white : const Color(0xFF5D3800))
                                  : HabitikColors.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _esFamiliar = true;
                        if (_costoAsignado < 20) {
                          _costoAsignado = 30;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _esFamiliar
                            ? (isDark ? const Color(0xFF2E7D32) : HabitikColors.green600)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _esFamiliar ? HabitikShadows.card : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 15,
                            color: _esFamiliar ? Colors.white : HabitikColors.textMid,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Familiar Colaborativo',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: _esFamiliar ? FontWeight.w800 : FontWeight.w600,
                              color: _esFamiliar ? Colors.white : HabitikColors.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Banner explicativo contextual ─────────────────────────────
          const SizedBox(height: 8),
          if (_esFamiliar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? HabitikColors.green900.withValues(alpha: 0.3) : const Color(0xFFDDF3E5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? HabitikColors.green700.withValues(alpha: 0.5) : const Color(0xFF8ED6A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined, size: 16, color: HabitikColors.green600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Colecta Colaborativa: Las $_costoAsignado 🪙 se distribuirán entre todos los integrantes y el premio se canjeará para la familia al completarse.',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: isDark ? Colors.white70 : const Color(0xFF144D25),
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFF3DE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFF7D186)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 15, color: isDark ? Colors.white60 : const Color(0xFF7A4A03)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Premio Individual: Estará disponible en la tienda para que el integrante lo canjee individualmente por $_costoAsignado 🪙.',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: isDark ? Colors.white60 : const Color(0xFF6D4002),
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Slider de costo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sliderBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sliderBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Asignar costo en monedas:',
                      style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: HabitikColors.amber400.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_costoAsignado 🪙',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFB300),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
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
                  activeColor: _esFamiliar ? HabitikColors.green600 : HabitikColors.amber500,
                  inactiveColor: isDark ? Colors.white12 : Colors.black12,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _costoAsignado = v.round());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('5 🪙 (1-2 días)', style: GoogleFonts.outfit(fontSize: 10.5, color: HabitikColors.textLight)),
                    Text('200 🪙 (meta grande)', style: GoogleFonts.outfit(fontSize: 10.5, color: HabitikColors.textLight)),
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
                  child: Text('Rechazar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApprove(
                      _costoAsignado,
                      esFamiliar: _esFamiliar,
                      titulo: _titulo,
                      descripcion: _descripcion,
                      icono: _emoji,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _esFamiliar ? Icons.groups_rounded : Icons.check_circle, 
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _esFamiliar
                              ? 'Aprobar Familiar ($_costoAsignado 🪙)'
                              : 'Aprobar Personal ($_costoAsignado 🪙)',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12.5),
                          overflow: TextOverflow.ellipsis,
                        ),
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

class _EditProposalDialog extends StatefulWidget {
  final String initialTitulo;
  final String initialDescripcion;
  final String initialEmoji;
  final bool initialEsFamiliar;

  const _EditProposalDialog({
    required this.initialTitulo,
    required this.initialDescripcion,
    required this.initialEmoji,
    required this.initialEsFamiliar,
  });

  @override
  State<_EditProposalDialog> createState() => _EditProposalDialogState();
}

class _EditProposalDialogState extends State<_EditProposalDialog> {
  late final TextEditingController _tituloController;
  late final TextEditingController _descController;
  late String _selectedEmoji;
  late bool _esFamiliar;

  static const List<String> _emojisSugeridos = [
    '🍕', '🍦', '🎮', '🎬', '🚴', '🏖️', '🎳', '🎁', '🍔', '🍿', '🧁', '⚽'
  ];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.initialTitulo);
    _descController = TextEditingController(text: widget.initialDescripcion);
    _selectedEmoji = widget.initialEmoji;
    _esFamiliar = widget.initialEsFamiliar;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _guardar() {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      HabitikFeedback.showError(context, 'El título del premio no puede estar vacío.');
      return;
    }

    Navigator.of(context).pop({
      'titulo': titulo,
      'descripcion': _descController.text.trim(),
      'emoji': _selectedEmoji,
      'esFamiliar': _esFamiliar,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1B271E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: HabitikColors.amber400.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: HabitikColors.amber400, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Editar Solicitud',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : HabitikColors.textDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Selector de emoji
            Text(
              'Icono / Emoji:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojisSugeridos.map((e) {
                final isSelected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedEmoji = e);
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? HabitikColors.amber400.withValues(alpha: 0.3) 
                          : (isDark ? Colors.white10 : const Color(0xFFF1F5F2)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? HabitikColors.amber400 : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(e, style: const TextStyle(fontSize: 19)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              'Título del premio:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Ej. Noche de pizza',
                filled: true,
                fillColor: isDark ? Colors.black26 : const Color(0xFFF9FBE7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: HabitikColors.amber400.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: HabitikColors.green500, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),

            // Descripción
            Text(
              'Descripción o detalle:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ej. Noche de pizza en familia viendo una película',
                filled: true,
                fillColor: isDark ? Colors.black26 : const Color(0xFFF9FBE7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: HabitikColors.amber400.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: HabitikColors.green500, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),

            // Switch tipo familiar colaborativo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _esFamiliar 
                    ? HabitikColors.green500.withValues(alpha: 0.12)
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F5F5)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _esFamiliar 
                      ? HabitikColors.green500.withValues(alpha: 0.3) 
                      : Colors.transparent,
                ),
              ),
              child: SwitchListTile.adaptive(
                value: _esFamiliar,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _esFamiliar = v);
                },
                activeThumbColor: HabitikColors.green500,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Familiar Colaborativo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : HabitikColors.textDark,
                  ),
                ),
                subtitle: Text(
                  'Divide la meta entre todos los miembros de la familia',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : HabitikColors.textMid,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HabitikColors.green500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                    ),
                    child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final cardBg = isDark ? const Color(0xFF1A222C) : const Color(0xFFF8FBFE);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFB8D8F4);
    final iconBg = isDark ? const Color(0xFF2C3E50) : const Color(0xFFD6E8FA);
    final iconBorder = isDark ? Colors.white12 : const Color(0xFFA1CDF7);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF114C87);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HabitikShadows.card,
        border: Border.all(
          color: cardBorder,
          width: 1.2,
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  getRewardCategoryIcon(canje.rewardEmoji, canje.rewardTitulo),
                  size: 22,
                  color: iconColor,
                ),
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
                          style: GoogleFonts.outfit(
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
                      style: GoogleFonts.outfit(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0C2B4B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${canje.costoPagado} 🪙 aportadas · ${_formatDate(canje.createdAt)}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFB300),
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
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text('Rechazar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text('Aprobar Canje', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
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
    final cardBg = isDark ? const Color(0xFF1E2F23) : const Color(0xFFF7FBF8);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFB4E4C5);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.groups_outlined, size: 16, color: HabitikColors.green600),
                  const SizedBox(width: 6),
                  Text(
                    'Colecta Activa',
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? HabitikColors.green300 : const Color(0xFF0F4E26),
                    ),
                  ),
                ],
              ),
              Text(
                '${colecta.totalRecaudado} de ${colecta.totalRequerido} 🪙',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: const Color(0xFFFFA000),
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
              valueColor: const AlwaysStoppedAnimation<Color>(HabitikColors.green600),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Aportes de la familia:',
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : const Color(0xFF2C4A36),
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
                      color: a.pagado ? HabitikColors.green600 : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${a.nombre}: ${a.pagado ? "${a.montoPagado} 🪙 (Listo)" : "${a.montoAsignado} 🪙 (Pendiente)"}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: a.pagado ? const Color(0xFF1B5E20) : (isDark ? Colors.white60 : Colors.black54),
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
