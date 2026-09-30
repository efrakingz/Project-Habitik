import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/challenges/games/trivia/trivia_api.dart';

void main() {
  group('TriviaApi & Mock Fallback Tests', () {
    late TriviaApi api;

    setUp(() {
      api = TriviaApi(enableMockFallback: true);
      // Forzar uso de mock fallback para pruebas unitarias de lógica offline
      api.forceMockFallback(true);
    });

    test('iniciar() retorna una sesión válida con 3 vidas y 0 XP', () async {
      final session = await api.iniciar();

      expect(session.sessionId, isNotEmpty);
      expect(session.lives, 3);
      expect(session.extraLifePurchased, isFalse);
      expect(session.correctCount, 0);
      expect(session.accumulatedXp, 0);
    });

    test(
      'obtenerPregunta() retorna pregunta con 4 alternativas y fecha',
      () async {
        final session = await api.iniciar();
        final question = await api.obtenerPregunta(session.sessionId);

        expect(question.questionId, isNotEmpty);
        expect(question.options.length, 4);
        expect(question.question, isNotEmpty);
        expect(question.timeLimitSeconds, 30);
      },
    );

    test('responder() con acierto entrega XP y mantiene vidas', () async {
      final session = await api.iniciar();
      final question = await api.obtenerPregunta(session.sessionId);

      // Enviamos opción correcta (0 para la primera pregunta del mock)
      final result = await api.responder(
        session.sessionId,
        question.questionId,
        0,
      );

      expect(result.isCorrect, isTrue);
      expect(result.xpEarned, greaterThan(0));
      expect(result.remainingLives, 3);
      expect(result.correctCount, 1);
      expect(result.canContinue, isTrue);
    });

    test(
      'responder() con error o null descuenta 1 vida y entrega 0 XP',
      () async {
        final session = await api.iniciar();
        final question = await api.obtenerPregunta(session.sessionId);

        // Timeout: seleccionada null
        final result = await api.responder(
          session.sessionId,
          question.questionId,
          null,
        );

        expect(result.isCorrect, isFalse);
        expect(result.xpEarned, 0);
        expect(result.remainingLives, 2);
        expect(result.canContinue, isTrue);
      },
    );

    test(
      'finalizar() entrega resumen con monedas calculadas (1 por cada 5 correctas)',
      () async {
        final session = await api.iniciar();
        final finalResult = await api.finalizar(session.sessionId);

        expect(finalResult.sessionId, session.sessionId);
        expect(finalResult.correctCount, isNotNull);
        expect(finalResult.incorrectCount, isNotNull);
        expect(finalResult.xpEarned, isNotNull);
        expect(finalResult.coinsEarned, isNotNull);
      },
    );

    test('comprarVidaExtra() otorga 1 vida y marca comprada', () async {
      final session = await api.iniciar();
      final result = await api.comprarVidaExtra(session.sessionId);

      expect(result.lives, 1);
      expect(result.extraLifePurchased, isTrue);
    });
  });
}
