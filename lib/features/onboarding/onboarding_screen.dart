import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/user.dart';
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
  const OnboardingScreen({super.key, required this.onFinish});

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

  void _simulateOcr() async {
    setState(() => _isOcrReading = true);
    await Future.delayed(2500.ms);
    if (mounted) {
      setState(() {
        _isOcrReading = false;
        _consumoCtrl.text = _tipoBoleta == 'luz' ? '185' : '12';
        _montoCtrl.text = _tipoBoleta == 'luz' ? '27800' : '14400';
        _empresaCtrl.text = _tipoBoleta == 'luz' ? 'Enel' : 'Aguas Andinas';
        _periodoCtrl.text = 'Junio';
      });
      _showSuccess('¡OCR leido correctamente! Datos cargados.');
    }
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
      await ApiClient().patch('/familia/nombre', {'nombre': familyName});

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

      await _next();
    } catch (e) {
      _showError('Error al guardar onboarding: $e');
    } finally {
      setState(() => _loading = false);
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

      final email = SessionService().tempEmail;
      final pwd = SessionService().tempPwd;
      if (email != null && pwd != null) {
        try {
          final loginRes = await ApiClient().post('/auth/login', {
            'email': email,
            'password': pwd,
          });
          final loginData = jsonDecode(loginRes.body);
          final newToken = loginData['token_jwt'];
          final newProfile = UserProfile.fromJson(loginData['profile']).copyWith(
            familyId: family['id'],
            familyName: family['nombre'],
            rol: 'miembro',
          );
          await SessionService().saveSession(token: newToken, profile: newProfile);
        } catch (_) {
          if (user != null) {
            final updatedProfile = user.copyWith(
              familyId: family['id'],
              familyName: family['nombre'],
              rol: 'miembro',
            );
            await SessionService().saveSession(token: SessionService().token ?? '', profile: updatedProfile);
          }
        }
      } else if (user != null) {
        final updatedProfile = user.copyWith(
          familyId: family['id'],
          familyName: family['nombre'],
          rol: 'miembro',
        );
        await SessionService().saveSession(token: SessionService().token ?? '', profile: updatedProfile);
      }

      _showSuccess('¡Te has unido con éxito a la ${family['nombre']}!');
      _next();
    } catch (e) {
      _showError(e.toString());
      if (_rol == 'miembro') {
        setState(() {
          _isScanning = true;
        });
      }
    } finally {
      setState(() => _loading = false);
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

      await _next();
    } catch (e) {
      _showError('Error al guardar hábitos: $e');
    } finally {
      setState(() => _loading = false);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception:', '').trim()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: HabitikColors.green700,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            onTipoBoletaChanged: (val) => setState(() => _tipoBoleta = val),
            isOcrReading: _isOcrReading,
            onSimulateOcr: _simulateOcr,
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
