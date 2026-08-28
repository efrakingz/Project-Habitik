import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/session_service.dart';

class OnboardingProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onPrev;

  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (currentStep > 0) ...[
                GestureDetector(
                  onTap: onPrev,
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
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.eco, color: HabitikColors.green700, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              const Text(
                'Habitik',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text(
                        '¿Estás seguro que deseas salir? Volverás a la pantalla de inicio de sesión.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Salir', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    await SessionService().clearSession();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Salir', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paso ${currentStep + 1} de $totalSteps',
                style: const TextStyle(color: HabitikColors.green200, fontSize: 12),
              ),
              Text(
                '${((currentStep + 1) / totalSteps * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: HabitikColors.green600,
                  borderRadius: HabitikRadius.xs_,
                ),
              ),
              LayoutBuilder(
                builder: (ctx, cons) => AnimatedContainer(
                  duration: 400.ms,
                  curve: Curves.easeOut,
                  height: 8,
                  width: cons.maxWidth * ((currentStep + 1) / totalSteps),
                  decoration: BoxDecoration(
                    gradient: HabitikColors.xpGold,
                    borderRadius: HabitikRadius.xs_,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
