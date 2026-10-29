import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:habitik/core/services/bill_ocr_service.dart';
import 'package:habitik/core/services/bill_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/bill_record.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'widgets/bill_form_view.dart';
import 'widgets/bill_history_section.dart';
import 'widgets/scan_action_card.dart';

enum ScanStep {
  initial,
  reading,
  error,
  form,
}

/// Pantalla principal para HU 3.2: Carga Manual y Respaldo Documental (PDF/Imagen).
/// Permite capturar boletas (cámara, galería o PDF), lectura local OCR,
/// corrección manual inmediata ante escaneo fallido y vinculación documental al historial de auditoría.
class ScanScreen extends StatefulWidget {
  final BillOcrService? ocrService;
  final BillService? billService;
  final ImagePicker? imagePicker;

  const ScanScreen({
    super.key,
    this.ocrService,
    this.billService,
    this.imagePicker,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final BillOcrService _ocrService;
  late final BillService _billService;
  late final ImagePicker _imagePicker;

  ScanStep _currentStep = ScanStep.initial;
  String? _errorMessage;
  String? _selectedDocumentName;
  String? _selectedDocumentType;
  int? _selectedDocumentSize;
  String? _tempFilePath;
  String _lastCaptureSource = 'camera'; // 'camera' | 'gallery' | 'pdf' | 'manual'

  BillRecord _currentBillDraft = BillRecord.empty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ocrService = widget.ocrService ?? BillOcrService();
    _billService = widget.billService ?? BillService();
    _imagePicker = widget.imagePicker ?? ImagePicker();
    _billService.init();
  }

  /// 1. Tomar foto con la cámara del dispositivo
  Future<void> _handleTakePhoto() async {
    _lastCaptureSource = 'camera';
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;

      final length = await photo.length();
      await _processFile(
        fileName: photo.name.isNotEmpty ? photo.name : 'captura_camara.jpg',
        fileSizeBytes: length,
        tempPath: photo.path,
      );
    } catch (e) {
      debugPrint('⚠️ [ScanScreen] Error al capturar foto: $e');
      if (mounted) {
        HabitikFeedback.showError(
          context,
          'No se pudo acceder a la cámara. Revisa los permisos de la app.',
        );
      }
    }
  }

