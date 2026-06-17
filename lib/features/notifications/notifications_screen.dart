import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifs = NotificationItem.mockList;

  IconData _icon(String name) {
    switch (name) {
      case 'check_circle': return Icons.check_circle_outline;
      case 'person_add':   return Icons.person_add_alt_1_outlined;
      case 'emoji_events': return Icons.emoji_events_outlined;
      case 'cancel':       return Icons.cancel_outlined;
      case 'card_giftcard': return Icons.card_giftcard_outlined;
      default:             return Icons.notifications_outlined;
    }
  }

  Color _parseColor(String hex) {
    try { return Color(int.parse(hex.replaceAll('#', '0xFF'))); }
    catch (_) { return HabitikColors.green600; }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifs.where((n) => !n.leida).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Notificaciones',
          subtitulo: unread > 0 ? '$unread sin leer' : 'Todo leído ✅',
          body: _notifs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 12),
                      Text(
                        'Sin notificaciones',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = _notifs[i];
                    final color = _parseColor(n.colorHex);

                    return Container(
                       padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.leida
                            ? (isDark ? const Color(0xFF1E2E22) : Colors.white)
                            : (isDark ? const Color(0xFF2D3E2F) : const Color(0xFFEBF7EC)),
                        borderRadius: HabitikRadius.lg_,
                        border: Border.all(color: isDark ? const Color(0x30FFFFFF) : Colors.white, width: 3.0),
                        boxShadow: HabitikShadows.card,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
                            child: Center(child: Icon(_icon(n.iconNombre), color: color, size: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      n.titulo,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : HabitikColors.textDark,
                                        fontSize: 13,
                                        fontWeight: n.leida ? FontWeight.w600 : FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (!n.leida) Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                ]),
                                const SizedBox(height: 4),
                                Text(n.descripcion, style: TextStyle(color: isDark ? Colors.white70 : HabitikColors.textLight, fontSize: 12, height: 1.3)),
                                const SizedBox(height: 4),
                                Text(n.time, style: TextStyle(color: isDark ? Colors.white30 : HabitikColors.textHint, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.05, duration: 300.ms);
                  },
                ),
        ),
      ),
    );
  }
}
