import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/main.dart';

void main() {
  testWidgets('Habitik smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitikApp());
    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance clock past the splash timer (2.8 seconds)
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    // Clear the widget tree to dispose of all widgets and clear their animation tickers
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
