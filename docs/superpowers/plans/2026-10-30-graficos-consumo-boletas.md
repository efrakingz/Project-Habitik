# Gráficos mensuales de consumo de boletas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar el historial textual del escáner de boletas por gráficos mensuales separados para electricidad y agua, sin modificar backend ni OCR.

**Architecture:** `BillHistorySection` derivará series mensuales inmutables desde `List<BillRecord>` y las mostrará en tarjetas de barras propias de Flutter. `ScanActionCard` eliminará únicamente el aviso local solicitado. Las pruebas de escaneo validarán agrupación, estados vacíos y la ausencia de etiquetas eliminadas.

**Tech Stack:** Flutter, Dart, flutter_test, Material, Google Fonts.

---

## Estructura de archivos

- Modificar: `lib/features/scan/widgets/bill_history_section.dart` — agrupación mensual y tarjetas de gráficos.
- Modificar: `lib/features/scan/widgets/scan_action_card.dart` — eliminación del aviso de privacidad local.
- Modificar: `test/features/scan/scan_bill_test.dart` — pruebas de agrupación y nueva interfaz.

### Task 1: Preparar pruebas de la nueva interfaz

**Files:**
- Modify: `test/features/scan/scan_bill_test.dart`

- [ ] **Step 1: Escribir la prueba fallida de agrupación mensual**

Agregar fuera de los widgets de prueba una función pública esperada desde `bill_history_section.dart` y verificar que suma registros del mismo mes:

```dart
test('agrupa consumo por servicio y mes', () {
  BillRecord bill(
    String id,
    String service,
    DateTime periodStart,
    double consumption,
    String unit,
  ) => BillRecord(
        id: id,
        tipoServicio: service,
        proveedor: service == 'Agua' ? 'Esval' : 'CGE',
        periodoDesde: periodStart,
        periodoHasta: periodStart.add(const Duration(days: 29)),
        consumo: consumption,
        unidad: unit,
        monto: 10000,
        fechaVencimiento: periodStart.add(const Duration(days: 40)),
        entrySource: 'manual',
        createdAt: periodStart,
      );

  final series = buildMonthlyConsumptionSeries([
    bill('e1', 'Electricidad', DateTime(2026, 8, 1), 120, 'kWh'),
    bill('e2', 'Electricidad', DateTime(2026, 8, 15), 80, 'kWh'),
    bill('a1', 'Agua', DateTime(2026, 9, 1), 15, 'm³'),
  ]);

  expect(series.electricity.single.total, 200);
  expect(series.electricity.single.label, 'Ago');
  expect(series.water.single.total, 15);
  expect(series.water.single.label, 'Sep');
});
```

- [ ] **Step 2: Ejecutar la prueba para confirmar que falla**

Run: `flutter test test/features/scan/scan_bill_test.dart --plain-name "agrupa consumo por servicio y mes"`

Expected: falla porque `buildMonthlyConsumptionSeries` no existe.

- [ ] **Step 3: Reemplazar la prueba de historial por expectativas de gráficos**

Reemplazar el test `CA-4` para exigir ambos títulos, los valores agrupados y la ausencia de metadatos:

```dart
expect(find.text('Consumo de electricidad'), findsOneWidget);
expect(find.text('Consumo de agua'), findsOneWidget);
expect(find.text('175 kWh'), findsOneWidget);
expect(find.text('18 m³'), findsOneWidget);
expect(find.textContaining('OCR Confirmado'), findsNothing);
expect(find.textContaining('Sin doc. adjunto'), findsNothing);
expect(find.textContaining('Manual'), findsNothing);
```

- [ ] **Step 4: Actualizar la prueba de `ScanActionCard`**

Cambiar el nombre del test y la expectativa del aviso:

```dart
expect(
  find.textContaining('Tu documento se procesa solo en este dispositivo'),
  findsNothing,
);
```

- [ ] **Step 5: Ejecutar pruebas para confirmar los fallos esperados**

Run: `flutter test test/features/scan/scan_bill_test.dart`

Expected: fallos relacionados solo con el historial y el aviso que se eliminará.

### Task 2: Implementar la serie mensual pura

**Files:**
- Modify: `lib/features/scan/widgets/bill_history_section.dart`
- Test: `test/features/scan/scan_bill_test.dart`

- [ ] **Step 1: Definir los tipos inmutables de datos del gráfico**

Antes de `BillHistorySection`, agregar:

```dart
class MonthlyConsumptionPoint {
  const MonthlyConsumptionPoint({
    required this.month,
    required this.label,
    required this.total,
  });

  final DateTime month;
  final String label;
  final double total;
}

class MonthlyConsumptionSeries {
  const MonthlyConsumptionSeries({
    required this.electricity,
    required this.water,
  });

  final List<MonthlyConsumptionPoint> electricity;
  final List<MonthlyConsumptionPoint> water;
}
```

- [ ] **Step 2: Implementar `buildMonthlyConsumptionSeries`**

Agregar una función pura que use `periodoDesde`, normalice cada mes a `DateTime(year, month)`, sume `consumo` por clave `servicio-año-mes`, ordene cronológicamente y conserve los últimos seis puntos por servicio:

