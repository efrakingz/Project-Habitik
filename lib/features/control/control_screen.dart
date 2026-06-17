import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final _validations = PendingValidation.mockList;
  int _metaLuz  = 10;
  int _metaAgua = 8;

  void _aprobar(int id) {
    setState(() => _validations.removeWhere((v) => v.id == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('✅ Evidencia aprobada. El usuario recibió XP y monedas.'),
      backgroundColor: HabitikColors.green600,
    ));
  }

  void _rechazar(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: isDark ? const Color(0xFF1E2E22) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        final ctrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setModal) => Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Motivo de rechazo', style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('Explica por qué no cumple:', style: TextStyle(color: isDark ? HabitikColors.green300 : HabitikColors.green500, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark),
                decoration: InputDecoration(hintText: 'Ej: La foto no muestra las luces apagadas...', border: OutlineInputBorder(borderRadius: HabitikRadius.md_)),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.text.trim().isNotEmpty ? () {
                    setState(() => _validations.removeWhere((v) => v.id == id));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Evidencia rechazada.'), backgroundColor: Colors.redAccent));
                  } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  child: const Text('Confirmar Rechazo'),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Panel de Control',
          subtitulo: '👑 Jefe de Familia',
          headerActions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: HabitikColors.amber400, borderRadius: HabitikRadius.xxl_),
              child: const Text('ADMIN', style: TextStyle(color: Color(0xFF5D4037), fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Energía Familiar (Barra) ──
              EnergyBar(
                pct: 0.72,
                luzLabel: 'Meta 10% reducción',
                aguaLabel: 'Meta 8% reducción',
                luzSaving: '-18 kWh',
                aguaSaving: '-12 m³',
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // ── Metas de ahorro ──────────────────────────────────────
              const GameSectionTitle(icon: Icons.gps_fixed, title: 'Metas de Ahorro Mensual'),
              const SizedBox(height: 12),
              _metaSlider('⚡ Reducir Luz', _metaLuz, HabitikColors.amber400, (v) => setState(() => _metaLuz = v)),
              const SizedBox(height: 10),
              _metaSlider('💧 Reducir Agua', _metaAgua, HabitikColors.blue400, (v) => setState(() => _metaAgua = v)),
              const SizedBox(height: 24),

              // ── Validaciones ─────────────────────────────────────────
              const GameSectionTitle(icon: Icons.check_circle_outline, title: 'Validación de Retos'),
              const SizedBox(height: 12),

              if (_validations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2E22) : HabitikColors.green50,
                    borderRadius: HabitikRadius.lg_,
                    border: Border.all(color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green200),
                  ),
                  child: Column(children: [
                    const Text('✅', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text('No hay retos pendientes de validar', style: TextStyle(color: isDark ? Colors.white70 : HabitikColors.green600, fontWeight: FontWeight.w700)),
                  ]),
                )
              else
                ..._validations.asMap().entries.map((e) => ValidationCard(
                  validation: e.value,
                  onApprove: () => _aprobar(e.value.id),
                  onReject:  () => _rechazar(e.value.id),
                ).animate().fadeIn(delay: (e.key * 100).ms)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaSlider(String label, int value, Color color, void Function(int) onChange) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: isDark ? const Color(0x30FFFFFF) : Colors.white, width: 3.0),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 13, fontWeight: FontWeight.w800)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: HabitikRadius.xxl_),
            child: Text('$value%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ]),
        Slider(
          value: value.toDouble(),
          min: 5,
          max: 15,
          divisions: 10,
          activeColor: color,
          inactiveColor: color.withAlpha(50),
          onChanged: (v) => onChange(v.round()),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('5%', style: TextStyle(color: isDark ? Colors.white30 : HabitikColors.textDark.withAlpha(150), fontSize: 10, fontWeight: FontWeight.w700)),
          Text('15%', style: TextStyle(color: isDark ? Colors.white30 : HabitikColors.textDark.withAlpha(150), fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}
