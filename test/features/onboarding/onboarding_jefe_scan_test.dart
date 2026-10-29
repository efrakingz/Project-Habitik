import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/bill_ocr_service.dart';
import 'package:habitik/core/services/bill_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/features/onboarding/onboarding_screen.dart';

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

class MockImagePicker extends ImagePicker {
  XFile? photoToReturn;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    return photoToReturn;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockImagePicker mockPicker;
  late BillOcrService ocrService;
  late BillService billService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPicker = MockImagePicker();
    ocrService = BillOcrService();
    billService = BillService();
    await billService.clearAll();

    final user = UserProfile(
      id: 'jefe_01',
      email: 'jefe@habitik.test',
      nombre: 'Carlos Jefe',
      rol: 'jefe',
      familyName: 'Familia Torres',
      familyId: null,
    );
    await SessionService().saveSession(token: 'mock_jwt_token', profile: user);
    await SessionService().setOnboardingRole('jefe');
    await SessionService().setOnboardingCompleted(false);
  });

  tearDown(() {
    SocketService.disconnect();
  });

  Widget buildTestWidget({required VoidCallback onFinish}) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingScreen(
          onFinish: onFinish,
          ocrService: ocrService,
          billService: billService,
          imagePicker: mockPicker,
        ),
      ),
    );
  }

  group('Onboarding Jefe de Familia - Carga de Boletas y OCR (Luz y Agua)', () {
    testWidgets('Despliega selector de Luz y Agua, caja de escaneo y campos de consumo', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('📄 Consumo del Hogar'), findsOneWidget);
      expect(find.text('⚡ Electricidad (Luz)'), findsOneWidget);
      expect(find.text('💧 Agua Potable'), findsOneWidget);

      expect(find.text('Escanear boleta con cámara'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_scan_bill_button')), findsOneWidget);
      expect(find.byKey(const Key('onboarding_pick_gallery_button')), findsOneWidget);

      expect(find.text('Consumo estimado (kWh)'), findsOneWidget);
      expect(find.text('Monto total boleta (\$)'), findsOneWidget);
      expect(find.text('Empresa'), findsOneWidget);
      expect(find.text('Periodo'), findsOneWidget);
      expect(find.text('Nombre de tu Hogar (Familia)'), findsOneWidget);
      expect(find.text('Establecer Metas'), findsOneWidget);
    });

    testWidgets('Alternar entre Luz y Agua adapta unidades y sugerencias', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Consumo estimado (kWh)'), findsOneWidget);

      await tester.tap(find.text('💧 Agua Potable'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Consumo estimado (m³)'), findsOneWidget);
      expect(find.text('Aguas Andinas'), findsOneWidget);

      await tester.tap(find.text('⚡ Electricidad (Luz)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Consumo estimado (kWh)'), findsOneWidget);
      expect(find.text('Enel'), findsOneWidget);
    });

    testWidgets('Rechaza foto aleatoria que no es boleta y reporta mensaje amigable', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      mockPicker.photoToReturn = _FakeXFile('scaled_camera_image_random.jpg');

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('onboarding_scan_bill_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('No se detectaron datos de una boleta válida'),
        findsOneWidget,
      );

      expect(find.textContaining('Respaldo:'), findsNothing);
    });

    testWidgets('Escaneo exitoso de boleta de Luz extrae candidatos y vincula respaldo', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      mockPicker.photoToReturn = _FakeXFile('boleta_enel_luz_octubre.jpg');

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('onboarding_pick_gallery_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('185'), findsOneWidget);
      expect(find.text('34500'), findsOneWidget);
      expect(find.text('Enel Distribución'), findsOneWidget);

      expect(find.textContaining('Respaldo: boleta_enel_luz_octubre.jpg'), findsOneWidget);
      expect(find.text('Volver a escanear 📷'), findsOneWidget);
    });

    testWidgets('Escaneo exitoso de boleta de Agua conmuta automáticamente a Agua y llena datos', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      mockPicker.photoToReturn = _FakeXFile('boleta_aguas_andinas_noviembre.png');

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('onboarding_scan_bill_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Consumo estimado (m³)'), findsOneWidget);
      expect(find.text('24.5'), findsOneWidget);
      expect(find.text('19800'), findsOneWidget);
      expect(find.text('Aguas Andinas'), findsOneWidget);

      expect(find.textContaining('Respaldo: boleta_aguas_andinas_noviembre.png'), findsOneWidget);
    });

    testWidgets('Confirmar paso registra la boleta inicial con metadatos de respaldo en BillService', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      mockPicker.photoToReturn = _FakeXFile('boleta_enel_luz.jpg');

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('onboarding_scan_bill_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Ocultar snackbar para que no obstrua el botón inferior
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).hideCurrentSnackBar();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final submitBtn = find.text('Establecer Metas');
      await tester.ensureVisible(submitBtn);
      await tester.pump();
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      final registeredBills = billService.billsNotifier.value;
      expect(registeredBills.isNotEmpty, true);
      final initialBill = registeredBills.first;

      expect(initialBill.tipoServicio, 'Electricidad');
      expect(initialBill.consumo, 185.0);
      expect(initialBill.monto, 34500);
      expect(initialBill.hasDocumentBackup, true);
      expect(initialBill.documentName, 'boleta_enel_luz.jpg');
      expect(initialBill.entrySource, 'ocr_confirmed');
    });

    testWidgets('Permite limpiar el respaldo documental antes de confirmar', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      mockPicker.photoToReturn = _FakeXFile('boleta_enel_luz.jpg');

      await tester.pumpWidget(buildTestWidget(onFinish: () {}));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const Key('onboarding_scan_bill_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('onboarding_clear_document_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding_clear_document_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Respaldo:'), findsNothing);
      expect(find.text('Escanear 📷'), findsOneWidget);
    });
  });
}
