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
      builder: (_) => _NotificacionPersonalizadaSheet(
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet para enviar notificación personalizada
// ─────────────────────────────────────────────────────────────────────────────

class _NotificacionPersonalizadaSheet extends StatefulWidget {
  const _NotificacionPersonalizadaSheet({
    required this.members,
    required this.familyId,
    required this.senderName,
  });
  final List<FamilyMember> members;
  final String familyId;
  final String senderName;

  @override
  State<_NotificacionPersonalizadaSheet> createState() =>
      _NotificacionPersonalizadaSheetState();
}

class _NotificacionPersonalizadaSheetState
    extends State<_NotificacionPersonalizadaSheet> {
  final _tituloCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  FamilyMember? _destinatarioSeleccionado; // null = todos
  bool _enviando = false;

  // Plantillas rápidas
  static const List<Map<String, String>> _plantillas = [
    {'emoji': '🌿', 'titulo': '¡Hábito del día!', 'mensaje': 'Recuerda completar tu reto de hoy. ¡Cada acción cuenta para el hogar! 💪'},
    {'emoji': '💡', 'titulo': 'Alerta de consumo', 'mensaje': 'El consumo de luz de este mes está por encima de la meta. ¡Apaguemos lo que no usamos!'},
    {'emoji': '🚿', 'titulo': 'Reto de agua', 'mensaje': '¡Hoy es el día del reto de la ducha rápida! Menos de 5 minutos y ganarás XP extra.'},
    {'emoji': '🏆', 'titulo': '¡Bien hecho familia!', 'mensaje': 'Este mes vamos muy bien con nuestras metas. ¡Sigamos así para alcanzar el nivel siguiente!'},
  ];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final titulo = _tituloCtrl.text.trim();
    final mensaje = _mensajeCtrl.text.trim();

    if (titulo.isEmpty || mensaje.isEmpty) {
      HabitikFeedback.showError(context, 'Completa el título y el mensaje antes de enviar.');
      return;
    }

    setState(() => _enviando = true);

    try {
      final bodyMap = <String, dynamic>{
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo': 'MANUAL',
        'family_id': widget.familyId,
        'usuario_nombre': widget.senderName,
        if (_destinatarioSeleccionado != null)
          'destinatario_id': _destinatarioSeleccionado!.id,
      };

      final response = await ApiClient().post(
        '/notificaciones/enviar-personalizada',
        bodyMap,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        HabitikFeedback.showSuccess(
          context,
          _destinatarioSeleccionado != null
              ? '✅ Notificación enviada a ${_destinatarioSeleccionado!.nombre}'
              : '✅ Notificación enviada a toda la familia',
        );
      } else {
        HabitikFeedback.showError(context, 'Error al enviar. Intenta de nuevo.');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ [ControlScreen] Error enviando notificación: $e');
      HabitikFeedback.showError(context, 'Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111B15) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título del sheet
            Text(
              '🔔 Enviar Notificación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'El mensaje llegará aunque la app esté cerrada',
              style: TextStyle(fontSize: 12, color: HabitikColors.textMid),
            ),
            const SizedBox(height: 20),

            // Plantillas rápidas
            Text(
              'Plantillas rápidas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _plantillas.length,
                separatorBuilder: (_, x) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = _plantillas[i];
                  return _PlantillaChip(
                    label: '${p['emoji']} ${p['titulo']}',
                    onTap: () {
                      _tituloCtrl.text = p['titulo']!;
                      _mensajeCtrl.text = p['mensaje']!;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Destinatario
            Text(
              'Destinatario',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            _DestinatarioSelector(
              members: widget.members,
              selected: _destinatarioSeleccionado,
              onChanged: (m) => setState(() => _destinatarioSeleccionado = m),
              isDark: isDark,
            ),
            const SizedBox(height: 18),

            // Título
            _InputField(
              controller: _tituloCtrl,
              label: 'Título',
              hint: 'Ej: ¡Hábito del día!',
              isDark: isDark,
              maxLength: 60,
            ),
            const SizedBox(height: 12),

            // Mensaje
            _InputField(
              controller: _mensajeCtrl,
              label: 'Mensaje',
              hint: 'Escribe el mensaje que recibirá tu familia...',
              isDark: isDark,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HabitikColors.blue500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: HabitikColors.blue500.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _destinatarioSeleccionado != null
                                ? 'Enviar a ${_destinatarioSeleccionado!.nombre}'
                                : 'Enviar a toda la familia',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets del sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PlantillaChip extends StatelessWidget {
  const _PlantillaChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE8F5FF),
          borderRadius: HabitikRadius.xl_,
          border: Border.all(
            color: HabitikColors.blue500.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: HabitikColors.blue500,
          ),
        ),
      ),
    );
  }
}

class _DestinatarioSelector extends StatelessWidget {
  const _DestinatarioSelector({
    required this.members,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });
  final List<FamilyMember> members;
  final FamilyMember? selected;
  final ValueChanged<FamilyMember?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final todos = [null, ...members];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: todos.length,
        separatorBuilder: (_, x) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final member = todos[i];
          final isSelected = selected?.id == member?.id;
          final label = member == null ? '👨‍👩‍👧 Todos' : member.nombre;

          return GestureDetector(
            onTap: () => onChanged(member),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? HabitikColors.blue500
                    : (isDark ? const Color(0xFF1C2C1E) : const Color(0xFFF5F5F5)),
                borderRadius: HabitikRadius.xl_,
                border: Border.all(
                  color: isSelected
                      ? HabitikColors.blue500
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : HabitikColors.textDark),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
    this.maxLength,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : HabitikColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : HabitikColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: HabitikColors.textLight, fontSize: 13),
            counterStyle: TextStyle(color: HabitikColors.textLight, fontSize: 11),
            filled: true,
            fillColor: isDark ? const Color(0xFF1C2C1E) : const Color(0xFFF7FAF7),
            border: OutlineInputBorder(
              borderRadius: HabitikRadius.md_,
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : HabitikColors.green200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: HabitikRadius.md_,
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : HabitikColors.green200,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: HabitikRadius.md_,
              borderSide: BorderSide(
                color: HabitikColors.blue500,
                width: 1.8,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
