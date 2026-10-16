import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';

void main() {
  group('HabitikErrorView Widget Tests', () {
    testWidgets('renders full view with message and triggers onRetry', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitikErrorView(
              title: 'Error de Red',
              message: 'Exception: Falló la conexión al servidor',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Error de Red'), findsOneWidget);
      // 'Exception: ' should be cleaned
      expect(find.text('Falló la conexión al servidor'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('renders compact view correctly and triggers onRetry', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitikErrorView.compact(
              message: 'No se pudieron cargar los datos',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('No se pudieron cargar los datos'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('renders default fallback message when message is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HabitikErrorView(),
          ),
        ),
      );

      expect(
        find.text('Ocurrió un problema inesperado. Por favor, intenta de nuevo.'),
        findsOneWidget,
      );
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
