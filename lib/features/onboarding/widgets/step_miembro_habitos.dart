import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/inputs/option_chip_group.dart';

class StepMiembroHabitos extends StatelessWidget {
  final String tiempoDucha;
  final ValueChanged<String> onTiempoDuchaChanged;
  final String lucesEncendidas;
  final ValueChanged<String> onLucesEncendidasChanged;
  final String reciclaje;
  final ValueChanged<String> onReciclajeChanged;
  final VoidCallback onSubmit;

  const StepMiembroHabitos({
    super.key,
    required this.tiempoDucha,
    required this.onTiempoDuchaChanged,
    required this.lucesEncendidas,
    required this.onLucesEncendidasChanged,
    required this.reciclaje,
    required this.onReciclajeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          '📊 Tus Hábitos',
          'Responde con honestidad para personalizar tu experiencia',
        ),
        const SizedBox(height: 20),

        // Pregunta 1
        _questionCat('💧 Agua'),
        const SizedBox(height: 4),
        _questionLabel('¿Cuánto tiempo duras en la ducha aproximadamente?'),
        const SizedBox(height: 8),
        OptionChipGroup(
          options: const ['< 5 min', '5-10 min', '10-15 min', '> 15 min'],
          selectedValue: tiempoDucha,
          onSelected: onTiempoDuchaChanged,
        ),
        const SizedBox(height: 20),

        // Pregunta 2
        _questionCat('📱 Pantallas'),
        const SizedBox(height: 4),
        _questionLabel(
          '¿Cuántas horas al día utilizas pantallas (TV, celular, PC)?',
        ),
        const SizedBox(height: 8),
        OptionChipGroup(
          options: const ['< 3 horas', '3-6 horas', '> 6 horas'],
          selectedValue: lucesEncendidas,
          onSelected: onLucesEncendidasChanged,
        ),
        const SizedBox(height: 20),

        // Pregunta 3
        _questionCat('♻️ Reciclaje'),
        const SizedBox(height: 4),
        _questionLabel('¿Qué tan seguido reciclas botellas o plásticos?'),
        const SizedBox(height: 8),
        OptionChipGroup(
          options: const ['Nunca', 'A veces', 'Siempre'],
          selectedValue: reciclaje,
          onSelected: onReciclajeChanged,
        ),

        const SizedBox(height: 28),

        PrimaryButton(
          label: 'Guardar Hábitos',
          onTap: onSubmit,
          icon: Icons.arrow_forward,
        ),
      ],
    );
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: HabitikColors.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: HabitikColors.green500, fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _questionCat(String cat) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: HabitikColors.green100,
      borderRadius: HabitikRadius.xxl_,
    ),
    child: Text(
      cat,
      style: const TextStyle(
        color: HabitikColors.textDark,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _questionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: HabitikColors.textDark,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    ),
  );
}
