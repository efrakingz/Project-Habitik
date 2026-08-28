import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/cards/invite_qr_card.dart';

class StepJefeFinal extends StatelessWidget {
  final Map<String, dynamic>? mapaGastoEstimado;
  final String? inviteToken;
  final bool qrError;
  final VoidCallback onGenerateInviteToken;
  final VoidCallback onNext;
  final void Function(String msg) onShowSuccess;

  const StepJefeFinal({
    super.key,
    required this.mapaGastoEstimado,
    required this.inviteToken,
    required this.qrError,
    required this.onGenerateInviteToken,
    required this.onNext,
    required this.onShowSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final luzKwh = mapaGastoEstimado?['baseline_luz_kwh'] ?? 230;
    final aguaM3 = mapaGastoEstimado?['baseline_agua_m3'] ?? 14.0;
    final costoLuz = mapaGastoEstimado?['costo_estimado_luz'] ?? 34500;
    final costoAgua = mapaGastoEstimado?['costo_estimado_agua'] ?? 16800;
    final totalEstimado = mapaGastoEstimado?['gasto_total_estimado'] ?? 51300;
    final recs = (mapaGastoEstimado?['recomendaciones'] as List?)?.map((e) => e.toString()).toList() ?? [
      'Regula el termostato de tu calefacción eléctrica para optimizar el ahorro.'
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: HabitikColors.green100, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: HabitikColors.green700, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hogar y Metas Configurados!',
                    style: TextStyle(color: HabitikColors.textDark, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Mapa de gasto calculado. Invita a tu familia:',
                    style: TextStyle(color: HabitikColors.textLight, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sección 1: Mapa de Gasto (Horizontal en una sola fila)
        const Text(
          '🗺️ GASTO ESTIMADO DEL MES',
          style: TextStyle(color: HabitikColors.textDark, fontSize: 10.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _miniResultCard('⚡ Luz ($luzKwh kWh)', '\$${_formatMoney(costoLuz)}', HabitikColors.amber500)),
            const SizedBox(width: 6),
            Expanded(child: _miniResultCard('💧 Agua ($aguaM3 m³)', '\$${_formatMoney(costoAgua)}', Colors.blueAccent)),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: HabitikColors.heroGreen,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: HabitikShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL EST.', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('\$${_formatMoney(totalEstimado)}', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: HabitikColors.green50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HabitikColors.green200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_rounded, color: HabitikColors.green700, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  recs.first,
                  style: const TextStyle(color: HabitikColors.textDark, fontSize: 10, height: 1.25),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección 2: Código QR Centrado Abajo (Gran Tamaño y Destacado)
        InviteQrCard(
          inviteToken: inviteToken,
          qrError: qrError,
          onRetry: onGenerateInviteToken,
          onShowSuccess: onShowSuccess,
        ),

        const SizedBox(height: 18),
        PrimaryButton(label: 'Continuar a la aplicación 🚀', onTap: onNext, icon: Icons.arrow_forward_rounded),
      ],
    );
  }

  Widget _miniResultCard(String title, String monto, Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(monto, style: const TextStyle(color: HabitikColors.textDark, fontSize: 12.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  String _formatMoney(num val) {
    return val.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
