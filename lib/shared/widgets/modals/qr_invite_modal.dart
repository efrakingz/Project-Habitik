import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/audio_service.dart';

/// Modal centralizado para mostrar el código QR y enlace de invitación familiar.
class QrInviteModal extends StatelessWidget {
  final String inviteToken;

  const QrInviteModal({super.key, required this.inviteToken});

  /// Abre el diálogo. Si [inviteToken] es nulo, lo consulta dinámicamente al backend.
  static Future<void> show(BuildContext context, {String? inviteToken}) async {
    String token = inviteToken ?? '';

    if (token.isEmpty) {
      try {
        final response = await ApiClient().get('/familia/invite');
        final data = jsonDecode(response.body);
        token = data['invite_token'] ?? '';
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al obtener código: ${e.toString().replaceAll('Exception:', '').trim()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => QrInviteModal(inviteToken: token),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E2E22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: HabitikRadius.lg_,
        side: BorderSide(
          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF263D2B) : HabitikColors.green100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🏡', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Súmalos al Hogar!',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pide a tu familiar que escanee el código o comparte el enlace directo.',
                        style: TextStyle(
                          color: isDark ? HabitikColors.green200 : HabitikColors.textMid,
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    AudioService.playSFX('click.mp3');
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contenedor QR
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HabitikColors.green600, width: 2.5),
                boxShadow: HabitikShadows.card,
              ),
              child: QrImageView(
                data: 'https://habitik.app/join?token=$inviteToken',
                version: QrVersions.auto,
                padding: EdgeInsets.zero,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'CÓDIGO DE INVITACIÓN:',
              style: TextStyle(
                color: HabitikColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              inviteToken,
              style: const TextStyle(
                color: HabitikColors.green800,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    AudioService.playSFX('click.mp3');
                    Clipboard.setData(ClipboardData(text: inviteToken));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Código copiado al portapapeles! 📋✨'),
                        backgroundColor: HabitikColors.green700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copiar Código'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green700,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AudioService.playSFX('click.mp3');
                    final link = 'https://habitik.app/join?token=$inviteToken';
                    final text = '¡Únete a mi hogar en Habitik! 🏡\nUsa este enlace para unirte: $link\n\nCódigo de invitación: $inviteToken';
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Enlace de invitación copiado! 🔗✨'),
                        backgroundColor: HabitikColors.green700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: const Text('Copiar Enlace'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF223528) : Colors.white,
                    foregroundColor: isDark ? Colors.white : HabitikColors.green800,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: HabitikColors.green500, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AudioService.playSFX('click.mp3');
                    final link = 'https://habitik.app/join?token=$inviteToken';
                    final text = '¡Únete a mi hogar en Habitik! 🏡\nUsa este enlace para unirte: $link\n\nCódigo de invitación: $inviteToken';
                    SharePlus.instance.share(ShareParams(text: text));
                  },
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2E4233) : Colors.grey.shade100,
                    foregroundColor: isDark ? Colors.white70 : HabitikColors.textDark,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
