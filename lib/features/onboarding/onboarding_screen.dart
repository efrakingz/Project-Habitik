import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String? _rol;
  int? _personas;
  final Map<String, String> _encuesta = {};

  bool get _canContinue => true;

  int get _totalSteps => _rol == 'jefe' ? 4 : 3;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          child: Column(
            children: [
              // ── Progress header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.eco, color: HabitikColors.green700, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text('Habitik', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    ]),
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
                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(
                        position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                        child: child,
                      )),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(),
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
    switch (_step) {
      case 0: return _stepRol();
      case 1: return _rol == 'jefe' ? _stepPersonas() : _stepHabitos();
      case 2: return _rol == 'jefe' ? _stepHabitos() : _stepFinalMiembro();
      case 3: return _stepFinalJefe();
      default: return const SizedBox.shrink();
    }
  }

  // ── PASO 0: Rol ─────────────────────────────────────────────────────────
  Widget _stepRol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('🏠 Constitución del Hogar', '¿Cuál es tu rol en la familia?'),
        const SizedBox(height: 24),
        _rolCard('jefe', Icons.shield_outlined, 'Jefe de Familia', 'Acceso completo: metas, presupuesto y validación de retos.', '👑'),
        const SizedBox(height: 12),
        _rolCard('miembro', Icons.people_outline, 'Miembro', 'Retos, gamificación y seguimiento de hábitos eco.', '🙋'),
        const SizedBox(height: 32),
        PrimaryButton(label: 'Continuar', onTap: _canContinue ? _next : null, icon: Icons.arrow_forward),
      ],
    );
  }

  Widget _rolCard(String role, IconData icon, String title, String desc, String emoji) {
    final selected = _rol == role;
    return GestureDetector(
      onTap: () => setState(() => _rol = role),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected
              ? HabitikColors.heroGreen
              : const LinearGradient(colors: [HabitikColors.green50, HabitikColors.green50]),
          borderRadius: HabitikRadius.lg_,
          border: Border.all(color: selected ? HabitikColors.green600 : HabitikColors.divider, width: 2),
          boxShadow: selected ? HabitikShadows.colored(HabitikColors.green600) : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: selected ? Colors.white : HabitikColors.textDark, fontWeight: FontWeight.w800, fontSize: 15)),
                Text(desc, style: TextStyle(color: selected ? HabitikColors.green200 : HabitikColors.textLight, fontSize: 12, height: 1.4)),
              ]),
            ),
            if (selected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ── PASO 1 (Jefe): Personas ──────────────────────────────────────────────
  Widget _stepPersonas() {
    final emojis = ['🧍', '👫', '👨‍👩‍👦', '👨‍👩‍👧‍👦', '🏠'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('👨‍👩‍👧‍👦 Tu Hogar', '¿Cuántas personas viven aquí?'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: [1, 2, 3, 4, 5].map((n) {
            final selected = _personas == n;
            return GestureDetector(
              onTap: () => setState(() => _personas = n),
              child: AnimatedContainer(
                duration: 200.ms,
                width: (MediaQuery.of(context).size.width - 70) / 3,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: selected
                      ? HabitikColors.heroGreen
                      : const LinearGradient(colors: [HabitikColors.green50, HabitikColors.green50]),
                  borderRadius: HabitikRadius.lg_,
                  border: Border.all(color: selected ? HabitikColors.green600 : HabitikColors.divider, width: 2),
                  boxShadow: selected ? HabitikShadows.colored(HabitikColors.green600) : [],
                ),
                child: Column(children: [
                  Text(emojis[n - 1], style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(n == 5 ? '5 o más' : '$n', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : HabitikColors.textDark)),
                  Text(n == 1 ? 'persona' : 'personas', style: TextStyle(fontSize: 10, color: selected ? HabitikColors.green200 : HabitikColors.textLight)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        PrimaryButton(label: 'Continuar', onTap: _canContinue ? _next : null, icon: Icons.arrow_forward),
      ],
    );
  }

  // ── PASO 2: Hábitos ─────────────────────────────────────────────────────
  Widget _stepHabitos() {
    final preguntas = [
      {'key': 'ducha', 'cat': '💧 Agua', 'label': '¿Cuánto tiempo te duras en la ducha?', 'ops': ['< 5 min', '5-10 min', '10-15 min', '> 15 min']},
      {'key': 'luces',  'cat': '⚡ Luz',  'label': '¿Dejas luces encendidas en habitaciones vacías?', 'ops': ['Nunca', 'A veces', 'Siempre']},
      {'key': 'cargadores', 'cat': '⚡ Energía', 'label': '¿Dejas cargadores enchufados sin usar?', 'ops': ['Nunca', 'A veces', 'Siempre']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('📊 Tus Hábitos', 'Responde honestamente para calcular tu impacto'),
        const SizedBox(height: 20),
        ...preguntas.map((q) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: HabitikColors.green100, borderRadius: HabitikRadius.xxl_),
              child: Text(q['cat'] as String, style: const TextStyle(color: HabitikColors.textDark, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 6),
            Text(q['label'] as String, style: const TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: (q['ops'] as List<String>).map((op) {
                final selected = _encuesta[q['key']] == op;
                return GestureDetector(
                  onTap: () => setState(() => _encuesta[q['key'] as String] = op),
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
            ),
          ]),
        )),
        PrimaryButton(label: 'Continuar', onTap: _next, icon: Icons.arrow_forward),
      ],
    );
  }

  // ── PASO FINAL Jefe/Miembro ──────────────────────────────────────────────
  Widget _stepFinalJefe() => _finalCard(
    icon: Icons.home_rounded,
    title: '¡Hogar listo!',
    desc: 'Comparte el código QR con tu familia para que se unan y empiecen a ganar XP.',
    btnLabel: '¡Empezar ahora!',
  );

  Widget _stepFinalMiembro() => _finalCard(
    icon: Icons.rocket_launch_rounded,
    title: '¡Ya estás dentro!',
    desc: 'Ya formas parte del hogar. Completa retos para ganar XP y monedas. ¡A jugar!',
    btnLabel: '¡Jugar ahora!',
  );

  Widget _finalCard({required IconData icon, required String title, required String desc, required String btnLabel}) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: HabitikColors.heroGreen,
            shape: BoxShape.circle,
            boxShadow: HabitikShadows.glow(HabitikColors.green500),
          ),
          child: Center(child: Icon(icon, color: Colors.white, size: 48)),
        ),
        const SizedBox(height: 24),
        Text(title, style: const TextStyle(color: HabitikColors.textDark, fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: HabitikColors.textLight, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        PrimaryButton(label: btnLabel, onTap: widget.onFinish, icon: Icons.play_arrow_rounded),
      ],
    );
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: HabitikColors.textDark, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: HabitikColors.green500, fontSize: 13)),
    ]);
  }
}
