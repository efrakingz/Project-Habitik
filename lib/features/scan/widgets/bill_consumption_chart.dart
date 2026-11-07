import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/bill_record.dart';

enum BillChartService { water, electricity }

class BillMonthlyPoint {
  const BillMonthlyPoint({
    required this.month,
    required this.label,
    required this.value,
  });

  final DateTime month;
  final String label;
  final double? value;

  bool get hasValue => value != null;
}

class BillConsumptionChart extends StatefulWidget {
  const BillConsumptionChart({super.key, required this.bills});

  final List<BillRecord> bills;

  static List<BillMonthlyPoint> monthlyPoints({
    required List<BillRecord> bills,
    required BillChartService service,
    required int months,
    required DateTime now,
  }) {
    final visibleMonths = List.generate(months, (index) {
      final date = DateTime(now.year, now.month - months + 1 + index);
      return DateTime(date.year, date.month);
    });
    final totals = <DateTime, double>{};

    for (final bill in bills) {
      final matchesService = service == BillChartService.water
          ? bill.isAgua
          : bill.isElectricidad;
      if (!matchesService) continue;

      final month = DateTime(bill.periodoHasta.year, bill.periodoHasta.month);
      if (!visibleMonths.contains(month)) continue;
      totals[month] = (totals[month] ?? 0) + bill.consumo;
    }

    return visibleMonths
        .map(
          (month) => BillMonthlyPoint(
            month: month,
            label: _monthLabels[month.month - 1],
            value: totals[month],
          ),
        )
        .toList();
  }

  static const _monthLabels = [
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

  @override
  State<BillConsumptionChart> createState() => _BillConsumptionChartState();
}

class _BillConsumptionChartState extends State<BillConsumptionChart> {
  BillChartService _service = BillChartService.water;
  int _months = 6;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;
    final points = BillConsumptionChart.monthlyPoints(
      bills: widget.bills,
      service: _service,
      months: _months,
      now: DateTime.now(),
    );
    final hasValues = points.any((point) => point.hasValue);
    final isWater = _service == BillChartService.water;
    final accent = isWater ? HabitikColors.blue500 : HabitikColors.amber500;
    final unit = isWater ? 'm³' : 'kWh';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? HabitikColors.darkCardBg : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white12 : HabitikColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.15)
                  : HabitikColors.green900.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolución del consumo',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : HabitikColors.green900,
              ),
            ),
            const SizedBox(height: 12),
            _ServiceTabs(
              selected: _service,
              isDark: isDark,
              onSelected: (service) => setState(() => _service = service),
            ),
            const SizedBox(height: 12),
            _RangeSelector(
              selected: _months,
              isDark: isDark,
              onSelected: (months) => setState(() => _months = months),
            ),
            const SizedBox(height: 16),
            if (hasValues)
              SizedBox(
                height: 188,
                child: _ConsumptionLineChart(
                  points: points,
                  accent: accent,
                  unit: unit,
                  isDark: isDark,
                ),
              )
            else
              _EmptyChartState(
                serviceName: isWater ? 'agua' : 'electricidad',
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTabs extends StatelessWidget {
  const _ServiceTabs({
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  final BillChartService selected;
  final bool isDark;
  final ValueChanged<BillChartService> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Agua',
            icon: '💧',
            controlKey: const Key('bill_chart_service_water'),
            selected: selected == BillChartService.water,
            selectedColor: HabitikColors.blue500,
            isDark: isDark,
            onTap: () => onSelected(BillChartService.water),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabButton(
            label: 'Electricidad',
            icon: '⚡',
            controlKey: const Key('bill_chart_service_electricity'),
            selected: selected == BillChartService.electricity,
            selectedColor: HabitikColors.amber500,
            isDark: isDark,
            onTap: () => onSelected(BillChartService.electricity),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.controlKey,
    required this.selected,
    required this.selectedColor,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final String icon;
  final Key controlKey;
  final bool selected;
  final Color selectedColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: controlKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: isDark ? 0.28 : 0.14)
              : (isDark ? Colors.white10 : HabitikColors.green50),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? selectedColor
                : (isDark ? Colors.white12 : HabitikColors.divider),
          ),
        ),
        child: Center(
          child: Text(
            '$icon $label',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? (isDark ? Colors.white : HabitikColors.textDark)
                  : (isDark ? Colors.white70 : HabitikColors.textMid),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  final int selected;
  final bool isDark;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [3, 6, 9, 12]
          .map(
            (months) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: months == 12 ? 0 : 7),
                child: InkWell(
                  key: Key('bill_chart_range_$months'),
                  onTap: () => onSelected(months),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: selected == months
                          ? HabitikColors.green700
                          : (isDark ? Colors.white10 : HabitikColors.green50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${months}M',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: selected == months
                              ? Colors.white
                              : (isDark
                                    ? Colors.white70
                                    : HabitikColors.green800),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ConsumptionLineChart extends StatelessWidget {
  const _ConsumptionLineChart({
    required this.points,
    required this.accent,
    required this.unit,
    required this.isDark,
  });

  final List<BillMonthlyPoint> points;
  final Color accent;
  final String unit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final maximum = points
        .where((point) => point.hasValue)
        .map((point) => point.value!)
        .fold<double>(0, math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$unit por mes',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white60 : HabitikColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: CustomPaint(
            painter: _ConsumptionLinePainter(
              points: points,
              accent: accent,
              gridColor: isDark ? Colors.white12 : HabitikColors.divider,
              labelColor: isDark ? Colors.white60 : HabitikColors.textLight,
              maximum: maximum,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _ConsumptionLinePainter extends CustomPainter {
  const _ConsumptionLinePainter({
    required this.points,
    required this.accent,
    required this.gridColor,
    required this.labelColor,
    required this.maximum,
  });

  final List<BillMonthlyPoint> points;
  final Color accent;
  final Color gridColor;
  final Color labelColor;
  final double maximum;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 4.0;
    const top = 7.0;
    const bottom = 23.0;
    final chartHeight = size.height - top - bottom;
    final chartWidth = size.width - left;
    final maxValue = maximum <= 0 ? 1.0 : maximum * 1.15;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index < 3; index++) {
      final y = top + chartHeight * index / 2;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
    }

    final positions = <Offset?>[];
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final x =
          left +
          (points.length == 1 ? 0 : chartWidth * index / (points.length - 1));
      if (point.hasValue) {
        final y = top + chartHeight - (point.value! / maxValue * chartHeight);
        positions.add(Offset(x, y));
      } else {
        positions.add(null);
      }
      _paintLabel(canvas, point.label, Offset(x, size.height - 16));
    }

    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final pointPaint = Paint()..color = accent;
    Offset? previous;
    for (final position in positions) {
      if (position != null) {
        if (previous != null) canvas.drawLine(previous, position, linePaint);
        canvas.drawCircle(position, 4.5, pointPaint);
        canvas.drawCircle(position, 2.0, Paint()..color = Colors.white);
      }
      previous = position;
    }
  }

  void _paintLabel(Canvas canvas, String label, Offset center) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: labelColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy));
  }

  @override
  bool shouldRepaint(covariant _ConsumptionLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.maximum != maximum;
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState({required this.serviceName, required this.isDark});

  final String serviceName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : HabitikColors.green50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text('📈', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'Aún no hay registros de $serviceName para este período',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : HabitikColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}
