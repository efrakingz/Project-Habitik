import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/bill_ocr_service.dart';
import 'package:habitik/core/services/bill_service.dart';
import 'package:habitik/data/models/bill_record.dart';
import 'package:habitik/features/scan/scan_screen.dart';
import 'package:habitik/features/scan/widgets/bill_form_view.dart';
import 'package:habitik/features/scan/widgets/bill_history_section.dart';
import 'package:habitik/features/scan/widgets/scan_action_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await BillService().clearAll();
  });

  group('HU 3.2 - BillRecord Model & Backend Contract', () {
    test('Serializa y deserializa contrato estructurado con metadatos de respaldo', () {
      final now = DateTime(2026, 10, 29);
      final from = DateTime(2026, 10, 1);
      final to = DateTime(2026, 10, 25);
      final due = DateTime(2026, 11, 10);

      final bill = BillRecord(
        id: 'bill_test_01',
        tipoServicio: 'Electricidad',
        proveedor: 'Enel Distribución',
        periodoDesde: from,
        periodoHasta: to,
        consumo: 185.5,
        unidad: 'kWh',
        monto: 35400,
        fechaVencimiento: due,
        entrySource: 'ocr_confirmed',
        hasDocumentBackup: true,
        documentName: 'boleta_octubre.pdf',
        documentType: 'pdf',
        documentSizeBytes: 1048576,
        createdAt: now,
      );

      final json = bill.toJson();

      final payload = bill.toBackendPayload();
      expect(payload, {
        'service_type': 'electricity',
        'provider_code': 'enel_distribucion',
        'period_start': '2026-10-01',
        'period_end': '2026-10-25',
        'consumption': 185.5,
        'amount_clp': 35400,
        'due_date': '2026-11-10',
        'entry_source': 'ocr_confirmed',
      });

      // Deserialización defensiva
      final parsed = BillRecord.fromJson(json);
      expect(parsed.id, 'bill_test_01');
      expect(parsed.tipoServicio, 'Electricidad');
      expect(parsed.isElectricidad, true);
      expect(parsed.isAgua, false);
      expect(parsed.proveedor, 'Enel Distribución');
      expect(parsed.consumo, 185.5);
      expect(parsed.monto, 35400);
      expect(parsed.hasDocumentBackup, true);
      expect(parsed.documentName, 'boleta_octubre.pdf');
    });

    test('Tolerancia defensiva ante campos en español y valores nulos', () {
      final jsonEs = {
        'id': 'bill_es',
        'tipo_servicio': 'agua',
        'proveedor': 'Aguas Andinas',
        'periodo_desde': '2026-09-01',
        'periodo_hasta': '2026-09-30',
        'consumo': '24.2',
        'unidad': 'm³',
        'monto': '19500',
        'fecha_vencimiento': '2026-10-15',
        'fuente_ingreso': 'manual',
        'tiene_respaldo': false,
      };

      final parsed = BillRecord.fromJson(jsonEs);
      expect(parsed.tipoServicio, 'Agua');
      expect(parsed.isAgua, true);
      expect(parsed.consumo, 24.2);
      expect(parsed.monto, 19500);
      expect(parsed.unidad, 'm³');
      expect(parsed.entrySource, 'manual');
      expect(parsed.hasDocumentBackup, false);
    });

    test('Lee la respuesta exacta del Backend de boletas', () {
      final parsed = BillRecord.fromJson({
        'id': 'bill-db-01',
        'service_type': 'water',
        'provider_code': 'esval',
        'period_start': '2026-09-01',
        'period_end': '2026-09-30',
        'consumption': 18.5,
        'consumption_unit': 'm3',
        'amount_clp': 16200,
        'due_date': '2026-10-15',
        'entry_source': 'manual',
        'created_at': '2026-09-30T12:00:00.000Z',
      });

      expect(parsed.tipoServicio, 'Agua');
      expect(parsed.proveedor, 'Esval');
      expect(parsed.unidad, 'm3');
      expect(parsed.monto, 16200);
    });
  });

  group('HU 3.2 - BillOcrService (Validación Documental & OCR Local)', () {
    final ocrService = BillOcrService();

    test('Rechaza archivos que exceden los 10 MB', () {
      final error = ocrService.validateFile(
        fileName: 'archivo_pesado.pdf',
        fileSizeBytes: 11 * 1024 * 1024, // 11 MB
      );
      expect(error, contains('excede el tamaño máximo permitido de 10 MB'));
    });

    test('Rechaza extensiones no permitidas', () {
      final error = ocrService.validateFile(
        fileName: 'documento.docx',
        fileSizeBytes: 500 * 1024,
      );
      expect(error, contains('Formato no compatible'));
    });

    test('Acepta formatos válidos: JPG, PNG, HEIC y PDF', () {
      expect(
        ocrService.validateFile(fileName: 'boleta.jpg', fileSizeBytes: 500),
        isNull,
      );
      expect(
        ocrService.validateFile(fileName: 'boleta.jpeg', fileSizeBytes: 500),
        isNull,
      );
      expect(
        ocrService.validateFile(fileName: 'boleta.png', fileSizeBytes: 500),
        isNull,
      );
      expect(
        ocrService.validateFile(fileName: 'boleta.heic', fileSizeBytes: 500),
        isNull,
      );
      expect(
        ocrService.validateFile(fileName: 'boleta.pdf', fileSizeBytes: 500),
        isNull,
      );
    });

    test('Extrae candidatos de Electricidad por heurística local', () async {
      final result = await ocrService.processDocument(
        fileName: 'boleta_enel_luz.pdf',
        fileSizeBytes: 800 * 1024,
      );

      expect(result.isSuccess, true);
      expect(result.candidateData, isNotNull);
      expect(result.candidateData!.tipoServicio, 'Electricidad');
      expect(result.candidateData!.unidad, 'kWh');
      expect(result.candidateData!.proveedor, 'Enel Distribución');
      expect(result.documentName, 'boleta_enel_luz.pdf');
      expect(result.documentType, 'pdf');
    });

    test('Extrae candidatos de Agua por heurística local', () async {
      final result = await ocrService.processDocument(
        fileName: 'boleta_aguas_andinas.png',
        fileSizeBytes: 450 * 1024,
      );

      expect(result.isSuccess, true);
      expect(result.candidateData, isNotNull);
      expect(result.candidateData!.tipoServicio, 'Agua');
      expect(result.candidateData!.unidad, 'm³');
      expect(result.candidateData!.proveedor, 'Aguas Andinas');
      expect(result.documentType, 'imagen');
    });

    test('Maneja documento ilegible o fallido reportando mensaje amigable', () async {
      final result = await ocrService.processDocument(
        fileName: 'boleta_borrosa_error.jpg',
        fileSizeBytes: 200 * 1024,
      );

      expect(result.isSuccess, false);
      expect(
        result.errorMessage,
        'No pudimos leer los datos automáticamente. Puedes ingresarlos de forma manual.',
      );
    });

    test('Rechaza imagen aleatoria o no reconocida como boleta (ej. cámara virtual)', () async {
      final result = await ocrService.processDocument(
        fileName: 'scaled_camera_image_123.jpg',
        fileSizeBytes: 200 * 1024,
      );

      expect(result.isSuccess, false);
      expect(
        result.errorMessage,
        contains('No se detectaron datos de una boleta válida en la imagen'),
      );
    });
  });

  group('HU 3.2 - BillService Persistence & History', () {
    test('registerBill guarda localmente y emite notificación reactiva', () async {
      final billService = BillService();
      await billService.clearAll();

      expect(billService.bills.length, 0);

      final record = BillRecord(
        id: 'bill_001',
        tipoServicio: 'Agua',
        proveedor: 'Esval',
        periodoDesde: DateTime(2026, 9, 1),
        periodoHasta: DateTime(2026, 9, 30),
        consumo: 20.0,
        unidad: 'm³',
        monto: 16000,
        fechaVencimiento: DateTime(2026, 10, 15),
        entrySource: 'manual',
        hasDocumentBackup: true,
        documentName: 'boleta_esval.pdf',
        documentType: 'pdf',
        createdAt: DateTime.now(),
      );

      await billService.registerBill(record);

      expect(billService.bills.length, 1);
      expect(billService.bills.first.id, 'bill_001');
      expect(billService.bills.first.proveedor, 'Esval');
      expect(billService.billsNotifier.value.length, 1);
    });
  });

  group('HU 3.2 - Widgets & User Experience Flow', () {
    Widget buildTestableWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      );
    }

    testWidgets('ScanActionCard despliega las 4 opciones y el aviso de privacidad',
        (tester) async {
      bool photoCalled = false;
      bool imageCalled = false;
      bool pdfCalled = false;
      bool manualCalled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ScanActionCard(
            onTakePhoto: () => photoCalled = true,
            onPickImage: () => imageCalled = true,
            onPickPdf: () => pdfCalled = true,
            onManualInput: () => manualCalled = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Escáner de Boletas'), findsOneWidget);
      expect(find.text('Tomar foto'), findsOneWidget);
      expect(find.text('Elegir imagen'), findsOneWidget);
      expect(find.text('Elegir PDF'), findsOneWidget);
      expect(find.text('Ingresar manual'), findsOneWidget);
      expect(
        find.textContaining('Tu documento se procesa solo en este dispositivo'),
        findsOneWidget,
      );

      // Prueba de interacción táctil
      await tester.tap(find.text('Tomar foto'));
      expect(photoCalled, true);

      await tester.tap(find.text('Elegir imagen'));
      expect(imageCalled, true);

      await tester.tap(find.text('Elegir PDF'));
      expect(pdfCalled, true);

      await tester.tap(find.text('Ingresar manual'));
      expect(manualCalled, true);
    });

    testWidgets(
        'CA-1: Inmediatamente después de un escaneo fallido o incorrecto, ofrece "Editar datos"',
        (tester) async {
      final billService = BillService();
      await billService.clearAll();

      final fakePicker = _FakeImagePicker(
        _FakeXFile('boleta_ilegible_fallo.jpg'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanScreen(
              billService: billService,
              imagePicker: fakePicker,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Simular captura de documento que falla en lectura automática
      await tester.tap(find.text('Tomar foto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700)); // Espera proceso OCR

      // 2. Verificar que se despliega la pantalla de error oficial
      expect(find.text('Lectura no completada'), findsOneWidget);
      expect(
        find.text(
            'No pudimos leer los datos automáticamente. Puedes ingresarlos de forma manual.'),
        findsOneWidget,
      );

      // 3. Verificar que ofrece inmediatamente la opción "Editar datos" (Criterio 1)
      final editBtn = find.byKey(const Key('scan_error_edit_data_button'));
      expect(editBtn, findsOneWidget);

      // 4. Pulsar "Editar datos" abre de inmediato el formulario editable sin bloquear
      await tester.tap(editBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tipo de Servicio'), findsOneWidget);
      expect(find.text('Revisa los datos antes de confirmar. La lectura automática puede contener errores.'),
          findsOneWidget);
      expect(find.textContaining('boleta_ilegible_fallo.jpg'), findsOneWidget);
    });

    testWidgets(
        'CA-3: Validación al ingresar datos manualmente (monto y consumo no vacíos y formato numérico > 0)',
        (tester) async {
      BillRecord? confirmedRecord;

      await tester.pumpWidget(
        buildTestableWidget(
          BillFormView(
            initialData: BillRecord.empty,
            onConfirm: (record) => confirmedRecord = record,
            onCancel: () {},
          ),
        ),
      );
      await tester.pump();

      // Intento de confirmar con campos vacíos
      final confirmBtn = find.byKey(const Key('bill_confirm_button'));
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pump();

      expect(find.text('Ingresa el valor de consumo.'), findsOneWidget);
      expect(find.text('Ingresa el monto facturado.'), findsOneWidget);
      expect(confirmedRecord, isNull);

      // Ingreso de valores inválidos (cero o negativos)
      await tester.enterText(
          find.byKey(const Key('bill_consumption_input')), '0');
      await tester.enterText(
          find.byKey(const Key('bill_amount_input')), '-500');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pump();

      expect(find.text('El consumo debe ser un número positivo.'), findsOneWidget);
      expect(find.text('El monto debe ser un entero positivo.'), findsOneWidget);
      expect(confirmedRecord, isNull);

      // Ingreso de valores válidos
      await tester.enterText(
          find.byKey(const Key('bill_consumption_input')), '190.5');
      await tester.enterText(
          find.byKey(const Key('bill_amount_input')), '36000');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pump();

      expect(confirmedRecord, isNotNull);
      expect(confirmedRecord!.consumo, 190.5);
      expect(confirmedRecord!.monto, 36000);
      expect(confirmedRecord!.tipoServicio, 'Electricidad');
    });

    testWidgets(
        'CA-3 y Alternancia de unidad: cambiar a Agua cambia unidad a m³ y lista de proveedores',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          BillFormView(
            initialData: BillRecord.empty.copyWith(tipoServicio: 'Electricidad'),
            onConfirm: (_) {},
            onCancel: () {},
          ),
        ),
      );
      await tester.pump();

      // Unidad inicial kWh visible
      expect(find.text('Consumo (kWh)'), findsOneWidget);
      expect(find.text('Enel Distribución'), findsOneWidget);

      // Alternar a Agua
      await tester.tap(find.text('💧 Agua'));
      await tester.pump();

      // Unidad cambia a m³
      expect(find.text('Consumo (m³)'), findsOneWidget);
      expect(find.text('Aguas Andinas'), findsOneWidget);
    });

    testWidgets(
        'CA-4: El documento cargado queda vinculado al registro histórico para futuras auditorías',
        (tester) async {
      final billWithDoc = BillRecord(
        id: 'bill_hist_01',
        tipoServicio: 'Electricidad',
        proveedor: 'CGE',
        periodoDesde: DateTime(2026, 9, 1),
        periodoHasta: DateTime(2026, 9, 30),
        consumo: 175.0,
        unidad: 'kWh',
        monto: 32000,
        fechaVencimiento: DateTime(2026, 10, 15),
        entrySource: 'ocr_confirmed',
        hasDocumentBackup: true,
        documentName: 'boleta_cge_sep.pdf',
        documentType: 'pdf',
        createdAt: DateTime.now(),
      );

      final billManual = BillRecord(
        id: 'bill_hist_02',
        tipoServicio: 'Agua',
        proveedor: 'Aguas Andinas',
        periodoDesde: DateTime(2026, 9, 1),
        periodoHasta: DateTime(2026, 9, 30),
        consumo: 18.0,
        unidad: 'm³',
        monto: 15400,
        fechaVencimiento: DateTime(2026, 10, 18),
        entrySource: 'manual',
        hasDocumentBackup: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          BillHistorySection(bills: [billWithDoc, billManual]),
        ),
      );
      await tester.pump();

      expect(find.text('Historial de Auditoría'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Registro con documento PDF vinculado
      expect(find.text('CGE'), findsOneWidget);
      expect(find.text('boleta_cge_sep.pdf'), findsOneWidget);
      expect(find.text('🔍 OCR Confirmado'), findsOneWidget);
      expect(find.text('📊 175.0 kWh'), findsOneWidget);

      // Registro manual sin documento
      expect(find.text('Aguas Andinas'), findsOneWidget);
      expect(find.text('Sin doc. adjunto'), findsOneWidget);
      expect(find.text('✍️ Manual'), findsOneWidget);
      expect(find.text('📊 18.0 m³'), findsOneWidget);
    });
  });
}

class _FakeImagePicker extends ImagePicker {
  final XFile file;
  _FakeImagePicker(this.file);

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    return file;
  }
}

class _FakeXFile extends XFile {
  final String _customName;
  _FakeXFile(String name)
      : _customName = name,
        super.fromData(Uint8List.fromList([1, 2, 3, 4]));

  @override
  String get name => _customName;

  @override
  Future<int> length() async => 1024;
}

