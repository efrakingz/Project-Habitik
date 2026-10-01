import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/challenges/games/trivia/widgets/trivia_start_overlay.dart';
import 'package:habitik/features/challenges/games/trivia/widgets/trivia_header.dart';
import 'package:habitik/features/challenges/games/trivia/widgets/answer_option.dart';
import 'package:habitik/features/challenges/games/trivia/widgets/answer_feedback.dart';
import 'package:habitik/features/challenges/games/trivia/widgets/extra_life_dialog.dart';
import 'package:habitik/features/challenges/games/trivia/widgets/trivia_result.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_answer_result.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_final_result.dart';

void main() {
  group('Trivia Widgets Tests', () {
    testWidgets('TriviaStartOverlay muestra reglas y botón para comenzar', (
      tester,
    ) async {
      bool started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TriviaStartOverlay(
              onStart: () => started = true,
              onExit: () {},
            ),
          ),
        ),
      );

      expect(find.text('Trivia Ambiental'), findsOneWidget);
      expect(find.textContaining('3 Vidas'), findsOneWidget);
      expect(find.textContaining('30 Segundos'), findsOneWidget);
      expect(find.text('¡COMENZAR TRIVIA!'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('¡COMENZAR TRIVIA!'), 100);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('¡COMENZAR TRIVIA!'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(started, isTrue);
    });

    testWidgets('TriviaHeader muestra 3 corazones, tiempo y stats', (
      tester,
    ) async {
      bool exited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TriviaHeader(
              lives: 2,
              remainingSeconds: 25,
              correctCount: 4,
              accumulatedXp: 180,
              onExit: () => exited = true,
            ),
          ),
        ),
      );

      expect(find.text('Trivia Ambiental'), findsOneWidget);
      expect(find.text('25s'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('180 XP'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(exited, isTrue);
    });

    testWidgets('AnswerOption muestra letra, texto y responde al toque', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerOption(
              index: 0,
              text: 'Desenchufar aparatos',
              state: AnswerOptionState.defaultState,
              isDisabled: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('Desenchufar aparatos'), findsOneWidget);

      await tester.tap(find.text('Desenchufar aparatos'));
      expect(tapped, isTrue);
    });

    testWidgets('AnswerFeedbackBanner muestra resultado y explicación', (
      tester,
    ) async {
      bool continued = false;
      const result = TriviaAnswerResult(
        isCorrect: true,
        correctOption: 1,
        explanation: 'Ahorras mucha energía.',
        timeSeconds: 5,
        xpEarned: 60,
        remainingLives: 3,
        correctCount: 1,
        accumulatedXp: 60,
        canContinue: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerFeedbackBanner(
              result: result,
              onContinue: () => continued = true,
            ),
          ),
        ),
      );

      expect(find.text('¡Respuesta Correcta!'), findsOneWidget);
      expect(find.text('Ahorras mucha energía.'), findsOneWidget);
      expect(find.text('CONTINUAR'), findsOneWidget);

      await tester.tap(find.text('CONTINUAR'));
      expect(continued, isTrue);
    });

    testWidgets('ExtraLifeDialog muestra costo de 5 monedas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExtraLifeDialog(onBuyLife: () {}, onFinish: () {}),
          ),
        ),
      );

      expect(find.text('¡Te has quedado sin vidas!'), findsOneWidget);
      expect(find.text('5 monedas'), findsOneWidget);
      expect(find.text('TERMINAR PARTIDA'), findsOneWidget);
    });

    testWidgets('TriviaResultView muestra resumen de aciertos y monedas', (
      tester,
    ) async {
      bool closed = false;
      const finalResult = TriviaFinalResult(
        sessionId: 'sess-test',
        correctCount: 8,
        incorrectCount: 2,
        xpEarned: 360,
        coinsEarned: 1,
        totalXp: 1200,
        coinBalance: 20,
        currentLevel: 3,
        levelUp: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TriviaResultView(
              result: finalResult,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('¡Partida Finalizada!'), findsOneWidget);
      expect(find.text('8'), findsOneWidget); // Aciertos
      expect(find.text('+360'), findsOneWidget); // XP
      expect(find.text('+1'), findsOneWidget); // Monedas
      expect(find.text('¡RECLAMAR RECOMPENSA! ✨'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('¡RECLAMAR RECOMPENSA! ✨'), 100);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('¡RECLAMAR RECOMPENSA! ✨'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(closed, isTrue);
    });

    testWidgets('Responsividad en pantalla pequeña (320x480) sin overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TriviaStartOverlay(onStart: () {}, onExit: () {}),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
