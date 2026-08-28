import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class StepMiembroJoin extends StatelessWidget {
  final bool hasCameraPermission;
  final MobileScannerController? scannerController;
  final bool isScanning;
  final TextEditingController inviteCodeCtrl;
  final VoidCallback onCheckPermission;
  final ValueChanged<String> onDetectCode;
  final VoidCallback onJoinFamily;

  const StepMiembroJoin({
    super.key,
    required this.hasCameraPermission,
    required this.scannerController,
    required this.isScanning,
    required this.inviteCodeCtrl,
    required this.onCheckPermission,
    required this.onDetectCode,
    required this.onJoinFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('👥 Unirse a un Hogar', 'Escanea el código QR de tu Jefe de Familia o ingresa el código manual'),
        const SizedBox(height: 20),

        // Visor de Cámara QR Estilo Escáner Profesional
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E15),
            borderRadius: HabitikRadius.md_,
            border: Border.all(color: HabitikColors.green600, width: 2),
            boxShadow: HabitikShadows.card,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vista de Cámara Real o Solicitud de Permiso
              if (hasCameraPermission && scannerController != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(HabitikRadius.md - 2),
                    child: MobileScanner(
                      controller: scannerController!,
                      onDetect: (capture) {
                        if (!isScanning) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final code = barcode.rawValue;
                          if (code != null && code.isNotEmpty) {
                            onDetectCode(code);
                            break;
                          }
                        }
                      },
                    ),
                  ),
                )
              else if (!hasCameraPermission)
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_off_rounded, color: Colors.white60, size: 36),
                          const SizedBox(height: 8),
                          const Text(
                            'Se requiere permiso de cámara',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: onCheckPermission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HabitikColors.green700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Permitir Cámara 📷', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(color: HabitikColors.green400),
                  ),
                ),

              // Fondo de cuadrícula decorativo simulando feed de cámara
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: GridPaper(
                    color: HabitikColors.green300,
                    divisions: 1,
                    subdivisions: 1,
                    interval: 20,
                  ),
                ),
              ),
              const Positioned(
                top: 15,
                child: Text(
                  '📷 ESCANEANDO CÓDIGO QR...',
                  style: TextStyle(color: HabitikColors.green300, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ),
              // Cuadro de enfoque del escáner
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Línea láser roja de escaneo dentro del cuadro
                    Center(
                      child: Container(
                        width: 160,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          boxShadow: [
                            BoxShadow(color: Colors.redAccent.withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 1),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .slideY(begin: -28, end: 28, duration: 1200.ms),
                    ),
                  ],
                ),
              ),
              // Leyenda decorativa
              Positioned(
                bottom: 12,
                child: Text(
                  'Coloca el código QR en el centro del cuadro',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionSubtitle('O ingresa el token manualmente:'),
        const SizedBox(height: 8),
        _textField('Ingresa token de 36 caracteres...', inviteCodeCtrl, TextInputType.text),
        const SizedBox(height: 24),

        PrimaryButton(label: 'Vincular Hogar 🔗', onTap: onJoinFamily, icon: Icons.link_rounded),
      ],
    );
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: HabitikColors.textDark, fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: HabitikColors.green500, fontSize: 12.5)),
      ],
    );
  }

  Widget _sectionSubtitle(String text) => Text(
        text,
        style: const TextStyle(color: HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.bold),
      );

  Widget _textField(String hint, TextEditingController ctrl, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}
