import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habitik/core/services/bill_ocr_service.dart';
import 'package:habitik/core/services/bill_service.dart';
import 'package:habitik/data/models/bill_record.dart';

import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/shared/widgets/feedback/habitik_feedback.dart';
import 'package:habitik/shared/widgets/layout/loading_overlay.dart';

import 'widgets/onboarding_progress_header.dart';
import 'widgets/step_jefe_consumo.dart';
import 'widgets/step_jefe_infraestructura.dart';
import 'widgets/step_jefe_final.dart';
import 'widgets/step_miembro_join.dart';
import 'widgets/step_miembro_habitos.dart';
import 'widgets/step_miembro_final.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  final BillOcrService? ocrService;
  final BillService? billService;
  final ImagePicker? imagePicker;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
    this.ocrService,
    this.billService,
    this.imagePicker,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  late String _rol; // 'jefe' o 'miembro'
  bool _loading = false;
  String _loadingMessage = "";
  Map<String, dynamic>? _mapaGastoEstimado;

  // Datos Jefe: Boleta / Consumo
  String _tipoBoleta = 'luz'; // 'luz' o 'agua'
  final _familyNameCtrl = TextEditingController(text: 'Mi Hogar');
  final _consumoCtrl = TextEditingController(text: '140');
  final _montoCtrl = TextEditingController(text: '21000');
  final _empresaCtrl = TextEditingController(text: 'Enel');
  final _periodoCtrl = TextEditingController(text: 'Junio');

  bool _isOcrReading = false;
  String? _inviteToken;
  bool _qrError = false;

  late final BillOcrService _ocrService;
  late final BillService _billService;
  late final ImagePicker _imagePicker;

  String? _documentBackupName;
  String? _documentBackupType;
  int? _documentBackupSize;
  String? _documentTempPath;
  bool _hasDocumentBackup = false;

  // Datos Jefe: Cuestionario del Hogar
  int _personasCount = 4;
  int _habitacionesCount = 3;
  String _tipoCalefaccion = 'electrica';
  final List<String> _electrodomesticos = ['lavadora', 'secadora'];

  // Datos Miembro: Unirse a Hogar & Hábitos
  final _inviteCodeCtrl = TextEditingController();
  String _tiempoDucha = '5-10 min';
  String _lucesEncendidas = '3-6 horas';
  String _reciclaje = 'A veces';

  bool _hasCameraPermission = false;
  bool _isScanning = true;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _ocrService = widget.ocrService ?? BillOcrService();
    _billService = widget.billService ?? BillService();
    _imagePicker = widget.imagePicker ?? ImagePicker();
    _billService.init();
    _rol = SessionService().getOnboardingRole();
    if (_rol == 'miembro') {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        formats: const [BarcodeFormat.qrCode],
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPermission();
      });
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasCameraPermission = status.isGranted;
      });
    }
  }

  @override
  void dispose() {
    _familyNameCtrl.dispose();
    _consumoCtrl.dispose();
    _montoCtrl.dispose();
    _empresaCtrl.dispose();
    _periodoCtrl.dispose();
    _inviteCodeCtrl.dispose();
    _scannerController?.dispose();
    _ocrService.cleanupTempFiles(specificPath: _documentTempPath);
    super.dispose();
  }

  int get _totalSteps => 3;

  Future<void> _next() async {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      if (_rol == 'jefe' && _step == 2) {
        await _generateInviteToken();
      }
    } else {
      await SessionService().setOnboardingCompleted(true);
      widget.onFinish();
    }
  }

  void _prev() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Future<void> _generateInviteToken() async {
    setState(() {
      _qrError = false;
      _loading = true;
      _loadingMessage = "Generando código de invitación...";
    });
    try {
      final response = await ApiClient().get('/familia/invite');
      final data = jsonDecode(response.body);
      setState(() {
        _inviteToken = data['invite_token'];
        _qrError = false;
      });
    } catch (e) {
      setState(() {
        _qrError = true;
      });
      _showError('No se pudo generar el token de invitación: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleScanBill({ImageSource source = ImageSource.camera}) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (photo == null) return;

      setState(() => _isOcrReading = true);

      int length = 0;
      Uint8List? bytes;
      try {
        length = await photo.length();
        bytes = await photo.readAsBytes();
      } catch (_) {
        length = 1024;
      }
      final result = await _ocrService.processDocument(
        fileName: photo.name.isNotEmpty ? photo.name : 'captura_camara.jpg',
        fileSizeBytes: length,
        filePath: photo.path,
        fileBytes: bytes,
        preferredServiceType: _tipoBoleta == 'agua' ? 'Agua' : 'Electricidad',
      );

      if (!mounted) return;
      setState(() => _isOcrReading = false);

      if (!result.isSuccess) {
        _showError(
          result.errorMessage ??
              'No se detectaron datos de una boleta válida en la imagen. Asegúrate de enfocar bien la boleta o ingresa los datos de forma manual.',
        );
        return;
      }

      final candidate = result.candidateData;
      if (candidate == null) {
        _showError('No se pudieron extraer datos de la boleta. Puedes ingresarlos de forma manual.');
        return;
      }

      final isElectricidad = candidate.tipoServicio.toLowerCase().contains('elec') ||
          candidate.unidad.toLowerCase().contains('kwh');
      final isAgua = candidate.tipoServicio.toLowerCase().contains('agua') ||
          candidate.unidad.toLowerCase().contains('m');

      setState(() {
        if (isAgua) {
          _tipoBoleta = 'agua';
        } else if (isElectricidad) {
          _tipoBoleta = 'luz';
        }

        final consumoFormatted = candidate.consumo > 0
            ? (candidate.consumo.truncateToDouble() == candidate.consumo
                ? candidate.consumo.toInt().toString()
                : candidate.consumo.toString())
            : '';
        _consumoCtrl.text = consumoFormatted;
        _montoCtrl.text = candidate.monto > 0 ? candidate.monto.toString() : '';
        _empresaCtrl.text = candidate.proveedor;
        _periodoCtrl.text = _formatPeriod(candidate.periodoDesde);

        _documentBackupName = result.documentName ?? photo.name;
        _documentBackupType = result.documentType ?? 'imagen';
        _documentBackupSize = result.documentSizeBytes ?? length;
        _documentTempPath = photo.path;
        _hasDocumentBackup = true;
      });

      _showSuccess(
        '¡Boleta de ${candidate.tipoServicio} leída con éxito! Revisa los datos antes de continuar.',
      );
    } catch (e) {
      debugPrint('⚠️ [Onboarding] Error al procesar escaneo: $e');
      if (mounted) {
        setState(() => _isOcrReading = false);
        _showError('Error al procesar la cámara o imagen: $e');
      }
    }
  }

  void _clearDocumentBackup() {
    _ocrService.cleanupTempFiles(specificPath: _documentTempPath);
    setState(() {
      _documentBackupName = null;
      _documentBackupType = null;
      _documentBackupSize = null;
      _documentTempPath = null;
      _hasDocumentBackup = false;
    });
  }

  String _formatPeriod(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    if (date.month >= 1 && date.month <= 12) {
      return months[date.month - 1];
    }
    return 'Mes actual';
  }

  void _submitJefeConsumoStep() async {
    final consumo = double.tryParse(_consumoCtrl.text) ?? 0.0;
    final monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    final familyName = _familyNameCtrl.text.trim();

    if (consumo <= 0 || monto <= 0) {
      _showError('Por favor ingresa consumo y monto válidos.');
      return;
    }
    if (familyName.isEmpty) {
      _showError('Por favor ingresa el nombre de tu hogar.');
      return;
    }

    setState(() {
      _loading = true;
      _loadingMessage = "Configurando el nombre del hogar...";
    });

    try {
      try {
        await ApiClient().patch('/familia/nombre', {'nombre': familyName});
      } catch (netErr) {
        debugPrint('ℹ️ [Onboarding] Backend offline al actualizar nombre de familia: $netErr');
      }

      // Registrar boleta inicial vinculada al Jefe de Familia (POST /bills y local)
      final now = DateTime.now();
      final billRecord = BillRecord(
        id: 'bill_init_${now.millisecondsSinceEpoch}',
        tipoServicio: _tipoBoleta == 'luz' ? 'Electricidad' : 'Agua',
        proveedor: _empresaCtrl.text.trim().isNotEmpty
            ? _empresaCtrl.text.trim()
            : (_tipoBoleta == 'luz' ? 'Enel Distribución' : 'Aguas Andinas'),
        periodoDesde: DateTime(now.year, now.month - 1, 1),
        periodoHasta: DateTime(now.year, now.month, 1).subtract(const Duration(days: 1)),
        consumo: consumo,
        unidad: _tipoBoleta == 'luz' ? 'kWh' : 'm³',
        monto: monto.toInt(),
        fechaVencimiento: now.add(const Duration(days: 15)),
        entrySource: _hasDocumentBackup ? 'ocr_confirmed' : 'manual',
        hasDocumentBackup: _hasDocumentBackup,
        documentName: _documentBackupName,
        documentType: _documentBackupType,
        documentSizeBytes: _documentBackupSize,
        createdAt: now,
      );

      try {
        await _billService.registerBill(billRecord);
      } catch (billError) {
        debugPrint('ℹ️ [Onboarding] Registro local de boleta preservado ante backend offline: $billError');
      }

      final user = SessionService().currentUser;
      if (user != null) {
        final updated = user.copyWith(familyName: familyName);
        await SessionService().saveSession(token: SessionService().token ?? '', profile: updated);
      }

      _next();
    } catch (e) {
      _showError('Error al guardar el nombre del hogar: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitJefeOnboarding() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _loadingMessage = "Calculando consumo baseline del hogar...";
    });

    try {
      final response = await ApiClient().post('/onboarding', {
        'personasCount': _personasCount,
        'habitacionesCount': _habitacionesCount,
        'tipoCalefaccion': _tipoCalefaccion,
        'electrodomesticos': _electrodomesticos
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('mapa_gasto_estimado')) {
          _mapaGastoEstimado = data['mapa_gasto_estimado'];
        }
      }

      if (!mounted) return;
      await _next();
    } catch (e) {
      if (!mounted) return;
      _showError('Error al guardar onboarding: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _joinFamily() async {
    FocusScope.of(context).unfocus();
    String token = _inviteCodeCtrl.text.trim();
    if (token.isEmpty) {
      _showError('Por favor ingresa el código de invitación.');
      return;
    }

    if (token.contains('token=')) {
      final uri = Uri.tryParse(token);
      if (uri != null && uri.queryParameters.containsKey('token')) {
        token = uri.queryParameters['token']!;
      } else {
        final parts = token.split('token=');
        if (parts.length > 1) {
          token = parts[1].split('&')[0];
        }
      }
      _inviteCodeCtrl.text = token;
    }

    setState(() {
      _loading = true;
      _loadingMessage = "Uniendo al hogar familiar...";
    });

    try {
      final user = SessionService().currentUser;
      final response = await ApiClient().post('/familia/join', {
        'invite_token': token,
        'user_id': user?.id ?? '',
      });

      final data = jsonDecode(response.body);
      final family = data['family'];
      final newToken = data['token_jwt'] as String?;
      final profileJson = data['profile'];

      UserProfile updatedProfile;
      if (profileJson != null && profileJson is Map<String, dynamic>) {
        updatedProfile = UserProfile.fromJson(profileJson);
      } else if (user != null) {
        updatedProfile = user.copyWith(
          familyId: family['id'],
          familyName: family['nombre'],
          rol: 'miembro',
        );
      } else {
        updatedProfile = UserProfile.empty.copyWith(
          familyId: family['id'],
          familyName: family['nombre'],
          rol: 'miembro',
        );
      }

      await SessionService().saveSession(
        token: newToken ?? SessionService().token ?? '',
        profile: updatedProfile,
      );
      await SessionService().setOnboardingRole('miembro');

      if (!mounted) return;
      _showSuccess('¡Te has unido con éxito a la ${family['nombre']}!');
      _next();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      if (_rol == 'miembro') {
        setState(() {
          _isScanning = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submitMiembroOnboarding() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _loadingMessage = "Registrando tus hábitos...";
    });

    int tiempoDuchaMinutos = 8;
    if (_tiempoDucha == '< 5 min') tiempoDuchaMinutos = 4;
    if (_tiempoDucha == '10-15 min') tiempoDuchaMinutos = 12;
    if (_tiempoDucha == '> 15 min') tiempoDuchaMinutos = 18;

    int horasPantalla = 4;
    if (_lucesEncendidas == '< 3 horas') horasPantalla = 2;
    if (_lucesEncendidas == '> 6 horas') horasPantalla = 8;

    String reciclajeFreq = 'ocasional';
    if (_reciclaje == 'Nunca') reciclajeFreq = 'nunca';
    if (_reciclaje == 'Siempre') reciclajeFreq = 'siempre';

    try {
      await ApiClient().post('/onboarding', {
        'tiempoDuchaPromedio': tiempoDuchaMinutos,
        'horasPantallaDiarias': horasPantalla,
        'frecuenciaReciclaje': reciclajeFreq
      });

      if (!mounted) return;
      await _next();
    } catch (e) {
      if (!mounted) return;
      _showError('Error al guardar hábitos: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String get _juegoSugerido {
    if (_tiempoDucha == '10-15 min' || _tiempoDucha == '> 15 min') {
      return 'ducha';
    }
    if (_reciclaje == 'Nunca' || _reciclaje == 'A veces') {
      return 'puzzle';
    }
    return 'trivia';
  }

  void _showError(String msg) {
    HabitikFeedback.showError(context, msg.replaceAll('Exception:', '').trim());
  }

  void _showSuccess(String msg) {
    HabitikFeedback.showSuccess(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  OnboardingProgressHeader(
                    currentStep: _step,
                    totalSteps: _totalSteps,
                    onPrev: _prev,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: AnimatedSwitcher(
                          duration: 300.ms,
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: KeyedSubtree(
                            key: ValueKey('$_rol-$_step'),
                            child: _buildStep(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              LoadingOverlay(
                isLoading: _loading,
                message: _loadingMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_rol == 'jefe') {
      switch (_step) {
        case 0:
          return StepJefeConsumo(
            tipoBoleta: _tipoBoleta,
            onTipoBoletaChanged: (val) {
              setState(() {
                _tipoBoleta = val;
                if (val == 'agua' && (_empresaCtrl.text.isEmpty || _empresaCtrl.text == 'Enel')) {
                  _empresaCtrl.text = 'Aguas Andinas';
                  if (_consumoCtrl.text == '140') _consumoCtrl.text = '15';
                  if (_montoCtrl.text == '21000') _montoCtrl.text = '14500';
                } else if (val == 'luz' && (_empresaCtrl.text.isEmpty || _empresaCtrl.text == 'Aguas Andinas')) {
                  _empresaCtrl.text = 'Enel';
                  if (_consumoCtrl.text == '15') _consumoCtrl.text = '140';
                  if (_montoCtrl.text == '14500') _montoCtrl.text = '21000';
                }
              });
            },
            isOcrReading: _isOcrReading,
            onScanBill: () => _handleScanBill(source: ImageSource.camera),
            onPickGallery: () => _handleScanBill(source: ImageSource.gallery),
            documentBackupName: _documentBackupName,
            onClearDocument: _clearDocumentBackup,
            consumoCtrl: _consumoCtrl,
            montoCtrl: _montoCtrl,
            empresaCtrl: _empresaCtrl,
            periodoCtrl: _periodoCtrl,
            familyNameCtrl: _familyNameCtrl,
            onSubmit: _submitJefeConsumoStep,
          );
        case 1:
          return StepJefeInfraestructura(
            personasCount: _personasCount,
            onPersonasChanged: (v) => setState(() => _personasCount = v),
            habitacionesCount: _habitacionesCount,
            onHabitacionesChanged: (v) => setState(() => _habitacionesCount = v),
            tipoCalefaccion: _tipoCalefaccion,
            onCalefaccionChanged: (v) => setState(() => _tipoCalefaccion = v),
            electrodomesticos: _electrodomesticos,
            onToggleElectrodomestico: () {},
            onToggleElectrodomesticoItem: (appId) {
              setState(() {
                if (_electrodomesticos.contains(appId)) {
                  _electrodomesticos.remove(appId);
                } else {
                  _electrodomesticos.add(appId);
                }
              });
            },
            onSubmit: _submitJefeOnboarding,
          );
        case 2:
          return StepJefeFinal(
            mapaGastoEstimado: _mapaGastoEstimado,
            inviteToken: _inviteToken,
            qrError: _qrError,
            onGenerateInviteToken: _generateInviteToken,
            onNext: _next,
            onShowSuccess: _showSuccess,
          );
        default:
          return const SizedBox.shrink();
      }
    } else {
      switch (_step) {
        case 0:
          return StepMiembroJoin(
            hasCameraPermission: _hasCameraPermission,
            scannerController: _scannerController,
            isScanning: _isScanning,
            inviteCodeCtrl: _inviteCodeCtrl,
            onCheckPermission: _checkPermission,
            onDetectCode: (code) {
              String token = code.trim();
              if (token.contains('token=')) {
                final uri = Uri.tryParse(token);
                if (uri != null && uri.queryParameters.containsKey('token')) {
                  token = uri.queryParameters['token']!;
                } else {
                  final parts = token.split('token=');
                  if (parts.length > 1) {
                    token = parts[1].split('&')[0];
                  }
                }
              }
              setState(() {
                _isScanning = false;
              });
              _inviteCodeCtrl.text = token;
              _joinFamily();
            },
            onJoinFamily: _joinFamily,
          );
        case 1:
          return StepMiembroHabitos(
            tiempoDucha: _tiempoDucha,
            onTiempoDuchaChanged: (v) => setState(() => _tiempoDucha = v),
            lucesEncendidas: _lucesEncendidas,
            onLucesEncendidasChanged: (v) => setState(() => _lucesEncendidas = v),
            reciclaje: _reciclaje,
            onReciclajeChanged: (v) => setState(() => _reciclaje = v),
            onSubmit: _submitMiembroOnboarding,
          );
        case 2:
          return StepMiembroFinal(
            juegoSugerido: _juegoSugerido,
            onNext: _next,
          );
        default:
          return const SizedBox.shrink();
      }
    }
  }
}
