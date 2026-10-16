import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

class CoinValueGuide extends StatefulWidget {
  final bool initialExpanded;
  const CoinValueGuide({super.key, this.initialExpanded = false});

  @override
  State<CoinValueGuide> createState() => _CoinValueGuideState();
}

class _CoinValueGuideState extends State<CoinValueGuide> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF241D10).withValues(alpha: 0.85)
            : const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HabitikColors.amber400.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: HabitikColors.amber400.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('💡', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Cuánto vale una moneda en Habitik?',
                          style: TextStyle(
                            color: isDark ? Colors.white : HabitikColors.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Un integrante activo junta ~10 🪙 al día (~70 a la semana).',
                          style: TextStyle(
                            color: isDark ? HabitikColors.amber300 : const Color(0xFF795548),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: HabitikColors.amber400,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: HabitikColors.amber400.withValues(alpha: 0.25)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TierRow(
                    range: '5 - 20 🪙',
                    dias: '1 - 2 días',
                    ejemplo: 'Elegir el postre, 30 min extra de pantalla o saltar una tarea menor.',
                  ),
                  SizedBox(height: 8),
                  _TierRow(
                    range: '25 - 50 🪙',
                    dias: '3 - 5 días',
                    ejemplo: '1 hora de videojuegos, elegir película de la noche, tarde al parque.',
                  ),
                  SizedBox(height: 8),
                  _TierRow(
                    range: '55 - 100 🪙',
                    dias: '1 - 2 semanas',
                    ejemplo: 'Pedir pizza familiar, salida por un helado, día libre de quehaceres.',
                  ),
                  SizedBox(height: 8),
                  _TierRow(
                    range: '100 - 200 🪙',
                    dias: '2 - 3 semanas',
                    ejemplo: 'Ir al cine en familia, almuerzo especial o gran meta colectiva.',
                  ),
                  SizedBox(height: 10),
                  Text(
                    '👨‍👩‍👧‍👦 Recuerda: Los premios familiares se dividen equitativamente entre todos los miembros de la familia.',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFFFA000),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  final String range;
  final String dias;
  final String ejemplo;

  const _TierRow({
    required this.range,
    required this.dias,
    required this.ejemplo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: HabitikColors.amber400.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            range,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: Color(0xFFFFB300),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : HabitikColors.textDark,
              ),
              children: [
                TextSpan(
                  text: '($dias): ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ejemplo),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
