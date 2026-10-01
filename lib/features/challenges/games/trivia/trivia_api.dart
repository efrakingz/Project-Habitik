import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'models/trivia_session.dart';
import 'models/trivia_question.dart';
import 'models/trivia_answer_result.dart';
import 'models/trivia_extra_life_result.dart';
import 'models/trivia_final_result.dart';
import 'trivia_mock_data.dart';

class TriviaApi {
  final ApiClient _client;
  final bool enableMockFallback;
  bool _useMockFallback = false;

  // Estado interno para el motor de simulación mock local
  TriviaSession? _mockSession;
  int _mockQuestionIndex = 0;
  DateTime? _mockQuestionStartedAt;
  final List<TriviaMockQuestionData> _mockQuestionPool = List.from(
    kMockTriviaQuestions,
  );

  TriviaApi({ApiClient? client, this.enableMockFallback = true})
    : _client = client ?? ApiClient();

  bool get isUsingMockFallback => _useMockFallback;

  @visibleForTesting
  void forceMockFallback(bool value) {
    _useMockFallback = value;
  }

  /// Inicia o recupera una partida de Trivia
  Future<TriviaSession> iniciar() async {
    if (_useMockFallback) {
      return _iniciarMock();
    }

    try {
      final response = await _client.post('/trivia/iniciar', {});
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return TriviaSession.fromJson(data);
      }
      throw const FormatException(
        'Respuesta inválida al iniciar sesión de trivia',
      );
    } catch (e) {
      debugPrint('⚠️ [TriviaApi] Error al conectar con /trivia/iniciar: $e');
      if (enableMockFallback) {
        debugPrint(
          '🌿 [TriviaApi] Activando motor de simulación local (mock fallback)',
        );
        _useMockFallback = true;
        return _iniciarMock();
      }
      rethrow;
    }
  }

  /// Obtiene la pregunta activa o siguiente para la sesión
  Future<TriviaQuestion> obtenerPregunta(String sessionId) async {
    if (_useMockFallback) {
      return _obtenerPreguntaMock(sessionId);
    }

    try {
      final response = await _client.get(
        '/trivia/pregunta?sesion_id=$sessionId',
      );
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return TriviaQuestion.fromJson(data);
      }
      throw const FormatException(
        'Respuesta inválida al obtener pregunta de trivia',
      );
    } catch (e) {
      debugPrint('⚠️ [TriviaApi] Error al conectar con /trivia/pregunta: $e');
      if (enableMockFallback) {
        _useMockFallback = true;
        return _obtenerPreguntaMock(sessionId);
      }
      rethrow;
    }
  }

  /// Envía la respuesta seleccionada o null en caso de timeout
  Future<TriviaAnswerResult> responder(
    String sessionId,
    String questionId,
    int? selectedOption,
  ) async {
    if (_useMockFallback) {
      return _responderMock(sessionId, questionId, selectedOption);
    }

    try {
      final response = await _client.post('/trivia/respuesta', {
        'sesion_id': sessionId,
        'pregunta_id': questionId,
        'opcion_seleccionada': selectedOption,
      });
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return TriviaAnswerResult.fromJson(data);
      }
      throw const FormatException(
        'Respuesta inválida al registrar respuesta de trivia',
      );
    } catch (e) {
      debugPrint('⚠️ [TriviaApi] Error al conectar con /trivia/respuesta: $e');
      if (enableMockFallback) {
        _useMockFallback = true;
        return _responderMock(sessionId, questionId, selectedOption);
      }
      rethrow;
    }
  }

  /// Solicita la compra de 1 vida adicional por 5 monedas
  Future<TriviaExtraLifeResult> comprarVidaExtra(String sessionId) async {
    if (_useMockFallback) {
      return _comprarVidaExtraMock(sessionId);
    }

    try {
      final response = await _client.post('/trivia/vida-extra', {
        'sesion_id': sessionId,
      });
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return TriviaExtraLifeResult.fromJson(data);
      }
      throw const FormatException('Respuesta inválida al comprar vida extra');
    } catch (e) {
      debugPrint('⚠️ [TriviaApi] Error al conectar con /trivia/vida-extra: $e');
      if (enableMockFallback) {
        _useMockFallback = true;
        return _comprarVidaExtraMock(sessionId);
      }
      rethrow;
    }
  }

  /// Finaliza la partida de Trivia y consolida recompensas
  Future<TriviaFinalResult> finalizar(String sessionId) async {
    if (_useMockFallback) {
      return _finalizarMock(sessionId);
    }

    try {
      final response = await _client.post('/trivia/finalizar', {
        'sesion_id': sessionId,
      });
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return TriviaFinalResult.fromJson(data);
      }
      throw const FormatException('Respuesta inválida al finalizar trivia');
    } catch (e) {
      debugPrint('⚠️ [TriviaApi] Error al conectar con /trivia/finalizar: $e');
      if (enableMockFallback) {
        _useMockFallback = true;
        return _finalizarMock(sessionId);
      }
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Simulación Mock Local (Fallback cuando la API / tablas no están disponibles)
  // ─────────────────────────────────────────────────────────────────────────────

  TriviaSession _iniciarMock() {
    _mockQuestionIndex = 0;
    _mockSession = TriviaSession(
      sessionId: 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
      lives: 3,
      extraLifePurchased: false,
      correctCount: 0,
      accumulatedXp: 0,
      estimatedCoins: 0,
    );
    return _mockSession!;
  }

  TriviaQuestion _obtenerPreguntaMock(String sessionId) {
    if (_mockSession == null) {
      _iniciarMock();
    }
    final qIndex = _mockQuestionIndex % _mockQuestionPool.length;
    final qData = _mockQuestionPool[qIndex];
    _mockQuestionStartedAt = DateTime.now().toUtc();

    return TriviaQuestion(
      questionId: qData.questionId,
      question: qData.question,
      options: qData.options,
      category: qData.category,
      difficulty: qData.difficulty,
      timeLimitSeconds: qData.timeLimitSeconds,
      startedAt: _mockQuestionStartedAt!,
    );
  }

  TriviaAnswerResult _responderMock(
    String sessionId,
    String questionId,
    int? selectedOption,
  ) {
    _mockSession ??= _iniciarMock();

    TriviaMockQuestionData? currentQ;
    try {
      currentQ = _mockQuestionPool.firstWhere(
        (q) => q.questionId == questionId,
      );
    } catch (_) {
      final qIndex = _mockQuestionIndex % _mockQuestionPool.length;
      currentQ = _mockQuestionPool[qIndex];
    }

    final isCorrect =
        selectedOption != null && selectedOption == currentQ.correctOptionIndex;
    final elapsedSeconds = _mockQuestionStartedAt != null
        ? DateTime.now()
              .toUtc()
              .difference(_mockQuestionStartedAt!)
              .inSeconds
              .clamp(1, 30)
        : 10;

    int xpEarned = 0;
    int remainingLives = _mockSession!.lives;
    int correctCount = _mockSession!.correctCount;
    int accumulatedXp = _mockSession!.accumulatedXp;

    if (isCorrect) {
      if (elapsedSeconds <= 10) {
        xpEarned = 60;
      } else if (elapsedSeconds <= 20) {
        xpEarned = 40;
      } else {
        xpEarned = 20;
      }
      correctCount += 1;
      accumulatedXp += xpEarned;
    } else {
      xpEarned = 0;
      remainingLives = (remainingLives - 1).clamp(0, 99);
    }

    final canContinue = remainingLives > 0;
    _mockSession = _mockSession!.copyWith(
      lives: remainingLives,
      correctCount: correctCount,
      accumulatedXp: accumulatedXp,
      estimatedCoins: correctCount ~/ 5,
    );

    _mockQuestionIndex++;

    return TriviaAnswerResult(
      isCorrect: isCorrect,
      correctOption: currentQ.correctOptionIndex,
      explanation: currentQ.explanation,
      timeSeconds: elapsedSeconds,
      xpEarned: xpEarned,
      remainingLives: remainingLives,
      correctCount: correctCount,
      accumulatedXp: accumulatedXp,
      canContinue: canContinue,
    );
  }

  TriviaExtraLifeResult _comprarVidaExtraMock(String sessionId) {
    _mockSession ??= _iniciarMock();
    final user = SessionService().currentUser;
    final currentCoins = user?.monedas ?? 10;

    if (currentCoins < 5) {
      throw Exception('No tienes suficientes monedas (necesitas 5)');
    }
    if (_mockSession!.extraLifePurchased) {
      throw Exception(
        'Ya has comprado la vida extra permitida en esta partida',
      );
    }

    _mockSession = _mockSession!.copyWith(lives: 1, extraLifePurchased: true);

    return TriviaExtraLifeResult(
      lives: 1,
      coinBalance: (currentCoins - 5).clamp(0, 999999),
      extraLifePurchased: true,
    );
  }

  TriviaFinalResult _finalizarMock(String sessionId) {
    _mockSession ??= _iniciarMock();
    final user = SessionService().currentUser;
    final userXp = user?.xp ?? 0;
    final userCoins = user?.monedas ?? 0;
    final userLevel = user?.nivel ?? 1;

    final correctas = _mockSession!.correctCount;
    final totalRespondidas = _mockQuestionIndex;
    final incorrectas = (totalRespondidas - correctas).clamp(0, 9999);
    final xpGanada = _mockSession!.accumulatedXp;
    final monedasGanadas = correctas ~/ 5;

    final nuevoTotalXp = userXp + xpGanada;
    final nuevoSaldoMonedas = userCoins + monedasGanadas;

    return TriviaFinalResult(
      sessionId: _mockSession!.sessionId,
      correctCount: correctas,
      incorrectCount: incorrectas,
      xpEarned: xpGanada,
      coinsEarned: monedasGanadas,
      totalXp: nuevoTotalXp,
      coinBalance: nuevoSaldoMonedas,
      currentLevel: userLevel,
      levelUp: false,
    );
  }
}
