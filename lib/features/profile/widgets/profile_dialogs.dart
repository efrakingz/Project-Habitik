import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/user.dart';

class ProfileDialogs {
  static void showEditProfileDialog({
    required BuildContext context,
    required UserProfile user,
    required ValueChanged<UserProfile> onSaved,
  }) {
    final nameCtrl = TextEditingController(text: user.nombre);
    final letterCtrl = TextEditingController(text: user.avatarLetra);
    String selectedColor = user.avatarColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final List<String> presetColors = [
              '#43A047', // Verde
              '#2E7D32', // Verde oscuro
              '#9C27B0', // Púrpura
              '#FF5722', // Naranja
              '#2196F3', // Azul
              '#E91E63', // Rosa
              '#FFCA28', // Amarillo
            ];

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF16251B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HabitikRadius.lg_),
              title: Row(
                children: [
                  const Text('👤', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: isDark ? Colors.white : HabitikColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ingresa tu nombre',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Inicial del Avatar (Máx. 2 letras)',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: letterCtrl,
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Ej. S',
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Color del Avatar',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: presetColors.length,
                        itemBuilder: (context, index) {
                          final colorHex = presetColors[index];
                          final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                          final isSelected = selectedColor.toUpperCase() == colorHex.toUpperCase();
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = colorHex;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? Colors.white : HabitikColors.textDark)
                                      : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName = nameCtrl.text.trim();
                    final newLetter = letterCtrl.text.trim().toUpperCase();
                    if (newName.isEmpty || newLetter.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor completa todos los campos.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final updatedProfile = user.copyWith(
                      nombre: newName,
                      avatarLetra: newLetter,
                      avatarColor: selectedColor,
                    );

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    await SessionService().saveSession(
                      token: SessionService().token!,
                      profile: updatedProfile,
                    );

                    onSaved(updatedProfile);
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado exitosamente.'),
                        backgroundColor: HabitikColors.green600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HabitikRadius.sm_),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> showInviteQRDialog(BuildContext context) async {
    try {
      final response = await ApiClient().get('/familia/invite');
      final data = jsonDecode(response.body);
      final String inviteToken = data['invite_token'] ?? '';

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) {
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
              padding: const EdgeInsets.all(20),
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
                              style: TextStyle(
                                color: isDark ? Colors.white : HabitikColors.textDark,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pide a tu familiar que escanee el código QR o comparte el enlace directo para unirse en segundos.',
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
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Recuadro del código QR de 200x200 px con borde verde esmeralda (Regla de AGENTS.md)
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: inviteToken));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Código QR copiado al portapapeles! 📋✨'),
                              backgroundColor: HabitikColors.green700,
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
                          final link = 'https://habitik.app/join?token=$inviteToken';
                          final text = '¡Únete a mi hogar en Habitik! 🏡\nUsa este enlace para unirte: $link\n\nCódigo de invitación: $inviteToken';
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Enlace de invitación copiado! 🔗✨'),
                              backgroundColor: HabitikColors.green700,
                            ),
                          );
                        },
                        icon: const Icon(Icons.link_rounded, size: 16),
                        label: const Text('Copiar Enlace'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: HabitikColors.green800,
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
                          final link = 'https://habitik.app/join?token=$inviteToken';
                          final text = '¡Únete a mi hogar en Habitik! 🏡\nUsa este enlace para unirte: $link\n\nCódigo de invitación: $inviteToken';
                          SharePlus.instance.share(ShareParams(text: text));
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: HabitikColors.textDark,
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
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
