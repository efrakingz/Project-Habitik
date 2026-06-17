import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
      child: SafeArea(
        bottom: false,
        child: ScreenShell(
          titulo: 'Scan de Boletas',
          subtitulo: '📄 Auditoría de Consumo',
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                // 1. Escáner de Boletas Card
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
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: HabitikColors.heroGreen,
                            borderRadius: HabitikRadius.md_,
                            boxShadow: HabitikShadows.colored(HabitikColors.green600),
                          ),
                          child: const Text(
                            '📷 Escanear Boleta',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
