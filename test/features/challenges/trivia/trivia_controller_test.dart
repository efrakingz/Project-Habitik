import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/challenges/games/trivia/trivia_controller.dart';
import 'package:habitik/features/challenges/games/trivia/trivia_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TriviaController Unit Tests', () {
    late TriviaApi api;
    late TriviaController controller;

    setUp(() {
      api = TriviaApi(enableMockFallback: true);
      api.forceMockFallback(true);
      controller = TriviaController(api: api);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Inicia con estado loading y pasa a question con 3 vidas', () async {
      expect(controller.state, TriviaState.loading);

      await controller.initGame();

      expect(controller.state, TriviaState.question);
      expect(controller.lives, 3);
      expect(controller.currentQuestion, isNotNull);
      expect(controller.remainingSeconds, inInclusiveRange(1, 30));
    });

    test(
      'submitAnswer() bloquea doble envío y pasa a estado feedback',
      () async {
        await controller.initGame();

        // Enviamos opción
        final future = controller.submitAnswer(0);
        expect(controller.isSubmitting, isTrue);

        // Segundo toque mientras envía debe ser ignorado
        await controller.submitAnswer(1);

        await future;

        expect(controller.state, TriviaState.feedback);
        expect(controller.lastAnswerResult, isNotNull);
        expect(controller.isSubmitting, isFalse);
      },
    );

    test(
      'onContinueAfterFeedback() avanza a la siguiente pregunta si le quedan vidas',
      () async {
        await controller.initGame();
        final firstQId = controller.currentQuestion!.questionId;

        await controller.submitAnswer(0);
        expect(controller.state, TriviaState.feedback);

        controller.onContinueAfterFeedback();
        expect(controller.state, TriviaState.loading);

        // Esperar que cargue la siguiente pregunta
        await Future.delayed(const Duration(milliseconds: 50));
        expect(controller.state, TriviaState.question);
        expect(controller.currentQuestion!.questionId, isNot(firstQId));
      },
    );

    test(
      'Perder las 3 vidas conduce a estado outOfLives si no ha comprado vida extra',
      () async {
        await controller.initGame();

        // Fallar 3 veces consecutivas
        await controller.submitAnswer(3); // Incorrecta
        controller.onContinueAfterFeedback();
        await Future.delayed(const Duration(milliseconds: 20));

        await controller.submitAnswer(3); // Incorrecta
        controller.onContinueAfterFeedback();
        await Future.delayed(const Duration(milliseconds: 20));

        await controller.submitAnswer(3); // Incorrecta
        controller.onContinueAfterFeedback();
        await Future.delayed(const Duration(milliseconds: 20));

        expect(controller.lives, 0);
        expect(controller.state, TriviaState.outOfLives);
      },
    );

    test(
      'finishGame() consolida el resultado y pasa a estado finished',
      () async {
        await controller.initGame();
        await controller.submitAnswer(0);

        await controller.finishGame();

        expect(controller.state, TriviaState.finished);
        expect(controller.finalResult, isNotNull);
      },
    );

    test('Cancela el temporizador de manera segura en dispose()', () async {
      final localController = TriviaController(api: api);
      await localController.initGame();
      expect(() => localController.dispose(), returnsNormally);
    });
  });
}
