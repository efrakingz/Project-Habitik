import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/bill_record.dart';

class BillHistorySection extends StatelessWidget {
  const BillHistorySection({super.key, required this.bills});

  final List<BillRecord> bills;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Registro de boletas',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : HabitikColors.green900,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? HabitikColors.green500.withValues(alpha: 0.15)
                    : HabitikColors.green100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${bills.length}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? HabitikColors.green400
                      : HabitikColors.green800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (bills.isEmpty)
          _EmptyBillsState(isDark: isDark)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bills.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _BillRecordCard(bill: bills[index], isDark: isDark),
          ),
      ],
    );
  }
}

class _EmptyBillsState extends StatelessWidget {
  const _EmptyBillsState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            'Aún no hay boletas registradas',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : HabitikColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cuando confirmes una boleta, su consumo aparecerá aquí y en la evolución mensual.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: isDark ? Colors.white54 : HabitikColors.textLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRecordCard extends StatelessWidget {
  const _BillRecordCard({required this.bill, required this.isDark});

  final BillRecord bill;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isElectricity = bill.isElectricidad;
    final accent = isElectricity
        ? HabitikColors.amber500
        : HabitikColors.blue500;
    final icon = isElectricity ? '⚡' : '💧';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 21)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.proveedor,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : HabitikColors.textDark,
                  ),
                ),
                Text(
                  '${bill.tipoServicio} · ${_formatDate(bill.periodoHasta)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : HabitikColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatConsumption(bill.consumo)} ${bill.unidad}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : HabitikColors.green900,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? HabitikColors.darkCardBg : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isDark ? Colors.white12 : HabitikColors.divider),
  );
}

String _formatDate(DateTime date) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatConsumption(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}
