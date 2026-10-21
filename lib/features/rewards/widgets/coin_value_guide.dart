import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final cardBg = isDark
        ? const Color(0xFF261D12)
        : const Color(0xFFFFFBEB);
    final cardBorder = isDark
        ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
        : const Color(0xFFF59E0B);
    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF78350F);
    final subtitleColor = isDark
        ? const Color(0xFFFDE68A)
        : const Color(0xFF92400E);
    final arrowColor = isDark
        ? const Color(0xFFF59E0B)
        : const Color(0xFFB45309);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFFD97706)).withValues(alpha: isDark ? 0.35 : 0.14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFFD97706), const Color(0xFFB45309)]
                            : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Cuánto vale una moneda en Habitik?',
                          style: GoogleFonts.outfit(
                            color: titleColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Un integrante activo junta ~10 monedas al día (~70 a la semana).',
                          style: GoogleFonts.outfit(
                            color: subtitleColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: arrowColor,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(
              height: 1,
              color: isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TierRow(
                    range: '5 - 20 🪙',
                    dias: '1 - 2 días',
                    ejemplo: 'Elegir el postre, 30 min extra de pantalla o saltar una tarea menor.',
                  ),
                  const SizedBox(height: 8),
                  const _TierRow(
                    range: '25 - 50 🪙',
                    dias: '3 - 5 días',
                    ejemplo: '1 hora de videojuegos, elegir película de la noche, tarde al parque.',
                  ),
                  const SizedBox(height: 8),
                  const _TierRow(
                    range: '55 - 100 🪙',
                    dias: '1 - 2 semanas',
                    ejemplo: 'Pedir pizza familiar, salida por un helado, día libre de quehaceres.',
                  ),
                  const SizedBox(height: 8),
                  const _TierRow(
                    range: '100 - 200 🪙',
                    dias: '2 - 3 semanas',
                    ejemplo: 'Ir al cine en familia, almuerzo especial o gran meta colectiva.',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFFFDE68A).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recuerda: Los premios familiares se dividen equitativamente entre todos los miembros de la familia.',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                : const Color(0xFFFDE68A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.55)
                  : const Color(0xFFD97706),
              width: 1,
            ),
          ),
          child: Text(
            range,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '($dias): ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
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
