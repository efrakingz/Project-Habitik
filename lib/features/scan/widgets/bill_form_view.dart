import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/bill_record.dart';
import 'package:habitik/shared/widgets/feedback/habitik_feedback.dart';

/// Formulario editable de revisión y corrección de boleta (HU 3.2).
/// Valida campos obligatorios, formatos numéricos y coherencia de fechas.
class BillFormView extends StatefulWidget {
  final BillRecord initialData;
  final String? documentName;
  final String? documentType;
  final int? documentSizeBytes;
  final bool isSubmitting;
  final ValueChanged<BillRecord> onConfirm;
  final VoidCallback onCancel;

  const BillFormView({
    super.key,
    required this.initialData,
    this.documentName,
    this.documentType,
    this.documentSizeBytes,
    this.isSubmitting = false,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<BillFormView> createState() => _BillFormViewState();
}

class _BillFormViewState extends State<BillFormView> {
  final _formKey = GlobalKey<FormState>();

  late String _tipoServicio;
  late String _proveedor;
  late DateTime _periodoDesde;
  late DateTime _periodoHasta;
  late DateTime _fechaVencimiento;

  late final TextEditingController _consumoController;
  late final TextEditingController _montoController;

  static const List<String> _proveedoresLuz = [
    'Enel Distribución',
    'CGE',
    'Chilquinta Energía',
    'Saesa',
    'Frontel',
    'Colbún',
    'Edelaysen',
    'Otro (Luz)',
  ];

  static const List<String> _proveedoresAgua = [
    'Aguas Andinas',
    'Essbio',
    'Esval',
    'Aguas del Valle',
    'Smapa',
    'Aguas Nuevas',
    'Aguas Antofagasta',
    'Otro (Agua)',
  ];

  @override
  void initState() {
    super.initState();
    _tipoServicio = widget.initialData.tipoServicio;
    _proveedor = widget.initialData.proveedor.isNotEmpty
        ? widget.initialData.proveedor
        : (_tipoServicio == 'Agua' ? _proveedoresAgua.first : _proveedoresLuz.first);

    // Ajusta proveedor si no está en la lista correspondiente
    final currentList = _currentProviderList();
    if (!currentList.contains(_proveedor)) {
      _proveedor = currentList.first;
    }

    final now = DateTime.now();
    _periodoDesde = widget.initialData.periodoDesde.millisecondsSinceEpoch > 0
        ? widget.initialData.periodoDesde
        : DateTime(now.year, now.month - 1, 1);

    _periodoHasta = widget.initialData.periodoHasta.millisecondsSinceEpoch > 0
        ? widget.initialData.periodoHasta
        : DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));

    _fechaVencimiento =
        widget.initialData.fechaVencimiento.millisecondsSinceEpoch > 0
            ? widget.initialData.fechaVencimiento
            : now.add(const Duration(days: 10));

    _consumoController = TextEditingController(
      text: widget.initialData.consumo > 0
          ? widget.initialData.consumo.toString()
          : '',
    );

    _montoController = TextEditingController(
      text: widget.initialData.monto > 0
          ? widget.initialData.monto.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _consumoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  List<String> _currentProviderList() {
    return _tipoServicio == 'Agua' ? _proveedoresAgua : _proveedoresLuz;
  }

  String get _currentUnit => _tipoServicio == 'Agua' ? 'm³' : 'kWh';

  void _onServiceTypeChanged(String newType) {
    if (_tipoServicio == newType) return;
    setState(() {
      _tipoServicio = newType;
      _proveedor = _currentProviderList().first;
    });
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark ||
            isDarkModeNotifier.value;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: HabitikColors.green500,
                    onPrimary: Colors.black,
                    surface: HabitikColors.darkCardBg,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: HabitikColors.green700,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: HabitikColors.textDark,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_periodoHasta.isBefore(_periodoDesde)) {
      HabitikFeedback.showError(
        context,
        'La fecha de término debe ser posterior a la de inicio.',
      );
      return;
    }

    final consumoVal = double.tryParse(_consumoController.text.trim()) ?? 0.0;
    final montoVal = int.tryParse(_montoController.text.trim()) ?? 0;

    final record = BillRecord(
      id: widget.initialData.id.isNotEmpty
          ? widget.initialData.id
          : 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tipoServicio: _tipoServicio,
      proveedor: _proveedor,
      periodoDesde: _periodoDesde,
      periodoHasta: _periodoHasta,
      consumo: consumoVal,
      unidad: _currentUnit,
      monto: montoVal,
      fechaVencimiento: _fechaVencimiento,
      entrySource: widget.initialData.entrySource,
      hasDocumentBackup: widget.documentName != null &&
          widget.documentName!.isNotEmpty,
      documentName: widget.documentName,
      documentType: widget.documentType,
      documentSizeBytes: widget.documentSizeBytes,
      createdAt: DateTime.now(),
    );

    widget.onConfirm(record);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        color: isDark ? HabitikColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : HabitikColors.green200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : HabitikColors.green900.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de advertencia OCR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262111)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF856404).withValues(alpha: 0.4)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Revisa los datos antes de confirmar. La lectura automática puede contener errores.',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Badge de documento vinculado
            if (widget.documentName != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? HabitikColors.darkInputFill
                      : HabitikColors.green50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? HabitikColors.green500.withValues(alpha: 0.3)
                        : HabitikColors.green300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.documentType == 'pdf'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.image_rounded,
                      size: 18,
                      color: widget.documentType == 'pdf'
                          ? Colors.redAccent
                          : HabitikColors.blue500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Respaldo: ${widget.documentName} ${widget.documentSizeBytes != null ? "(${(widget.documentSizeBytes! / 1024).round()} KB)" : ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : HabitikColors.green900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HabitikColors.green700.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Local',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: HabitikColors.green500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Selector Tipo de Servicio (Electricidad / Agua)
            Text(
              'Tipo de Servicio',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ServiceTypeOption(
                    label: '⚡ Electricidad',
                    selected: _tipoServicio == 'Electricidad',
                    onTap: () => _onServiceTypeChanged('Electricidad'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ServiceTypeOption(
                    label: '💧 Agua',
                    selected: _tipoServicio == 'Agua',
                    onTap: () => _onServiceTypeChanged('Agua'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Proveedor
            Text(
              'Proveedor del Servicio',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: const Key('bill_provider_dropdown'),
              initialValue: _currentProviderList().contains(_proveedor)
                  ? _proveedor
                  : _currentProviderList().first,
              dropdownColor: isDark ? HabitikColors.darkCardBg : Colors.white,
              decoration: _inputDecoration(isDark),
              items: _currentProviderList()
                  .map((prov) => DropdownMenuItem(
                        value: prov,
                        child: Text(
                          prov,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : HabitikColors.textDark,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _proveedor = val);
              },
            ),
            const SizedBox(height: 16),

            // 3. Período Desde / Hasta
            Text(
              'Período Facturado',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateSelectorTile(
                    label: 'Desde',
                    dateText: dateFormat.format(_periodoDesde),
                    onTap: () => _pickDate(
                      context: context,
                      initialDate: _periodoDesde,
                      onPicked: (d) => _periodoDesde = d,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateSelectorTile(
                    label: 'Hasta',
                    dateText: dateFormat.format(_periodoHasta),
                    onTap: () => _pickDate(
                      context: context,
                      initialDate: _periodoHasta,
                      onPicked: (d) => _periodoHasta = d,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Consumo (con unidad visible no editable)
            Text(
              'Consumo ($_currentUnit)',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('bill_consumption_input'),
              controller: _consumoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
              decoration: _inputDecoration(isDark).copyWith(
                hintText: 'Ej. 185.0',
                suffixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    _currentUnit,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? HabitikColors.green400 : HabitikColors.green700,
                    ),
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Ingresa el valor de consumo.';
                }
                final numVal = double.tryParse(val.trim());
                if (numVal == null || numVal <= 0) {
                  return 'El consumo debe ser un número positivo.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 5. Monto Total (CLP)
            Text(
              'Monto Total a Pagar (CLP)',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('bill_amount_input'),
              controller: _montoController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
              decoration: _inputDecoration(isDark).copyWith(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    r'$',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                suffixText: 'CLP',
                hintText: 'Ej. 34500',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Ingresa el monto facturado.';
                }
                final intVal = int.tryParse(val.trim());
                if (intVal == null || intVal <= 0) {
                  return 'El monto debe ser un entero positivo.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 6. Fecha de Vencimiento
            Text(
              'Fecha de Vencimiento',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : HabitikColors.textMid,
              ),
            ),
            const SizedBox(height: 8),
            _DateSelectorTile(
              label: 'Vence el',
              dateText: dateFormat.format(_fechaVencimiento),
              onTap: () => _pickDate(
                context: context,
                initialDate: _fechaVencimiento,
                onPicked: (d) => _fechaVencimiento = d,
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción final
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    key: const Key('bill_confirm_button'),
                    onPressed: widget.isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HabitikColors.green700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: widget.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Confirmar registro',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    key: const Key('bill_cancel_button'),
                    onPressed: widget.isSubmitting ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : HabitikColors.divider,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : HabitikColors.textMid,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? HabitikColors.darkInputFill : HabitikColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : HabitikColors.divider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : HabitikColors.divider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: HabitikColors.green500,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
    );
  }
}

class _ServiceTypeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceTypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark
                    ? HabitikColors.green800
                    : HabitikColors.green50)
                : (isDark
                    ? HabitikColors.darkInputFill
                    : HabitikColors.surface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? HabitikColors.green500
                  : (isDark ? Colors.white12 : HabitikColors.divider),
              width: selected ? 1.8 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? (isDark ? Colors.white : HabitikColors.green900)
                  : (isDark ? Colors.white60 : HabitikColors.textMid),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  final String label;
  final String dateText;
  final VoidCallback onTap;

  const _DateSelectorTile({
    required this.label,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? HabitikColors.darkInputFill : HabitikColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : HabitikColors.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: isDark ? HabitikColors.green400 : HabitikColors.green700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : HabitikColors.textLight,
                      ),
                    ),
                    Text(
                      dateText,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : HabitikColors.textDark,
                      ),
                    ),
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
