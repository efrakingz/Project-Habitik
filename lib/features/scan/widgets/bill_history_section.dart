import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/bill_record.dart';

class MonthlyConsumptionPoint {
  const MonthlyConsumptionPoint({required this.month, required this.label, required this.total});

  final DateTime month;
  final String label;
  final double total;
}

class MonthlyConsumptionSeries {
  const MonthlyConsumptionSeries({required this.electricity, required this.water});

  final List<MonthlyConsumptionPoint> electricity;
  final List<MonthlyConsumptionPoint> water;
}

MonthlyConsumptionSeries buildMonthlyConsumptionSeries(List<BillRecord> bills) {
  List<MonthlyConsumptionPoint> buildFor(bool Function(BillRecord) matches) {
    final totals = <DateTime, double>{};
    for (final bill in bills.where(matches)) {
      final month = DateTime(bill.periodoDesde.year, bill.periodoDesde.month);
      totals[month] = (totals[month] ?? 0) + bill.consumo;
    }
    final points = totals.entries
        .map((entry) => MonthlyConsumptionPoint(month: entry.key, label: _monthLabel(entry.key.month), total: entry.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return points.length <= 6 ? points : points.sublist(points.length - 6);
  }

  return MonthlyConsumptionSeries(
    electricity: buildFor((bill) => bill.isElectricidad),
    water: buildFor((bill) => bill.isAgua),
  );
}

String _monthLabel(int month) {
  const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  return labels[month - 1];
}

class BillHistorySection extends StatelessWidget {
  const BillHistorySection({super.key, required this.bills});

  final List<BillRecord> bills;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;
    final series = buildMonthlyConsumptionSeries(bills);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consumo mensual',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : HabitikColors.green900,
          ),
        ),
        const SizedBox(height: 12),
        _MonthlyConsumptionChart(
          title: 'Consumo de electricidad',
          emptyLabel: 'Aún no hay consumo de electricidad registrado.',
          unit: 'kWh',
          icon: '⚡',
          color: HabitikColors.amber500,
          points: series.electricity,
        ),
        const SizedBox(height: 16),
        _MonthlyConsumptionChart(
          title: 'Consumo de agua',
          emptyLabel: 'Aún no hay consumo de agua registrado.',
          unit: 'm³',
          icon: '💧',
          color: HabitikColors.blue500,
          points: series.water,
        ),
      ],
    );
  }
}

class _MonthlyConsumptionChart extends StatelessWidget {
  const _MonthlyConsumptionChart({
    required this.title,
    required this.emptyLabel,
    required this.unit,
    required this.icon,
    required this.color,
    required this.points,
  });

  final String title;
  final String emptyLabel;
  final String unit;
  final String icon;
  final Color color;
  final List<MonthlyConsumptionPoint> points;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || isDarkModeNotifier.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HabitikColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : HabitikColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : HabitikColors.textDark,
                ),
              ),
              const Spacer(),
              Text(unit, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 18),
          if (points.isEmpty)
            SizedBox(
              height: 132,
              child: Center(
                child: Text(
                  emptyLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : HabitikColors.textLight,
                  ),
                ),
              ),
            )
          else
            _ChartBars(points: points, color: color, unit: unit, isDark: isDark),
        ],
      ),
    );
  }
}

class _ChartBars extends StatelessWidget {
  const _ChartBars({required this.points, required this.color, required this.unit, required this.isDark});

  final List<MonthlyConsumptionPoint> points;
  final Color color;
  final String unit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final maxTotal = points.map((point) => point.total).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 168,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points
            .map(
              (point) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatConsumption(point.total)} $unit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : HabitikColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 112,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: (point.total / maxTotal).clamp(0.08, 1.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        point.label,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : HabitikColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

String _formatConsumption(double value) {
  return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
