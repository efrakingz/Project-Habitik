import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/features/challenges/games/shared/game_widgets.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class HomeInspectionChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;
  const HomeInspectionChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<HomeInspectionChallenge> createState() => _HomeInspectionChallengeState();
}

class _HomeInspectionChallengeState extends State<HomeInspectionChallenge> {
  // Misiones rotativas simuladas
  static const _missions = [
    {'emoji': '💡', 'title': 'Apaga las luces', 'desc': 'Verifica que todas las luces estén apagadas en las habitaciones sin uso. Toma una foto como evidencia.', 'xp': 100, 'coins': 15},
    {'emoji': '🚰', 'title': 'Revisa grifos', 'desc': 'Comprueba que no haya grifos goteando en tu hogar. Fotografía los grifos cerrados.', 'xp': 80, 'coins': 10},
    {'emoji': '🔌', 'title': 'Desenchufa vampiros', 'desc': 'Desenchufa cargadores y electrodomésticos en standby. Foto de los tomacorrientes libres.', 'xp': 120, 'coins': 20},
  ];

  bool _submitted = false;
  bool _loading = false;
  final _noteCtrl = TextEditingController();
  bool _photoAdded = false;
  bool _showFlash = false;
  bool _isShaking = false;

  Map<String, dynamic> get _mission {
    final day = DateTime.now().day % _missions.length;
    return _missions[day] as Map<String, dynamic>;
  }

  void _capturePhoto() {
    if (_photoAdded) return;
    AudioService.playSFX('click.mp3');
    setState(() {
      _showFlash = true;
      _isShaking = true;
      _photoAdded = true;
    });
    Future.delayed(150.ms, () {
      if (mounted) setState(() => _showFlash = false);
    });
    Future.delayed(300.ms, () {
      if (mounted) setState(() => _isShaking = false);
    });
  }

  void _resetPhoto() {
    setState(() {
      _photoAdded = false;
    });
  }

  void _submit() async {
    if (!_photoAdded) return;
    setState(() => _loading = true);
    await Future.delayed(1400.ms);
    if (mounted) {
      AudioService.playSFX('win.mp3');
      setState(() { _loading = false; _submitted = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabitikColors.bgLight,
      body: SafeArea(
        child: GameShell(
          title: '🔍 Inspección del Día',
          headerColor: const Color(0xFFE65100),
          onClose: widget.onBack,
          child: _submitted ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final m = _mission;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mission card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFBF360C)]),
            borderRadius: HabitikRadius.lg_,
            boxShadow: HabitikShadows.colored(const Color(0xFFE65100)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['emoji'] as String, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(m['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(m['desc'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
            const SizedBox(height: 12),
            Row(children: [
              _chip('+${m['xp']} XP', Colors.white),
              const SizedBox(width: 8),
              _chip('+${m['coins']} 🪙', const Color(0xFFFFCA28)),
            ]),
          ]),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

        const SizedBox(height: 24),

        const Text('📸 Visor de Evidencia', style: TextStyle(color: HabitikColors.textDark, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),

        // High-tech Camera Viewfinder
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: HabitikRadius.lg_,
            border: Border.all(color: Colors.grey.shade800, width: 3),
            boxShadow: HabitikShadows.card,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Preview when photo added
              if (_photoAdded) ...[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 48)
                            .animate().scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        Text('EVIDENCIA CAPTURADA', style: TextStyle(color: Colors.greenAccent.shade200, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        const Text('Analizando patrones de consumo...', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            AudioService.playSFX('click.mp3');
                            _resetPhoto();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('🔄 Volver a capturar', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Laser scan sweep effect
                const Positioned.fill(child: LaserSweepAnimation()),
              ] else ...[
                // Viewfinder framing angles
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ViewfinderPainter(isShaking: _isShaking),
                  ),
                ),
                // Flashing REC indicator
                Positioned(
                  top: 15,
                  right: 15,
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
                      const SizedBox(width: 6),
                      const Text('REC', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                // Focus Crosshairs
                const Center(
                  child: Icon(Icons.center_focus_weak, color: Colors.white38, size: 44),
                ),
                // Capture trigger overlay button
                Center(
                  child: GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('CAPTURAR FOTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Shutter Flash overlay
              if (_showFlash)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
            ],
          ),
        ).animate(target: _isShaking ? 1 : 0)
         .shake(duration: 250.ms, hz: 6, curve: Curves.easeInOut),

        const SizedBox(height: 20),

        const Text('📝 Notas adicionales (opcional)', style: TextStyle(color: HabitikColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Ej: Apagué las 4 luces del pasillo y el baño...'),
        ),

        const SizedBox(height: 24),

        PrimaryButton(
          label: _photoAdded ? 'Enviar evidencia' : 'Agrega una foto primero',
          onTap: _photoAdded ? _submit : null,
          loading: _loading,
          icon: Icons.send_rounded,
          gradient: _photoAdded ? HabitikColors.heroGreen : null,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text('⏳', style: TextStyle(fontSize: 72))
              .animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text('¡Evidencia enviada!', style: TextStyle(color: HabitikColors.textDark, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Tu evidencia está en revisión.\nEl Jefe de Familia la validará pronto.',
            style: TextStyle(color: HabitikColors.textLight, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: HabitikColors.amber100, borderRadius: HabitikRadius.lg_, border: Border.all(color: HabitikColors.amber300)),
            child: const Row(children: [
              Text('⏰', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pendiente de aprobación', style: TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.w800, fontSize: 14)),
                Text('+100 XP y +15 🪙 al ser aprobado', style: TextStyle(color: HabitikColors.textLight, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              AudioService.playSFX('click.mp3');
              widget.onBack();
            },
            child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(gradient: HabitikColors.heroGreen, borderRadius: HabitikRadius.md_),
              alignment: Alignment.center,
              child: const Text('Volver a Retos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: HabitikRadius.xxl_),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
  );

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }
}

// ─────────────────────────────────────────────────────────────────────────────
// LaserSweepAnimation – efecto de barrido láser verde de escaneo tecnológico
// ─────────────────────────────────────────────────────────────────────────────
class LaserSweepAnimation extends StatefulWidget {
  const LaserSweepAnimation({super.key});

  @override
  State<LaserSweepAnimation> createState() => _LaserSweepAnimationState();
}

class _LaserSweepAnimationState extends State<LaserSweepAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 220 * _controller.value, // Viewfinder height is 220
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withAlpha(200),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ViewfinderPainter – dibuja las esquinas blancas del visor de la cámara
// ─────────────────────────────────────────────────────────────────────────────
class _ViewfinderPainter extends CustomPainter {
  final bool isShaking;
  _ViewfinderPainter({required this.isShaking});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const double l = 16.0; // corner line length
    
    // Top-Left corner
    canvas.drawPath(Path()..moveTo(12, 12 + l)..lineTo(12, 12)..lineTo(12 + l, 12), paint);
    // Top-Right corner
    canvas.drawPath(Path()..moveTo(size.width - 12 - l, 12)..lineTo(size.width - 12, 12)..lineTo(size.width - 12, 12 + l), paint);
    // Bottom-Left corner
    canvas.drawPath(Path()..moveTo(12, size.height - 12 - l)..lineTo(12, size.height - 12)..lineTo(12 + l, size.height - 12), paint);
    // Bottom-Right corner
    canvas.drawPath(Path()..moveTo(size.width - 12 - l, size.height - 12)..lineTo(size.width - 12, size.height - 12)..lineTo(size.width - 12, size.height - 12 - l), paint);
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => old.isShaking != isShaking;
}
