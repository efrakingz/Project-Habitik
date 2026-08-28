import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

class StepMiembroFinal extends StatelessWidget {
  final String juegoSugerido;
  final VoidCallback onNext;

  const StepMiembroFinal({
    super.key,
    required this.juegoSugerido,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    String juegoEmoji = '🎮';
    String juegoTitulo = 'Eco-Desafíos';
    String juegoDesc = 'Completa minijuegos sustentables diarios.';
    Color juegoColor = HabitikColors.green700;

    if (juegoSugerido == 'ducha') {
      juegoEmoji = '🚿';
      juegoTitulo = 'Speedrun de la Ducha';
      juegoDesc = 'Dado que te duchas más de 10 min, te sugerimos jugar hoy para controlar tu tiempo.';
      juegoColor = Colors.blue.shade700;
    } else if (juegoSugerido == 'puzzle') {
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
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: HabitikColors.green100, shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.rocket_launch_rounded, color: HabitikColors.green700, size: 40)),
        ),
        const SizedBox(height: 20),
        const Text(
          '¡Todo listo, Miembro!',
          style: TextStyle(color: HabitikColors.textDark, fontSize: 22, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Ya formas parte del hogar. Según tus hábitos de consumo, te sugerimos empezar con este Eco-Desafío hoy:',
          style: TextStyle(color: HabitikColors.textLight, fontSize: 13, height: 1.45),
          textAlign: TextAlign.center,
        ),
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
                    Text(
                      'RECOMENDACIÓN DEL DÍA',
                      style: TextStyle(color: juegoColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
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
        PrimaryButton(label: '¡Jugar ahora!', onTap: onNext, icon: Icons.play_arrow_rounded),
      ],
    );
  }
}
