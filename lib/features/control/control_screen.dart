import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  String? _inviteToken;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInviteToken();
  }

  Future<void> _fetchInviteToken() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiClient().get('/familia/invite');
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          _inviteToken = data['invite_token'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Panel de Control',
          subtitulo: '👑 Jefe de Familia',
          headerActions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: HabitikColors.amber400, borderRadius: HabitikRadius.xxl_),
              child: const Text('ADMIN', style: TextStyle(color: Color(0xFF5D4037), fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                    borderRadius: HabitikRadius.lg_,
                    border: Border.all(
                      color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                      width: 2,
                    ),
                    boxShadow: HabitikShadows.card,
                  ),
                  child: Column(
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 54))
                          .animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(
                        'Administrar Familia',
                        style: TextStyle(
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gestiona las metas de ahorro mensual de luz y agua, y aprueba evidencias de retos familiares.',
                        style: TextStyle(
                          color: isDark ? HabitikColors.green200 : HabitikColors.textLight,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: HabitikColors.heroGreen,
                            borderRadius: HabitikRadius.md_,
                            boxShadow: HabitikShadows.colored(HabitikColors.green600),
                          ),
                          child: const Text(
                            '👑 Configurar Metas',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Tarjeta de invitación
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                    borderRadius: HabitikRadius.lg_,
                    border: Border.all(
                      color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                      width: 2,
                    ),
                    boxShadow: HabitikShadows.card,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('👥', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invitar Miembros',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : HabitikColors.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Comparte el código QR o código de texto con tu familia para vincularlos al hogar.',
                                  style: TextStyle(
                                    color: isDark ? HabitikColors.green200 : HabitikColors.textLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(color: HabitikColors.green600),
                        )
                      else if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                'Error al obtener código: $_errorMessage',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _fetchInviteToken,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HabitikColors.green700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: HabitikRadius.xs_),
                                ),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      else if (_inviteToken != null) ...[
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
                            data: 'https://habitik.app/join?token=$_inviteToken',
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
                          _inviteToken!,
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
                                Clipboard.setData(ClipboardData(text: _inviteToken!));
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
                                final link = 'https://habitik.app/join?token=$_inviteToken';
                                final text = '¡Únete a mi hogar en Habitik! 🏡\nUsa este enlace para unirte: $link\n\nCódigo de invitación: $_inviteToken';
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
                                final link = 'https://habitik.app/join?token=$_inviteToken';
                                final text = '¡Únete a mi hogar en Habitik! 🏡\nUsa este enlace para unirte: $link\n\nCódigo de invitación: $_inviteToken';
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
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
