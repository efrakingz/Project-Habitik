import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:habitik/core/theme/theme.dart';

class InviteQrCard extends StatelessWidget {
  final String? inviteToken;
  final bool qrError;
  final VoidCallback onRetry;
  final void Function(String message)? onShowSuccess;

  const InviteQrCard({
    super.key,
    required this.inviteToken,
    required this.qrError,
    required this.onRetry,
    this.onShowSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final token = inviteToken;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Text(
            '🔗 CÓDIGO QR PARA TU FAMILIA (Invítalos a unirse)',
            style: TextStyle(
              color: HabitikColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HabitikColors.green600, width: 2.5),
              boxShadow: HabitikShadows.card,
            ),
            child: token != null
                ? QrImageView(
                    data: 'https://habitik.app/join?token=$token',
                    version: QrVersions.auto,
                    padding: EdgeInsets.zero,
                  )
                : qrError
                    ? Center(
                        child: IconButton(
                          icon: const Icon(Icons.refresh, size: 24),
                          onPressed: onRetry,
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
          ),
        ),
        const SizedBox(height: 8),
        if (token != null) ...[
          Center(
            child: Text(
              'Código: $token',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Botón "Copiar Código" que copia strictly el UUID plano del token
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: token));
                  onShowSuccess?.call('Código copiado al portapapeles');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HabitikColors.green100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HabitikColors.green600),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 13, color: HabitikColors.green700),
                      SizedBox(width: 4),
                      Text(
                        'Copiar Código',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: HabitikColors.green700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón "Copiar Enlace"
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'https://habitik.app/join?token=$token'));
                  onShowSuccess?.call('Enlace copiado');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    '📋 Copiar Enlace',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Botón "Compartir"
              InkWell(
                onTap: () => SharePlus.instance.share(
                  ShareParams(text: 'Únete a mi hogar en Habitik: https://habitik.app/join?token=$token'),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HabitikColors.green700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '📤 Compartir',
                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
