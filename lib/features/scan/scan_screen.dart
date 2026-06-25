import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isOcrReading = false;
  bool _showForm = false;
  bool _submitting = false;

  String _tipoBoleta = 'luz'; // 'luz' o 'agua'
  final _consumoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _periodoCtrl = TextEditingController();

  @override
  void dispose() {
    _consumoCtrl.dispose();
    _montoCtrl.dispose();
    _empresaCtrl.dispose();
    _periodoCtrl.dispose();
    super.dispose();
  }

  void _simulateOcr() async {
    setState(() {
      _isOcrReading = true;
      _showForm = false;
    });

    await Future.delayed(2500.ms);

    if (mounted) {
      setState(() {
        _isOcrReading = false;
        _showForm = true;
        _consumoCtrl.text = _tipoBoleta == 'luz' ? '195' : '14';
        _montoCtrl.text = _tipoBoleta == 'luz' ? '29250' : '16800';
        _empresaCtrl.text = _tipoBoleta == 'luz' ? 'Enel' : 'Aguas Andinas';
        _periodoCtrl.text = 'Junio';
      });
      _showSuccess('¡Lectura OCR completada! Por favor revisa los datos cargados.');
    }
  }

  void _submitManual() async {
    final consumo = _consumoCtrl.text.trim();
    final monto = _montoCtrl.text.trim();

    if (consumo.isEmpty || monto.isEmpty) {
      _showError('Por favor completa los campos de Consumo y Monto.');
      return;
    }

    setState(() {
      _submitting = true;
    });

    // Simular el registro de la boleta con el backend
    await Future.delayed(1500.ms);

    if (mounted) {
      setState(() {
        _submitting = false;
        _showForm = false;
        _consumoCtrl.clear();
        _montoCtrl.clear();
        _empresaCtrl.clear();
        _periodoCtrl.clear();
      });
      _showSuccess('¡Boleta registrada exitosamente en el sistema de ahorro!');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: HabitikColors.green700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ScreenShell(
              titulo: 'Scan de Boletas',
              subtitulo: '📄 Auditoría de Consumo',
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  children: [
                    // Card Principal
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
                          const Text('📄', style: TextStyle(fontSize: 54))
                              .animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),
                          const SizedBox(height: 12),
                          const Text(
                            'Escáner de Boletas',
                            style: TextStyle(
                              color: HabitikColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Captura tu boleta de agua o luz para registrar el consumo familiar',
                            style: TextStyle(
                              color: HabitikColors.textLight,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          if (_isOcrReading) ...[
                            const SizedBox(
                              width: 32, height: 32,
                              child: CircularProgressIndicator(color: HabitikColors.green700, strokeWidth: 3.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Esperando OCR... Leyendo boleta...',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HabitikColors.textDark),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: const Text('⚡ Luz'),
                                  selected: _tipoBoleta == 'luz',
                                  onSelected: (val) => setState(() => _tipoBoleta = 'luz'),
                                ),
                                const SizedBox(width: 12),
                                ChoiceChip(
                                  label: const Text('💧 Agua'),
                                  selected: _tipoBoleta == 'agua',
                                  onSelected: (val) => setState(() => _tipoBoleta = 'agua'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _simulateOcr,
                                    child: Container(
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: HabitikColors.heroGreen,
                                        borderRadius: HabitikRadius.md_,
                                        boxShadow: HabitikShadows.colored(HabitikColors.green600),
                                      ),
                                      child: const Text(
                                        '📷 Escanear Boleta',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      fixedSize: const Size.fromHeight(48),
                                      side: const BorderSide(color: HabitikColors.green600, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showForm = !_showForm;
                                        _consumoCtrl.clear();
                                        _montoCtrl.clear();
                                        _empresaCtrl.clear();
                                        _periodoCtrl.clear();
                                      });
                                    },
                                    child: Text(
                                      _showForm ? 'Ocultar' : 'Ingreso Manual',
                                      style: const TextStyle(color: HabitikColors.green700, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Formulario de Ingreso Manual
                    if (_showForm) ...[
                      const SizedBox(height: 20),
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos de la Boleta',
                              style: TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Divider(height: 20),

                            _label('Consumo real (${_tipoBoleta == 'luz' ? 'kWh' : 'm³'})'),
                            _textField('Ej: ${_tipoBoleta == 'luz' ? '180' : '12'}', _consumoCtrl, TextInputType.number),
                            const SizedBox(height: 12),

                            _label('Monto Cobrado (\$)'),
                            _textField('Ej: 27000', _montoCtrl, TextInputType.number),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _label('Empresa'),
                                      _textField('Ej: CGE', _empresaCtrl, TextInputType.text),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _label('Periodo'),
                                      _textField('Ej: Julio', _periodoCtrl, TextInputType.text),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            PrimaryButton(
                              label: 'Guardar Consumo 💾',
                              onTap: _submitManual,
                              loading: _submitting,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ],
                ),
              ),
            ),

            // Loader overlay
            if (_submitting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF00E5FF))),
                          SizedBox(height: 16),
                          Text(
                            'Guardando registro de consumo...',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.bold)),
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
