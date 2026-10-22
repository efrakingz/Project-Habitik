import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/rewards/widgets/coin_value_guide.dart';

void main() {
  group('CoinValueInfoModal Tests', () {
    testWidgets('renders modal bottom sheet with coin value tiers and dismisses on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => CoinValueInfoModal.show(context, isDark: false),
                  child: const Text('Abrir Guía'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to open modal
      await tester.tap(find.text('Abrir Guía'));
      await tester.pumpAndSettle();

      // Check modal content
      expect(find.text('¿Cuánto vale una moneda?'), findsOneWidget);
      expect(find.text('Ritmo de ahorro en Habitik'), findsOneWidget);
      expect(find.text('5 - 20 🪙'), findsOneWidget);
      expect(find.text('25 - 50 🪙'), findsOneWidget);
      expect(find.text('55 - 100 🪙'), findsOneWidget);
      expect(find.text('100 - 200 🪙'), findsOneWidget);
      expect(find.text('¡Entendido!'), findsOneWidget);

      // Tap '¡Entendido!' to dismiss
      await tester.tap(find.text('¡Entendido!'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cuánto vale una moneda?'), findsNothing);
    });

    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => CoinValueInfoModal.show(context, isDark: true),
                  child: const Text('Abrir Guía Oscura'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir Guía Oscura'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cuánto vale una moneda?'), findsOneWidget);
    });
  });
}
