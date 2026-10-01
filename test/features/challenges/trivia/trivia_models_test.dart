import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_session.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_question.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_answer_result.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_extra_life_result.dart';
import 'package:habitik/features/challenges/games/trivia/models/trivia_final_result.dart';

void main() {
  group('TriviaSession Model Tests', () {
    test('Parsea correctamente JSON válido de sesión', () {
      final json = {
        'sesion_id': 'sess-1234',
        'vidas': 3,
        'vida_extra_comprada': false,
        'correctas': 2,
        'xp_acumulada': 100,
        'monedas_estimadas': 0,
      };

      final session = TriviaSession.fromJson(json);

      expect(session.sessionId, 'sess-1234');
      expect(session.lives, 3);
      expect(session.extraLifePurchased, isFalse);
      expect(session.correctCount, 2);
      expect(session.accumulatedXp, 100);
      expect(session.estimatedCoins, 0);
    });

    test('Serializa y clona con copyWith', () {
      const session = TriviaSession(
        sessionId: 'sess-1',
        lives: 3,
        extraLifePurchased: false,
        correctCount: 1,
        accumulatedXp: 40,
        estimatedCoins: 0,
      );

      final updated = session.copyWith(lives: 2, extraLifePurchased: true);
      expect(updated.lives, 2);
      expect(updated.extraLifePurchased, isTrue);
      expect(updated.sessionId, 'sess-1');

      final map = updated.toJson();
      expect(map['vidas'], 2);
      expect(map['vida_extra_comprada'], isTrue);
    });
  });

  group('TriviaQuestion Model Tests', () {
    test('Parsea exitosamente pregunta con exactamente 4 alternativas', () {
      final json = {
        'pregunta_id': 'q-100',
        'pregunta': '¿Qué residuo se deposita en el contenedor azul?',
        'alternativas': ['Papel y cartón', 'Vidrio', 'Pilas', 'Plástico'],
        'categoria': 'reciclaje',
        'dificultad': 'facil',
        'limite_segundos': 30,
        'iniciada_en': '2026-09-30T12:00:00.000Z',
      };

      final question = TriviaQuestion.fromJson(json);

      expect(question.questionId, 'q-100');
      expect(question.options.length, 4);
      expect(question.category, 'reciclaje');
      expect(question.difficulty, 'facil');
      expect(question.timeLimitSeconds, 30);
      expect(question.startedAt.isUtc, isTrue);
    });

    test('Lanza FormatException si tiene menos de 4 alternativas', () {
      final json = {
        'pregunta_id': 'q-101',
        'pregunta': 'Pregunta corta',
        'alternativas': ['A', 'B', 'C'],
      };

      expect(() => TriviaQuestion.fromJson(json), throwsFormatException);
    });

    test('Lanza FormatException si tiene más de 4 alternativas', () {
      final json = {
        'pregunta_id': 'q-102',
        'pregunta': 'Pregunta larga',
        'alternativas': ['A', 'B', 'C', 'D', 'E'],
      };

      expect(() => TriviaQuestion.fromJson(json), throwsFormatException);
    });

    test('Lanza FormatException si alguna alternativa está vacía', () {
      final json = {
        'pregunta_id': 'q-103',
        'pregunta': 'Pregunta con vacío',
        'alternativas': ['A', ' ', 'C', 'D'],
      };

      expect(() => TriviaQuestion.fromJson(json), throwsFormatException);
    });

    test('Lanza FormatException si faltan datos esenciales de pregunta', () {
      final json = {
        'pregunta_id': '',
        'pregunta': '',
        'alternativas': ['A', 'B', 'C', 'D'],
      };

      expect(() => TriviaQuestion.fromJson(json), throwsFormatException);
    });
  });

  group('TriviaAnswerResult Model Tests', () {
    test('Parsea respuesta correcta con feedback y XP', () {
      final json = {
        'correcta': true,
        'opcion_correcta': 2,
        'explicacion': 'Excelente decisión ecológica.',
        'tiempo_segundos': 8,
        'xp_ganada': 60,
        'vidas_restantes': 3,
        'correctas': 1,
        'xp_acumulada': 60,
        'puede_continuar': true,
      };

      final result = TriviaAnswerResult.fromJson(json);

      expect(result.isCorrect, isTrue);
      expect(result.correctOption, 2);
      expect(result.explanation, 'Excelente decisión ecológica.');
      expect(result.xpEarned, 60);
      expect(result.canContinue, isTrue);
    });

    test('Parsea respuesta incorrecta con pérdida de vida', () {
      final json = {
        'correcta': false,
        'opcion_correcta': 0,
        'explicacion': 'El plástico dura siglos.',
        'tiempo_segundos': 15,
        'xp_ganada': 0,
        'vidas_restantes': 2,
        'correctas': 0,
        'xp_acumulada': 0,
        'puede_continuar': true,
      };

      final result = TriviaAnswerResult.fromJson(json);

      expect(result.isCorrect, isFalse);
      expect(result.correctOption, 0);
      expect(result.remainingLives, 2);
      expect(result.xpEarned, 0);
    });
  });

  group('TriviaExtraLifeResult Model Tests', () {
    test('Parsea respuesta de compra de vida extra', () {
      final json = {
        'vidas': 1,
        'saldo_monedas': 12,
        'vida_extra_comprada': true,
      };

      final result = TriviaExtraLifeResult.fromJson(json);

      expect(result.lives, 1);
      expect(result.coinBalance, 12);
      expect(result.extraLifePurchased, isTrue);
    });
  });

  group('TriviaFinalResult Model Tests', () {
    test('Parsea resumen final con subida de nivel', () {
      final json = {
        'sesion_id': 'sess-fin-99',
        'correctas': 10,
        'incorrectas': 2,
        'xp_ganada': 450,
        'monedas_ganadas': 2,
        'xp_total': 1800,
        'saldo_monedas': 25,
        'nivel_actual': 4,
        'level_up': true,
      };

      final result = TriviaFinalResult.fromJson(json);

      expect(result.sessionId, 'sess-fin-99');
      expect(result.correctCount, 10);
      expect(result.incorrectCount, 2);
      expect(result.xpEarned, 450);
      expect(result.coinsEarned, 2);
      expect(result.levelUp, isTrue);
      expect(result.currentLevel, 4);
    });
  });
}
