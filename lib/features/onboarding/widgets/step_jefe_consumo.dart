import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class StepJefeConsumo extends StatelessWidget {
  final String tipoBoleta; // 'luz' | 'agua'
  final ValueChanged<String> onTipoBoletaChanged;
  final bool isOcrReading;
  final VoidCallback onScanBill;
  final VoidCallback? onPickGallery;
  final TextEditingController consumoCtrl;
  final TextEditingController montoCtrl;
  final TextEditingController empresaCtrl;
  final TextEditingController periodoCtrl;
  final TextEditingController familyNameCtrl;
  final VoidCallback onSubmit;
  final String? documentBackupName;
  final VoidCallback? onClearDocument;

  const StepJefeConsumo({
    super.key,
    required this.tipoBoleta,
    required this.onTipoBoletaChanged,
    required this.isOcrReading,
    required this.onScanBill,
    this.onPickGallery,
    required this.consumoCtrl,
    required this.montoCtrl,
    required this.empresaCtrl,
    required this.periodoCtrl,
    required this.familyNameCtrl,
    required this.onSubmit,
    this.documentBackupName,
    this.onClearDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('📄 Consumo del Hogar', 'Ingresa una boleta para establecer las metas de ahorro'),
        const SizedBox(height: 20),

        // Selector Tipo Boleta
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('⚡ Electricidad (Luz)'),
                selected: tipoBoleta == 'luz',
                onSelected: (val) => onTipoBoletaChanged('luz'),
                selectedColor: HabitikColors.green100,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tipoBoleta == 'luz' ? HabitikColors.green900 : HabitikColors.textMid,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('💧 Agua Potable'),
                selected: tipoBoleta == 'agua',
                onSelected: (val) => onTipoBoletaChanged('agua'),
                selectedColor: const Color(0xFFE0F2FE),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tipoBoleta == 'agua' ? const Color(0xFF0369A1) : HabitikColors.textMid,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Lector OCR con IA Local
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: HabitikColors.green50,
            borderRadius: HabitikRadius.md_,
            border: Border.all(color: HabitikColors.divider),
          ),
          child: Column(
            children: [
              if (isOcrReading) ...[
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(color: HabitikColors.green700, strokeWidth: 3.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Leyendo boleta con IA local... Por favor espera...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: HabitikColors.textDark, fontSize: 13),
                ),
              ] else ...[
                const Text('📷', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                const Text(
                  'Escanear boleta con cámara',
                  style: TextStyle(fontWeight: FontWeight.bold, color: HabitikColors.textDark, fontSize: 13),
                ),
                const Text(
                  'Extrae consumo y monto automáticamente',
                  style: TextStyle(color: HabitikColors.textLight, fontSize: 11),
                ),
                const SizedBox(height: 12),

                // Respaldo de documento si ya fue cargado
                if (documentBackupName != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: HabitikColors.green100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: HabitikColors.green500.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: HabitikColors.green700, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Respaldo: $documentBackupName',
                            style: const TextStyle(
                              color: HabitikColors.green900,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onClearDocument != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            key: const Key('onboarding_clear_document_button'),
                            onTap: onClearDocument,
                            child: const Icon(Icons.close_rounded, size: 16, color: HabitikColors.textMid),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                GestureDetector(
                  key: const Key('onboarding_scan_bill_button'),
                  onTap: onScanBill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: HabitikColors.green700,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: HabitikShadows.card,
                    ),
                    child: Text(
                      documentBackupName != null ? 'Volver a escanear 📷' : 'Escanear 📷',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                if (onPickGallery != null) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    key: const Key('onboarding_pick_gallery_button'),
                    onPressed: onPickGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 14, color: HabitikColors.green700),
                    label: const Text(
                      'O seleccionar de la galería',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: HabitikColors.green700,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionSubtitle('O ingresar datos manualmente:'),
        const SizedBox(height: 12),

        _label('Consumo estimado (${tipoBoleta == 'luz' ? 'kWh' : 'm³'})'),
        _textField('Ej: ${tipoBoleta == 'luz' ? '140' : '15'}', consumoCtrl, TextInputType.number),
        const SizedBox(height: 12),

        _label('Monto total boleta (\$)'),
        _textField('Ej: 25000', montoCtrl, TextInputType.number),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Empresa'),
                  _textField(tipoBoleta == 'luz' ? 'Ej: Enel' : 'Ej: Aguas Andinas', empresaCtrl, TextInputType.text),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Periodo'),
                  _textField('Ej: Junio', periodoCtrl, TextInputType.text),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _label('Nombre de tu Hogar (Familia)'),
        _textField('Ej: Familia Torres', familyNameCtrl, TextInputType.text),
        const SizedBox(height: 28),

        PrimaryButton(label: 'Establecer Metas', onTap: onSubmit, icon: Icons.analytics_outlined),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(color: HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.w600),
        ),
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