  /// 2. Elegir imagen desde la galería (JPG, PNG, HEIC)
  Future<void> _handlePickImage() async {
    _lastCaptureSource = 'gallery';
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      final length = await image.length();
      await _processFile(
        fileName: image.name.isNotEmpty ? image.name : 'imagen_galeria.png',
        fileSizeBytes: length,
        tempPath: image.path,
      );
    } catch (e) {
      debugPrint('⚠️ [ScanScreen] Error al elegir imagen: $e');
      if (mounted) {
        HabitikFeedback.showError(
          context,
          'No se pudo seleccionar la imagen de la galería.',
        );
      }
    }
  }

  /// 3. Elegir archivo PDF del almacenamiento
  Future<void> _handlePickPdf() async {
    _lastCaptureSource = 'pdf';
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) return;
      final file = files.first;

      final length = await file.xFile.length();
      await _processFile(
        fileName: file.name,
        fileSizeBytes: length,
        tempPath: file.path,
      );
    } catch (e) {
      debugPrint('⚠️ [ScanScreen] Error al elegir PDF: $e');
      if (mounted) {
        HabitikFeedback.showError(
          context,
          'No se pudo abrir el selector de documentos PDF.',
        );
      }
    }
  }

  /// 4. Entrada directa manual sin archivo adjunto
  void _handleManualInput() {
    _lastCaptureSource = 'manual';
    setState(() {
      _selectedDocumentName = null;
      _selectedDocumentType = null;
      _selectedDocumentSize = null;
      _tempFilePath = null;
      _currentBillDraft = BillRecord.empty.copyWith(
        entrySource: 'manual',
        hasDocumentBackup: false,
      );
      _currentStep = ScanStep.form;
    });
  }

  /// Procesa el documento seleccionado, validando tamaño, formato y ejecutando OCR local
  Future<void> _processFile({
    required String fileName,
    required int fileSizeBytes,
    String? tempPath,
  }) async {
    // Validación previa inmediata
    final validationError = _ocrService.validateFile(
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
    );

    if (validationError != null) {
      if (mounted) HabitikFeedback.showError(context, validationError);
      return;
    }

    setState(() {
      _currentStep = ScanStep.reading;
      _tempFilePath = tempPath;
    });

    final result = await _ocrService.processDocument(
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      filePath: tempPath,
    );

    if (!mounted) return;

    if (result.isSuccess && result.candidateData != null) {
      final cand = result.candidateData!;
      setState(() {
        _selectedDocumentName = result.documentName;
        _selectedDocumentType = result.documentType;
        _selectedDocumentSize = result.documentSizeBytes;
        _currentBillDraft = BillRecord(
          id: '',
          tipoServicio: cand.tipoServicio,
          proveedor: cand.proveedor,
          periodoDesde: cand.periodoDesde,
          periodoHasta: cand.periodoHasta,
          consumo: cand.consumo,
          unidad: cand.unidad,
          monto: cand.monto,
          fechaVencimiento: cand.fechaVencimiento,
          entrySource: 'ocr_confirmed',
          hasDocumentBackup: true,
          documentName: result.documentName,
          documentType: result.documentType,
          documentSizeBytes: result.documentSizeBytes,
          createdAt: DateTime.now(),
        );
        _currentStep = ScanStep.form;
      });
    } else {
      // Escaneo fallido o ilegible (Criterio 1: ofrecer "Editar datos" inmediatamente)
      setState(() {
        _selectedDocumentName = result.documentName;
        _selectedDocumentType = result.documentType;
        _selectedDocumentSize = result.documentSizeBytes;
        _errorMessage = result.errorMessage ??
            'No pudimos leer los datos automáticamente. Puedes ingresarlos de forma manual.';
        _currentStep = ScanStep.error;
      });
    }
  }

  /// Abre el formulario tras un escaneo fallido o para corrección directa (Criterio 1)
  void _onEditAfterFailure() {
    setState(() {
      _currentBillDraft = BillRecord.empty.copyWith(
        entrySource: 'manual',
        hasDocumentBackup: _selectedDocumentName != null,
        documentName: _selectedDocumentName,
        documentType: _selectedDocumentType,
        documentSizeBytes: _selectedDocumentSize,
      );
      _currentStep = ScanStep.form;
    });
  }

  /// Cancela el flujo y limpia archivos temporales
  Future<void> _handleCancel() async {
    await _ocrService.cleanupTempFiles(specificPath: _tempFilePath);
    if (!mounted) return;
    setState(() {
      _currentStep = ScanStep.initial;
      _selectedDocumentName = null;
      _selectedDocumentType = null;
      _selectedDocumentSize = null;
      _tempFilePath = null;
      _currentBillDraft = BillRecord.empty;
      _errorMessage = null;
    });
  }

  /// Confirma y registra el consumo en el historial de auditoría
  Future<void> _handleConfirmBill(BillRecord bill) async {
    setState(() => _isSubmitting = true);
    try {
      await _billService.registerBill(bill);
      await _ocrService.cleanupTempFiles(specificPath: _tempFilePath);

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _currentStep = ScanStep.initial;
        _selectedDocumentName = null;
        _selectedDocumentType = null;
        _selectedDocumentSize = null;
        _tempFilePath = null;
        _currentBillDraft = BillRecord.empty;
      });

      HabitikFeedback.showSuccess(
        context,
        'Consumo registrado correctamente',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      HabitikFeedback.showError(context, 'Error al guardar registro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titulo: 'Scan de Boletas',
      subtitulo: '📄 Auditoría de Consumo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            // Paso 1: Inicial (Tarjeta de opciones + Historial de Auditoría)
            if (_currentStep == ScanStep.initial) ...[
              ScanActionCard(
                onTakePhoto: _handleTakePhoto,
                onPickImage: _handlePickImage,
                onPickPdf: _handlePickPdf,
                onManualInput: _handleManualInput,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<List<BillRecord>>(
                valueListenable: _billService.billsNotifier,
                builder: (context, bills, _) {
                  return BillHistorySection(bills: bills);
                },
              ),
            ],

            // Paso 2: Lectura en progreso (Indicador + Mensaje oficial)
            if (_currentStep == ScanStep.reading)
              _buildReadingStateCard(),

            // Paso 3: Escaneo fallido / ilegible (Criterio 1: botón "Editar datos")
            if (_currentStep == ScanStep.error)
              _buildErrorStateCard(),

            // Paso 4: Formulario de revisión y corrección
            if (_currentStep == ScanStep.form)
              BillFormView(
                initialData: _currentBillDraft,
                documentName: _selectedDocumentName,
                documentType: _selectedDocumentType,
                documentSizeBytes: _selectedDocumentSize,
                isSubmitting: _isSubmitting,
                onConfirm: _handleConfirmBill,
                onCancel: _handleCancel,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingStateCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? HabitikColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white12 : HabitikColors.green200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: HabitikColors.green500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Leyendo los datos de tu boleta…',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : HabitikColors.green900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Esto puede tardar unos segundos.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : HabitikColors.textMid,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _handleCancel,
            child: Text(
              'Cancelar lectura',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : HabitikColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStateCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? HabitikColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : const Color(0xFFFCA5A5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF4444),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lectura no completada',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : HabitikColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ??
                'No se detectaron datos de una boleta válida en la imagen. Puedes volver a tomar la foto o ingresarlos de forma manual.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : HabitikColors.textMid,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),

          // Botón primordial: "Editar datos" (Criterio 1)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('scan_error_edit_data_button'),
              onPressed: _onEditAfterFailure,
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: Text(
                'Editar datos',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: HabitikColors.green700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Botón para reintentar captura (cámara, galería o pdf según origen)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('scan_error_retake_button'),
              onPressed: () {
                if (_lastCaptureSource == 'camera') {
                  _handleTakePhoto();
                } else if (_lastCaptureSource == 'gallery') {
                  _handlePickImage();
                } else {
                  _handlePickPdf();
                }
              },
              icon: Icon(
                _lastCaptureSource == 'camera'
                    ? Icons.camera_alt_outlined
                    : _lastCaptureSource == 'gallery'
                        ? Icons.photo_library_outlined
                        : Icons.picture_as_pdf_outlined,
                size: 20,
              ),
              label: Text(
                _lastCaptureSource == 'camera'
                    ? 'Volver a tomar foto'
                    : _lastCaptureSource == 'gallery'
                        ? 'Elegir otra imagen'
                        : 'Elegir otro PDF',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : HabitikColors.green800,
                side: BorderSide(
                  color: isDark ? Colors.white24 : HabitikColors.green500,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Opción para cancelar y volver al inicio
          TextButton(
            key: const Key('scan_error_retry_button'),
            onPressed: _handleCancel,
            child: Text(
              'Cancelar y volver al inicio',
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : HabitikColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
