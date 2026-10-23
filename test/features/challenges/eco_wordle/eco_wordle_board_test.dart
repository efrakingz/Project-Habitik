import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/challenges/games/eco_wordle/widgets/board.dart';
import 'package:habitik/features/challenges/games/eco_wordle/widgets/failure_overlay.dart';

void main() {
  group('EcoWordleBoard Responsive Tests', () {
    testWidgets('Renderiza tablero de 5 letras en pantalla estándar sin overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75; // ~392 x 872 dp

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 380,
                child: EcoWordleBoard(
                  rows: 6,
                  cols: 5,
                  attempts: ['VERDE'],
                  currentAttempt: 'HOJ',
                  evaluationMatrix: [
                    ['verde', 'verde', 'verde', 'verde', 'verde']
                  ],
                  currentRow: 1,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WordleCell), findsNWidgets(30)); // 6 * 5 = 30
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renderiza tablero de 6 letras en pantalla estándar sin overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 380,
                child: EcoWordleBoard(
                  rows: 6,
                  cols: 6,
                  attempts: ['PLANTA'],
                  currentAttempt: 'BOSQ',
                  evaluationMatrix: [
                    ['verde', 'gris', 'amarillo', 'verde', 'verde', 'gris']
                  ],
                  currentRow: 1,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WordleCell), findsNWidgets(36)); // 6 * 6 = 36
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renderiza tablero de 7 letras en pantalla estándar sin overflow y centrado', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 380,
                child: EcoWordleBoard(
                  rows: 6,
                  cols: 7,
                  attempts: ['ECOLOGY'],
                  currentAttempt: 'PLANET',
                  evaluationMatrix: [
                    ['verde', 'gris', 'amarillo', 'verde', 'verde', 'gris', 'amarillo']
                  ],
                  currentRow: 1,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WordleCell), findsNWidgets(42)); // 6 * 7 = 42
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renderiza tablero de 7 letras en pantalla angosta (320 dp) sin overflow', (tester) async {
      tester.view.physicalSize = const Size(640, 1000);
      tester.view.devicePixelRatio = 2.0; // 320 x 500 dp

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 340,
                child: EcoWordleBoard(
                  rows: 6,
                  cols: 7,
                  attempts: [],
                  currentAttempt: 'HABITAT',
                  evaluationMatrix: [],
                  currentRow: 0,
                  cellSize: 36,
                  cellMargin: 2.0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WordleCell), findsNWidgets(42));
      expect(tester.takeException(), isNull);
    });
  });

  group('WordleFailureOverlay Tests', () {
    testWidgets('Muestra palabra de 7 letras y contador de intentos cuando se agotan los 6 intentos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordleFailureOverlay(
              intentosUsados: 6,
              maxIntentos: 6,
              largoPalabra: 7,
              palabraCorrecta: 'COMPOST',
              pistaEducativa: 'Abono orgánico natural obtenido de la descomposición controlada de residuos.',
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('LA PALABRA ERA'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('O'), findsNWidgets(2)); // C-O-M-P-O-S-T has 2 O's
      expect(find.text('M'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('Agotaste los 6 intentos sin adivinar la palabra. ¡Mañana hay una nueva oportunidad!'), findsOneWidget);
      expect(find.text('6/6 intentos'), findsOneWidget);
    });

    testWidgets('Muestra mensaje coherente si los intentos son 5 de 6 y no pone BIOMA arbitrariamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordleFailureOverlay(
              intentosUsados: 5,
              maxIntentos: 6,
              largoPalabra: 7,
              palabraCorrecta: 'COMPOST',
              pistaEducativa: 'Abono orgánico natural obtenido de la descomposición controlada de residuos.',
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Has completado 5 de 6 intentos. ¡Mañana hay una nueva oportunidad!'), findsOneWidget);
      expect(find.text('5/6 intentos'), findsOneWidget);
      expect(find.text('B'), findsNothing); // No debe mostrar BIOMA
    });

    testWidgets('Muestra placeholders con largoPalabra si no hay palabraprovista en vez de forzar 5 letras', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordleFailureOverlay(
              intentosUsados: 6,
              maxIntentos: 6,
              largoPalabra: 7,
              palabraCorrecta: null,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Debe mostrar exactamente 7 signos de interrogación y no BIOMA (5 letras)
      expect(find.text('?'), findsNWidgets(7));
      expect(find.text('B'), findsNothing);
    });
  });
}

