import 'package:flutter/material.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/modals/modals.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titulo: 'Scan de Boletas',
      subtitulo: '📄 Auditoría de Consumo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            HeroBannerCard(
              emoji: '📄',
              title: 'Escáner de Boletas',
              description:
                  'Captura tu boleta de agua o luz para auditar y registrar el consumo mensual de tu hogar.',
              actionLabel: '📷 Escanear Boleta',
              onAction: () {
                ComingSoonModal.show(
                  context,
                  title: 'Escáner de Boletas',
                  emoji: '📄',
                  description:
                      'La lectura y auditoría inteligente de boletas OCR estará disponible en una próxima actualización.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
