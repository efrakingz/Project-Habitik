import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  // Datos Jefe: Boleta / Consumo
  String _tipoBoleta = 'luz'; // 'luz' o 'agua'
  final _familyNameCtrl = TextEditingController(text: 'Mi Hogar');
  final _consumoCtrl = TextEditingController(text: '140');
  final _montoCtrl = TextEditingController(text: '21000');
  final _empresaCtrl = TextEditingController(text: 'Enel');
  final _periodoCtrl = TextEditingController(text: 'Junio');
  
  bool _isOcrReading = false;
  String? _inviteToken;

  // Datos Jefe: Cuestionario del Hogar
  int _personasCount = 4;
  int _habitacionesCount = 3;
  String _tipoCalefaccion = 'electrica';
  final List<String> _electrodomesticos = ['lavadora', 'secadora'];

  // Datos Miembro: Unirse a Hogar & Hábitos
  final _inviteCodeCtrl = TextEditingController();
  String _tiempoDucha = '5-10 min';
  String _lucesEncendidas = 'A veces';
  String _reciclaje = 'A veces';

  bool _hasCameraPermission = false;
  bool _isScanning = true;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    // Leer el rol de onboarding (local u obtenido de la BD)
    _rol = SessionService().getOnboardingRole();
    if (_rol == 'miembro') {
      _checkPermission();
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
      );
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _hasCameraPermission = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _hasCameraPermission = false;
        });
      }
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

  void _next() async {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      if (_rol == 'jefe' && _step == 2) {
        // Al entrar al paso final del Jefe (paso 2), generar el QR de invitación
        _generateInviteToken();
      }
    } else {
      await SessionService().setOnboardingCompleted(true);
      widget.onFinish();
    }
  }

  void _prev() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
    }
  }

  // Genera el QR de invitación desde el backend
  Future<void> _generateInviteToken() async {
    setState(() {
      _loading = true;
      _loadingMessage = "Generando código de invitación...";
    });
    try {
      final response = await ApiClient().get('/familia/invite');
      final data = jsonDecode(response.body);
      setState(() {
        _inviteToken = data['invite_token'];
      });
    } catch (e) {
      _showError('No se pudo generar el token de invitación: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Simula la lectura OCR de la boleta
  void _simulateOcr() async {
    setState(() {
      _isOcrReading = true;
    });
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
      await ApiClient().patch('/familia/nombre', {
        'nombre': familyName,
      });

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

  // Envía el consumo y cuestionario de Jefe al backend
  Future<void> _submitJefeOnboarding() async {
    setState(() {
      _loading = true;
      _loadingMessage = "Calculando consumo baseline del hogar...";
    });

    try {
      await ApiClient().post('/onboarding', {
        'personasCount': _personasCount,
        'habitacionesCount': _habitacionesCount,
        'tipoCalefaccion': _tipoCalefaccion,
        'electrodomesticos': _electrodomesticos
      });

      _next();
    } catch (e) {
      _showError('Error al guardar onboarding: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Une al miembro a la familia por invite_token
  Future<void> _joinFamily() async {
    final code = _inviteCodeCtrl.text.trim();
    if (code.isEmpty) {
      _showError('Por favor ingresa el código de invitación.');
      return;
    }

    setState(() {
      _loading = true;
      _loadingMessage = "Uniendo al hogar familiar...";
    });

    try {
      final user = SessionService().currentUser;
      final response = await ApiClient().post('/familia/join', {
        'invite_token': code,
        'user_id': user?.id ?? '',
      });

      final data = jsonDecode(response.body);
      final family = data['family'];
      
      // Actualizar perfil local del usuario en la sesión
      if (user != null) {
        final updatedProfile = user.copyWith(
          familyId: family['id'],
          familyName: family['nombre'],
          rol: 'miembro',
        );
        // Guardar sesión refrescando el perfil local
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

  // Envía hábitos de Miembro al backend
  Future<void> _submitMiembroOnboarding() async {
    setState(() {
      _loading = true;
      _loadingMessage = "Registrando tus hábitos...";
    });

    // Mapear opciones de encuesta a datos del backend
    int tiempoDuchaMinutos = 8;
    if (_tiempoDucha == '< 5 min') tiempoDuchaMinutos = 4;
    if (_tiempoDucha == '10-15 min') tiempoDuchaMinutos = 12;
    if (_tiempoDucha == '> 15 min') tiempoDuchaMinutos = 18;

    int horasPantalla = 4;
    if (_lucesEncendidas == 'Nunca') horasPantalla = 2;
    if (_lucesEncendidas == 'Siempre') horasPantalla = 8;

    String reciclajeFreq = 'ocasional';
    if (_reciclaje == 'Nunca') reciclajeFreq = 'nunca';
    if (_reciclaje == 'Siempre') reciclajeFreq = 'siempre';

    try {
      await ApiClient().post('/onboarding', {
        'tiempoDuchaPromedio': tiempoDuchaMinutos,
        'horasPantallaDiarias': horasPantalla,
        'frecuenciaReciclaje': reciclajeFreq
      });

      _next();
    } catch (e) {
      _showError('Error al guardar hábitos: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Obtiene sugerencia dinámica de juego
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
                  // ── Progress header ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_step > 0) ...[
                              GestureDetector(
                                onTap: _prev,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: HabitikColors.whiteOverlay20,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.eco, color: HabitikColors.green700, size: 16),
                              ),
                              const SizedBox(width: 8),
                            ],
                            const Text('Habitik', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Paso ${_step + 1} de $_totalSteps', style: const TextStyle(color: HabitikColors.green200, fontSize: 12)),
                            Text('${((_step + 1) / _totalSteps * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(children: [
                          Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: HabitikColors.green600, borderRadius: HabitikRadius.xs_)),
                          LayoutBuilder(builder: (ctx, cons) => AnimatedContainer(
                            duration: 400.ms,
                            curve: Curves.easeOut,
                            height: 8,
                            width: cons.maxWidth * ((_step + 1) / _totalSteps),
                            decoration: BoxDecoration(
                              gradient: HabitikColors.xpGold,
                              borderRadius: HabitikRadius.xs_,
                            ),
                          )),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Step content ────────────────────────────────────────────
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

              // Loader Inteligente Bloqueante
              if (_loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B2A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 4.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _loadingMessage,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
        case 0: return _stepJefeConsumo();
        case 1: return _stepJefeInfraestructura();
        case 2: return _stepFinalJefe();
        default: return const SizedBox.shrink();
      }
    } else {
      switch (_step) {
        case 0: return _stepMiembroJoin();
        case 1: return _stepMiembroHabitos();
        case 2: return _stepFinalMiembro();
        default: return const SizedBox.shrink();
      }
    }
  }

  // ── ONBOARDING JEFE: PASO 0 - Consumo de Boletas (OCR/Manual) ────────────────────
  Widget _stepJefeConsumo() {
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
                selected: _tipoBoleta == 'luz',
                onSelected: (val) => setState(() => _tipoBoleta = 'luz'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('💧 Agua Potable'),
                selected: _tipoBoleta == 'agua',
                onSelected: (val) => setState(() => _tipoBoleta = 'agua'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Lector OCR
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
              if (_isOcrReading) ...[
                const SizedBox(
                  width: 36, height: 36,
                  child: CircularProgressIndicator(color: HabitikColors.green700, strokeWidth: 3.5),
                ),
                const SizedBox(height: 12),
                const Text('Esperando OCR... Escaneando boleta...', style: TextStyle(fontWeight: FontWeight.bold, color: HabitikColors.textDark, fontSize: 13)),
              ] else ...[
                const Text('📷', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                const Text('Escanear boleta con cámara', style: TextStyle(fontWeight: FontWeight.bold, color: HabitikColors.textDark, fontSize: 13)),
                const Text('Extrae consumo y monto automáticamente', style: TextStyle(color: HabitikColors.textLight, fontSize: 11)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _simulateOcr,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: HabitikColors.green700, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Escanear 📷', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionSubtitle('O ingresar datos manualmente:'),
        const SizedBox(height: 12),
        
        _label('Consumo estimado (${_tipoBoleta == 'luz' ? 'kWh' : 'm³'})'),
        _textField('Ej: ${_tipoBoleta == 'luz' ? '140' : '15'}', _consumoCtrl, TextInputType.number),
        const SizedBox(height: 12),

        _label('Monto total boleta (\$)'),
        _textField('Ej: 25000', _montoCtrl, TextInputType.number),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Empresa'),
                  _textField('Ej: Enel', _empresaCtrl, TextInputType.text),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Periodo'),
                  _textField('Ej: Junio', _periodoCtrl, TextInputType.text),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _label('Nombre de tu Hogar (Familia)'),
        _textField('Ej: Familia Torres', _familyNameCtrl, TextInputType.text),
        const SizedBox(height: 28),

        PrimaryButton(label: 'Establecer Metas', onTap: _submitJefeConsumoStep, icon: Icons.analytics_outlined),
      ],
    );
  }

  // ── ONBOARDING JEFE: PASO 1 - Infraestructura del Hogar ─────────────────────────
  Widget _stepJefeInfraestructura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('🏠 Cuestionario del Hogar', 'Cuéntanos sobre tu infraestructura para establecer el baseline'),
        const SizedBox(height: 20),

        // Pregunta 1: Personas
        _questionCat('👥 Integrantes'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuántas personas viven en tu hogar?'),
        const SizedBox(height: 8),
        _chipList(['1', '2', '3', '4', '5+'], _personasCount.toString(), (v) {
          setState(() {
            _personasCount = v == '5+' ? 5 : int.parse(v);
          });
        }),
        const SizedBox(height: 20),

        // Pregunta 2: Habitaciones
        _questionCat('🚪 Habitaciones'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuántas habitaciones tiene tu hogar?'),
        const SizedBox(height: 8),
        _chipList(['1', '2', '3', '4', '5+'], _habitacionesCount.toString(), (v) {
          setState(() {
            _habitacionesCount = v == '5+' ? 5 : int.parse(v);
          });
        }),
        const SizedBox(height: 20),

        // Pregunta 3: Calefacción
        _questionCat('🔥 Calefacción'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuál es el tipo de calefacción principal?'),
        const SizedBox(height: 8),
        _chipList(['electrica', 'gas', 'lena', 'otra'], _tipoCalefaccion, (v) {
          setState(() => _tipoCalefaccion = v);
        }),
        const SizedBox(height: 20),

        // Pregunta 4: Electrodomésticos
        _questionCat('🔌 Electrodomésticos'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuáles electrodomésticos de alto consumo tienen?'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['lavadora', 'secadora', 'lavavajillas', 'aire_acondicionado'].map((appliance) {
            final selected = _electrodomesticos.contains(appliance);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _electrodomesticos.remove(appliance);
                  } else {
                    _electrodomesticos.add(appliance);
                  }
                });
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? HabitikColors.heroGreen
                      : const LinearGradient(colors: [HabitikColors.green50, HabitikColors.green50]),
                  borderRadius: HabitikRadius.md_,
                  border: Border.all(color: selected ? HabitikColors.green600 : HabitikColors.divider),
                ),
                child: Text(
                  appliance.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: selected ? Colors.white : HabitikColors.textDark, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        PrimaryButton(label: 'Guardar Cuestionario', onTap: _submitJefeOnboarding, icon: Icons.arrow_forward),
      ],
    );
  }

  // ── ONBOARDING JEFE: PASO 1 - Código QR Invitación ──────────────────────────────
  Widget _stepFinalJefe() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: HabitikColors.green100, shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.check_circle, color: HabitikColors.green700, size: 44)),
        ),
        const SizedBox(height: 20),
        const Text('¡Hogar configurado!', style: TextStyle(color: HabitikColors.textDark, fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Tu baseline de consumo ha sido guardado. Comparte este código QR o código de texto con tu familia para que se unan a tu hogar.', style: TextStyle(color: HabitikColors.textLight, fontSize: 13, height: 1.4), textAlign: TextAlign.center),
        
        const SizedBox(height: 24),
        
        // QR Mockup
        Container(
          width: 180, height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HabitikColors.green500, width: 2),
            boxShadow: HabitikShadows.card,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: _inviteToken != null
                  ? QrImageView(
                      data: _inviteToken!,
                      version: QrVersions.auto,
                      size: 140,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: HabitikColors.green800,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: HabitikColors.green800,
                      ),
                    )
                  : const CircularProgressIndicator(color: HabitikColors.green800),
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_inviteToken != null) ...[
          const Text('CÓDIGO DE INVITACIÓN:', style: TextStyle(color: HabitikColors.textLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          SelectableText(
            _inviteToken!,
            style: const TextStyle(color: HabitikColors.green800, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 32),
        PrimaryButton(label: '¡Empezar ahora!', onTap: _next, icon: Icons.play_arrow_rounded),
      ],
    );
  }

  // ── ONBOARDING MIEMBRO: PASO 0 - Unirse a Hogar (Scanner QR / Código) ────────────────
  Widget _stepMiembroJoin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('👥 Unirse a un Hogar', 'Escanea el código QR de tu Jefe de Familia o ingresa el código manual'),
        const SizedBox(height: 20),

        // Visor de Cámara QR Estilo Escáner Profesional
        Container(
          width: double.infinity,
          height: 220,
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
              if (_hasCameraPermission && _scannerController != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(HabitikRadius.md - 2),
                    child: MobileScanner(
                      controller: _scannerController!,
                      onDetect: (capture) {
                        if (!_isScanning) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final code = barcode.rawValue;
                          if (code != null && code.isNotEmpty) {
                            setState(() {
                              _isScanning = false;
                            });
                            _inviteCodeCtrl.text = code;
                            _joinFamily();
                            break;
                          }
                        }
                      },
                    ),
                  ),
                )
              else if (!_hasCameraPermission)
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
                            onPressed: _checkPermission,
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
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Línea láser roja de escaneo dentro del cuadro
                    Center(
                      child: Container(
                        width: 110,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          boxShadow: [
                            BoxShadow(color: Colors.redAccent.withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 1),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .slideY(begin: -20, end: 20, duration: 1200.ms),
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
        _textField('Ingresa token de 36 caracteres...', _inviteCodeCtrl, TextInputType.text),
        const SizedBox(height: 24),

        PrimaryButton(label: 'Vincular Hogar 🔗', onTap: _joinFamily, icon: Icons.link_rounded),
      ],
    );
  }

  // ── ONBOARDING MIEMBRO: PASO 1 - Encuesta de Hábitos ──────────────────────────────
  Widget _stepMiembroHabitos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('📊 Tus Hábitos', 'Responde con honestidad para personalizar tu experiencia'),
        const SizedBox(height: 20),

        // Pregunta 1
        _questionCat('💧 Agua'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuánto tiempo duras en la ducha aproximadamente?'),
        const SizedBox(height: 8),
        _chipList(['< 5 min', '5-10 min', '10-15 min', '> 15 min'], _tiempoDucha, (v) => setState(() => _tiempoDucha = v)),
        const SizedBox(height: 20),

        // Pregunta 2
        _questionCat('⚡ Luz'),
        const SizedBox(height: 4),
        _questionLabel('¿Dejas las luces encendidas en habitaciones vacías?'),
        const SizedBox(height: 8),
        _chipList(['Nunca', 'A veces', 'Siempre'], _lucesEncendidas, (v) => setState(() => _lucesEncendidas = v)),
        const SizedBox(height: 20),

        // Pregunta 3
        _questionCat('♻️ Reciclaje'),
        const SizedBox(height: 4),
        _questionLabel('¿Qué tan seguido reciclas botellas o plásticos?'),
        const SizedBox(height: 8),
        _chipList(['Nunca', 'A veces', 'Siempre'], _reciclaje, (v) => setState(() => _reciclaje = v)),
        
        const SizedBox(height: 28),

        PrimaryButton(label: 'Guardar Hábitos', onTap: _submitMiembroOnboarding, icon: Icons.arrow_forward),
      ],
    );
  }

  // ── ONBOARDING MIEMBRO: PASO 2 - Final & Sugerencia de Juegos ─────────────────────
  Widget _stepFinalMiembro() {
    final juego = _juegoSugerido;
    String juegoEmoji = '🎮';
    String juegoTitulo = 'Eco-Desafíos';
    String juegoDesc = 'Completa minijuegos sustentables diarios.';
    Color juegoColor = HabitikColors.green700;

    if (juego == 'ducha') {
      juegoEmoji = '🚿';
      juegoTitulo = 'Speedrun de la Ducha';
      juegoDesc = 'Dado que te duchas más de 10 min, te sugerimos jugar hoy para controlar tu tiempo.';
      juegoColor = Colors.blue.shade700;
    } else if (juego == 'puzzle') {
      juegoEmoji = '🎯';
      juegoTitulo = 'Eco-Puzzle';
      juegoDesc = 'Dado que reciclas poco, te sugerimos este puzzle rápido para aprender a clasificar residuos.';
      juegoColor = Colors.red.shade700;
    } else {
      juegoEmoji = '🧠';
      juegoTitulo = 'Trivia Eco';
      juegoDesc = '¡Genial! Tienes buenos hábitos. Juega a la trivia para poner a prueba tus conocimientos.';
      juegoColor = Colors.purple.shade700;
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: HabitikColors.green100, shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.rocket_launch_rounded, color: HabitikColors.green700, size: 40)),
        ),
        const SizedBox(height: 20),
        const Text('¡Todo listo, Miembro!', style: TextStyle(color: HabitikColors.textDark, fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Ya formas parte del hogar. Según tus hábitos de consumo, te sugerimos empezar con este Eco-Desafío hoy:', style: TextStyle(color: HabitikColors.textLight, fontSize: 13, height: 1.45), textAlign: TextAlign.center),
        
        const SizedBox(height: 20),

        // Tarjeta Sugerencia de Juego
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: juegoColor.withValues(alpha: 0.3), width: 2),
            boxShadow: HabitikShadows.card,
          ),
          child: Row(
            children: [
              Text(juegoEmoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RECOMENDACIÓN DEL DÍA', style: TextStyle(color: juegoColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    Text(juegoTitulo, style: const TextStyle(color: HabitikColors.textDark, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(juegoDesc, style: const TextStyle(color: HabitikColors.textLight, fontSize: 11, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        PrimaryButton(label: '¡Jugar ahora!', onTap: _next, icon: Icons.play_arrow_rounded),
      ],
    );
  }

  // ── WIDGETS AUXILIARES ────────────────────────────────────────────────────────
  Widget _stepTitle(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: HabitikColors.textDark, fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: HabitikColors.green500, fontSize: 12.5)),
    ]);
  }

  Widget _sectionSubtitle(String text) => Text(text, style: const TextStyle(color: HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.bold));

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.w600)),
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

  Widget _questionCat(String cat) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: HabitikColors.green100, borderRadius: HabitikRadius.xxl_),
    child: Text(cat, style: const TextStyle(color: HabitikColors.textDark, fontSize: 10, fontWeight: FontWeight.w800)),
  );

  Widget _questionLabel(String label) => Text(label, style: const TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.w700, fontSize: 13));

  Widget _chipList(List<String> ops, String selectedVal, Function(String) onSelect) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: ops.map((op) {
        final selected = selectedVal == op;
        return GestureDetector(
          onTap: () => onSelect(op),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected
                  ? HabitikColors.heroGreen
                  : const LinearGradient(colors: [HabitikColors.green50, HabitikColors.green50]),
              borderRadius: HabitikRadius.md_,
              border: Border.all(color: selected ? HabitikColors.green600 : HabitikColors.divider),
            ),
            child: Text(op, style: TextStyle(color: selected ? Colors.white : HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }
}

