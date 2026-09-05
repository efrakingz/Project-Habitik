import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/history_service.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _sessionService = SessionService();
  List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = true;
  String _filtro = 'Todas';
  StreamSubscription? _bgSubscription;
  VoidCallback? _socketUnsubscribe;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
    _suscribirEventosEnVivo();
  }

  @override
  void dispose() {
    _bgSubscription?.cancel();
    _socketUnsubscribe?.call();
    super.dispose();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _isLoading = true);
    final familyId = _sessionService.currentUser?.familyId;
    if (familyId != null && familyId.isNotEmpty) {
      final items = await HistoryService.cargarYSincronizar(familyId);
      if (mounted) {
        setState(() {
          _notificaciones = items;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _suscribirEventosEnVivo() {
    final familyId = _sessionService.currentUser?.familyId;
    if (familyId != null && familyId.isNotEmpty) {
      // 1. Escuchar eventos Socket.io en primer plano
      SocketService.initSocket(familyId);
      _socketUnsubscribe = SocketService.subscribe((data) {
        if (mounted) {
          setState(() {
            _notificaciones.insert(0, data);
          });
        }
      });

      // 2. Escuchar eventos del isolate de segundo plano si se despachan
      _bgSubscription = FlutterBackgroundService().on('nuevo_evento').listen((data) {
        if (data != null && mounted) {
          setState(() {
            final yaExiste = _notificaciones.any((n) =>
                (n['id'] != null && n['id'] == data['id']) ||
                (n['titulo'] == data['titulo'] && n['creado_en'] == data['creado_en']));
            if (!yaExiste) {
              _notificaciones.insert(0, Map<String, dynamic>.from(data));
            }
          });
        }
      });
    }
  }

  Future<void> _borrarHistorial() async {
    final familyId = _sessionService.currentUser?.familyId;
    if (familyId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Limpiar notificaciones?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: HabitikColors.textDark),
        ),
        content: Text(
          'Esta acción eliminará el historial de alertas familiares guardadas.',
          style: GoogleFonts.outfit(fontSize: 14, color: HabitikColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await HistoryService.borrarHistorial(familyId);
      if (mounted) {
        setState(() => _notificaciones.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial de notificaciones eliminado.'),
            backgroundColor: HabitikColors.green700,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _notificacionesFiltradas {
    if (_filtro == 'Todas') return _notificaciones;
    if (_filtro == 'Duchas') {
      return _notificaciones.where((n) {
        final tipo = (n['tipo'] ?? n['type'] ?? '').toString().toUpperCase();
        return tipo.contains('DUCHA') || tipo.contains('SPEEDRUN');
      }).toList();
    }
    if (_filtro == 'Alertas') {
      return _notificaciones.where((n) {
        final tipo = (n['tipo'] ?? n['type'] ?? '').toString().toUpperCase();
        return tipo.contains('ALERTA') || tipo.contains('GENERAL');
      }).toList();
    }
    return _notificaciones;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenShell(
        titulo: 'Notificaciones',
        subtitulo: _notificaciones.isEmpty ? 'Todo leído ✅' : '${_notificaciones.length} alertas familiares',
        showBackButton: true,
            headerActions: [
              if (_notificaciones.isNotEmpty)
                IconActionButton(
                  icon: Icons.delete_sweep_outlined,
                  onTap: _borrarHistorial,
                ),
            ],
            body: RefreshIndicator(
              onRefresh: _cargarNotificaciones,
              color: HabitikColors.green600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtros por categoría
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todas', '🔔'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Duchas', '🚿'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Alertas', '📢'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    else if (_notificacionesFiltradas.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _notificacionesFiltradas.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _notificacionesFiltradas[index];
                          return _buildNotificationCard(item, isDark)
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (index * 40).ms)
                              .slideY(begin: 0.1, end: 0);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildFilterChip(String label, String emoji) {
    final bool isSelected = _filtro == label;
    return GestureDetector(
      onTap: () => setState(() => _filtro = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? HabitikColors.green700 : Colors.white,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(
          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)).animate().scale(
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 12),
          Text(
            '¡Todo al día!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : HabitikColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No hay nuevas notificaciones por ahora. Cuando algún miembro de la familia empiece un reto o ducha, lo verás aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? Colors.white70 : HabitikColors.textLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, bool isDark) {
    final String titulo = item['titulo'] ?? item['title'] ?? 'Alerta Familiar';
    final String mensaje = item['mensaje'] ?? item['desc_text'] ?? '';
    final String usuario = item['usuario_nombre'] ?? item['sender_name'] ?? 'Familiar';
    final String tipo = (item['tipo'] ?? item['type'] ?? 'ALERTA_GENERAL').toString().toUpperCase();
    final String fecha = _formatearFecha(item['creado_en'] ?? item['created_at']);

    // Configuración visual por tipo
    Color iconBgColor = const Color(0xFFE8F5E9);
    Color iconColor = HabitikColors.green600;
    IconData iconData = Icons.notifications_rounded;

    if (tipo.contains('DUCHA') || tipo.contains('SPEEDRUN')) {
      iconBgColor = const Color(0xFFE0F7FA);
      iconColor = const Color(0xFF00ACC1);
      iconData = Icons.shower_rounded;
    } else if (tipo.contains('ALERTA') || tipo.contains('URGENTE')) {
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFFF9800);
      iconData = Icons.notification_important_rounded;
    } else if (tipo.contains('RETO') || tipo.contains('XP')) {
      iconBgColor = const Color(0xFFEDE7F6);
      iconColor = const Color(0xFF7E57C2);
      iconData = Icons.emoji_events_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
        borderRadius: HabitikRadius.md_,
        border: Border.all(
          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: HabitikShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? Colors.white : HabitikColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      fecha,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : HabitikColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF455A64),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 14, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      'Por: $usuario',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(dynamic fechaStr) {
    if (fechaStr == null) return 'Ahora';
    try {
      final dt = DateTime.parse(fechaStr.toString()).toLocal();
      final ahora = DateTime.now();
      final diferencia = ahora.difference(dt);

      if (diferencia.inMinutes < 1) return 'Ahora';
      if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes}m';
      if (diferencia.inHours < 24) {
        final hora = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        return 'Hoy $hora';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return 'Hoy';
    }
  }
}