```dart
MonthlyConsumptionSeries buildMonthlyConsumptionSeries(List<BillRecord> bills) {
  List<MonthlyConsumptionPoint> buildFor(bool Function(BillRecord) matches) {
    final totals = <DateTime, double>{};
    for (final bill in bills.where(matches)) {
      final month = DateTime(bill.periodoDesde.year, bill.periodoDesde.month);
      totals[month] = (totals[month] ?? 0) + bill.consumo;
    }
    final points = totals.entries
        .map((entry) => MonthlyConsumptionPoint(
              month: entry.key,
              label: DateFormat('MMM', 'es_CL').format(entry.key),
              total: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return points.length <= 6 ? points : points.sublist(points.length - 6);
  }

  return MonthlyConsumptionSeries(
    electricity: buildFor((bill) => bill.isElectricidad),
    water: buildFor((bill) => bill.isAgua),
  );
}
```

- [ ] **Step 3: Ejecutar la prueba de agrupación**

Run: `flutter test test/features/scan/scan_bill_test.dart --plain-name "agrupa consumo por servicio y mes"`

Expected: PASS.

- [ ] **Step 4: Commit de la lógica pura**

```bash
git add lib/features/scan/widgets/bill_history_section.dart test/features/scan/scan_bill_test.dart
git commit -m "feat(scan): agrupa consumo mensual de boletas"
```

### Task 3: Renderizar gráficos separados y eliminar metadatos

**Files:**
- Modify: `lib/features/scan/widgets/bill_history_section.dart`
- Test: `test/features/scan/scan_bill_test.dart`

- [ ] **Step 1: Reemplazar el `ListView.separated` por dos tarjetas de gráfico**

Dentro de `BillHistorySection.build`, crear la serie una vez y renderizar:

```dart
final series = buildMonthlyConsumptionSeries(bills);

_MonthlyConsumptionChart(
  title: 'Consumo de electricidad',
  unit: 'kWh',
  icon: '⚡',
  color: HabitikColors.amber500,
  points: series.electricity,
),
const SizedBox(height: 16),
_MonthlyConsumptionChart(
  title: 'Consumo de agua',
  unit: 'm³',
  icon: '💧',
  color: HabitikColors.blue500,
  points: series.water,
),
```

- [ ] **Step 2: Crear el widget privado `_MonthlyConsumptionChart`**

El widget recibe título, unidad, color y puntos. Para cada punto, usar `Expanded` con un `Column` que incluya el total formateado, un `FractionallySizedBox(heightFactor: point.total / maxTotal)` con altura máxima de 132 px, y el mes. Cuando `points.isEmpty`, mostrar `Aún no hay consumo de <servicio> registrado.` sin ocultar la otra tarjeta.

- [ ] **Step 3: Eliminar las tarjetas por boleta y sus etiquetas**

No renderizar proveedor, monto, nombre de documento, `entrySource`, OCR, manual ni estado de adjunto. Mantener el encabezado como `Consumo mensual` y reemplazar el contador por el total de registros solo si aporta contexto visual; no mostrar el nombre “Historial de Auditoría”.

- [ ] **Step 4: Ejecutar los tests de widgets actualizados**

Run: `flutter test test/features/scan/scan_bill_test.dart --plain-name "CA-4"`

Expected: PASS y ninguna ocurrencia visible de `OCR Confirmado`, `Manual` o `Sin doc. adjunto`.

- [ ] **Step 5: Commit de la interfaz de gráficos**

```bash
git add lib/features/scan/widgets/bill_history_section.dart test/features/scan/scan_bill_test.dart
git commit -m "feat(scan): muestra graficos mensuales por servicio"
```

### Task 4: Eliminar aviso de procesamiento local y validar

**Files:**
- Modify: `lib/features/scan/widgets/scan_action_card.dart`
- Test: `test/features/scan/scan_bill_test.dart`

- [ ] **Step 1: Eliminar el bloque de aviso**

En `ScanActionCard.build`, eliminar desde el `SizedBox(height: 18)` posterior a las opciones hasta el `Container` con `Icons.shield_outlined`, incluyendo el texto de procesamiento local. Conservar las cuatro acciones y su espaciado final.

- [ ] **Step 2: Ejecutar la prueba de la tarjeta**

Run: `flutter test test/features/scan/scan_bill_test.dart --plain-name "ScanActionCard"`

Expected: PASS; las cuatro acciones siguen visibles y el aviso no existe.

- [ ] **Step 3: Ejecutar validación completa de la función**

Run: `flutter test test/features/scan/scan_bill_test.dart --reporter compact`

Expected: todos los tests PASS.

- [ ] **Step 4: Ejecutar análisis estático**

Run: `flutter analyze lib/features/scan/widgets test/features/scan/scan_bill_test.dart`

Expected: `No issues found!`.

- [ ] **Step 5: Commit final**

```bash
git add lib/features/scan/widgets/scan_action_card.dart test/features/scan/scan_bill_test.dart
git commit -m "refactor(scan): simplifica historial y aviso documental"
```
