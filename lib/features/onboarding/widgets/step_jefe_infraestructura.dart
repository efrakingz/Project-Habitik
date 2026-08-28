import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/inputs/option_chip_group.dart';

class StepJefeInfraestructura extends StatelessWidget {
  final int personasCount;
  final ValueChanged<int> onPersonasChanged;
  final int habitacionesCount;
  final ValueChanged<int> onHabitacionesChanged;
  final String tipoCalefaccion;
  final ValueChanged<String> onCalefaccionChanged;
  final List<String> electrodomesticos;
  final VoidCallback onToggleElectrodomestico;
  final ValueChanged<String> onToggleElectrodomesticoItem;
  final VoidCallback onSubmit;

  const StepJefeInfraestructura({
    super.key,
    required this.personasCount,
    required this.onPersonasChanged,
    required this.habitacionesCount,
    required this.onHabitacionesChanged,
    required this.tipoCalefaccion,
    required this.onCalefaccionChanged,
    required this.electrodomesticos,
    required this.onToggleElectrodomestico,
    required this.onToggleElectrodomesticoItem,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
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
        OptionChipGroup(
          options: const ['1', '2', '3', '4', '5+'],
          selectedValue: personasCount >= 5 ? '5+' : personasCount.toString(),
          onSelected: (v) => onPersonasChanged(v == '5+' ? 5 : int.parse(v)),
        ),
        const SizedBox(height: 20),

        // Pregunta 2: Habitaciones
        _questionCat('🚪 Habitaciones'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuántas habitaciones tiene tu hogar?'),
        const SizedBox(height: 8),
        OptionChipGroup(
          options: const ['1', '2', '3', '4', '5+'],
          selectedValue: habitacionesCount >= 5 ? '5+' : habitacionesCount.toString(),
          onSelected: (v) => onHabitacionesChanged(v == '5+' ? 5 : int.parse(v)),
        ),
        const SizedBox(height: 20),

        // Pregunta 3: Calefacción
        _questionCat('🔥 Calefacción'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuál es el tipo de calefacción principal?'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            {'id': 'electrica', 'label': '⚡ Eléctrica'},
            {'id': 'gas', 'label': '🔥 Gas'},
            {'id': 'lena', 'label': '🪵 Leña'},
            {'id': 'otra', 'label': '🌿 Otra'},
          ].map((item) {
            final sel = tipoCalefaccion == item['id'];
            return GestureDetector(
              onTap: () => onCalefaccionChanged(item['id']!),
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: sel
                      ? HabitikColors.heroGreen
                      : const LinearGradient(colors: [HabitikColors.green50, HabitikColors.green50]),
                  borderRadius: HabitikRadius.md_,
                  border: Border.all(color: sel ? HabitikColors.green600 : HabitikColors.divider),
                ),
                child: Text(
                  item['label']!,
                  style: TextStyle(
                    color: sel ? Colors.white : HabitikColors.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Pregunta 4: Electrodomésticos
        _questionCat('🔌 Electrodomésticos'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuáles electrodomésticos de alto consumo tienen?'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            {'id': 'lavadora', 'label': '🧺 Lavadora'},
            {'id': 'secadora', 'label': '☀️ Secadora'},
            {'id': 'lavavajillas', 'label': '🍽️ Lavavajillas'},
            {'id': 'aire_acondicionado', 'label': '❄️ Aire Acondicionado'},
          ].map((app) {
            final selected = electrodomesticos.contains(app['id']);
            return GestureDetector(
              onTap: () => onToggleElectrodomesticoItem(app['id']!),
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
                  app['label']!,
                  style: TextStyle(
                    color: selected ? Colors.white : HabitikColors.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        PrimaryButton(label: 'Guardar Cuestionario', onTap: onSubmit, icon: Icons.arrow_forward),
      ],
    );
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: HabitikColors.textDark, fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: HabitikColors.green500, fontSize: 12.5)),
      ],
    );
  }

  Widget _questionCat(String cat) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: HabitikColors.green100, borderRadius: HabitikRadius.xxl_),
        child: Text(cat, style: const TextStyle(color: HabitikColors.textDark, fontSize: 10, fontWeight: FontWeight.w800)),
      );

  Widget _questionLabel(String label) => Text(
        label,
        style: const TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.w700, fontSize: 13),
      );
}
