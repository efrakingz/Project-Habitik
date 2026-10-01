import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:habitik/core/services/session_service.dart';
import 'models/trivia_session.dart';
import 'models/trivia_question.dart';
import 'models/trivia_answer_result.dart';
import 'models/trivia_final_result.dart';
import 'trivia_api.dart';

enum TriviaState {
  loading,
  question,
  submitting,
  feedback,
  outOfLives,
  finished,
  error,
}

class TriviaController extends ChangeNotifier {
  final TriviaApi api;
  final SessionService _sessionService;

  TriviaState _state = TriviaState.loading;
  TriviaSession? _session;
  TriviaQuestion? _currentQuestion;
  TriviaAnswerResult? _lastAnswerResult;
  TriviaFinalResult? _finalResult;

  int _remainingSeconds = 30;
  int? _selectedOptionIndex;
  bool _isSubmitting = false;
  String? _errorMessage;
  Timer? _timer;

  TriviaController({TriviaApi? api, SessionService? sessionService})
    : api = api ?? TriviaApi(),
      _sessionService = sessionService ?? SessionService();

  // ── Getters públicos ────────────────────────────────────────────────────────
  TriviaState get state => _state;
  TriviaSession? get session => _session;
  TriviaQuestion? get currentQuestion => _currentQuestion;
  TriviaAnswerResult? get lastAnswerResult => _lastAnswerResult;
  TriviaFinalResult? get finalResult => _finalResult;
  int get remainingSeconds => _remainingSeconds;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get lives => _session?.lives ?? 3;
  int get correctCount => _session?.correctCount ?? 0;
  int get accumulatedXp => _session?.accumulatedXp ?? 0;
  bool get canBuyExtraLife =>
      _session != null &&
      _session!.lives <= 0 &&
      !_session!.extraLifePurchased &&
      ((_sessionService.currentUser?.monedas ?? 0) >= 5);

  /// Inicializa la partida o recupera una existente
  Future<void> initGame() async {
    _cancelTimer();
    _setState(TriviaState.loading);
    _errorMessage = null;

    try {
      _session = await api.iniciar();
      await nextQuestion();
    } catch (e) {
      debugPrint('❌ [TriviaController] Error al iniciar partida: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(TriviaState.error);
    }
  }

  /// Solicita la siguiente pregunta y sincroniza el temporizador
  Future<void> nextQuestion() async {
    if (_session == null) {
      await initGame();
      return;
    }

    if (_session!.lives <= 0) {
      if (!_session!.extraLifePurchased) {
        _setState(TriviaState.outOfLives);
      } else {
        await finishGame();
      }
      return;
    }

    _cancelTimer();
    _setState(TriviaState.loading);
    _selectedOptionIndex = null;
    _lastAnswerResult = null;
    _errorMessage = null;

    try {
      final question = await api.obtenerPregunta(_session!.sessionId);
      _currentQuestion = question;

      // Calcular tiempo restante: otorgar el tiempo límite completo de la pregunta
      // evitando timeouts prematuros causados por desincronización de reloj o preguntas pendientes
      final limit = question.timeLimitSeconds > 0
          ? question.timeLimitSeconds
          : 30;
      final nowUtc = DateTime.now().toUtc();
      final elapsed = nowUtc.difference(question.startedAt.toUtc()).inSeconds;

      int remaining = limit;
      if (elapsed > 0 && elapsed < (limit - 5)) {
        remaining = limit - elapsed;
      } else {
        remaining = limit;
      }

      _remainingSeconds = remaining;
      _setState(TriviaState.question);
      _startTimer();
    } catch (e) {
      debugPrint('❌ [TriviaController] Error al obtener pregunta: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(TriviaState.error);
    }
  }

  /// Inicia el temporizador de cuenta regresiva
  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        _cancelTimer();
        notifyListeners();
        // Timeout automático: envía respuesta vacía (null)
        submitAnswer(null);
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Envía la respuesta del usuario con protección anti-doble toque
  Future<void> submitAnswer(int? optionIndex) async {
    if (_isSubmitting || _state != TriviaState.question) return;
    if (_session == null || _currentQuestion == null) return;

    _isSubmitting = true;
    _cancelTimer();
    _selectedOptionIndex = optionIndex;
    _setState(TriviaState.submitting);

    try {
      final result = await api.responder(
        _session!.sessionId,
        _currentQuestion!.questionId,
        optionIndex,
      );

      _lastAnswerResult = result;
      _session = _session!.copyWith(
        lives: result.remainingLives,
        correctCount: result.correctCount,
        accumulatedXp: result.accumulatedXp,
      );

      // Feedback táctil según acierto o error (seguro ante entornos de pruebas)
      try {
        if (result.isCorrect) {
          await HapticFeedback.lightImpact();
        } else {
          await HapticFeedback.mediumImpact();
        }
      } catch (_) {}

      _isSubmitting = false;
      _setState(TriviaState.feedback);
    } catch (e) {
      _isSubmitting = false;
      debugPrint('❌ [TriviaController] Error al enviar respuesta: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(TriviaState.error);
    }
  }

  /// Continúa al siguiente estado tras revisar el banner de feedback
  void onContinueAfterFeedback() {
    if (_lastAnswerResult?.canContinue == true && (_session?.lives ?? 0) > 0) {
      nextQuestion();
    } else {
      if (_session != null && !_session!.extraLifePurchased) {
        _setState(TriviaState.outOfLives);
      } else {
        finishGame();
      }
    }
  }

  /// Compra 1 vida extra por 5 monedas si cumple los requisitos
  Future<bool> buyExtraLife() async {
    if (_session == null || _isSubmitting) return false;

    _isSubmitting = true;
    _cancelTimer();
    _setState(TriviaState.loading);

    try {
      final result = await api.comprarVidaExtra(_session!.sessionId);
      _session = _session!.copyWith(
        lives: result.lives,
        extraLifePurchased: true,
      );

      // Descontar monedas en el perfil local en tiempo real
      final current = _sessionService.currentUser;
      if (current != null) {
        await _sessionService.updateRewardsAndXp(monedas: result.coinBalance);
      }

      _isSubmitting = false;
      await nextQuestion();
      return true;
    } catch (e) {
      _isSubmitting = false;
      debugPrint('❌ [TriviaController] Error al comprar vida extra: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setState(TriviaState.error);
      return false;
    }
  }

  /// Finaliza la partida, consolida recompensas y actualiza perfil local
  Future<void> finishGame() async {
    if (_session == null) {
      _setState(TriviaState.finished);
      return;
    }

    _cancelTimer();
    _setState(TriviaState.loading);

    try {
      final result = await api.finalizar(_session!.sessionId);
      _finalResult = result;

      // Actualizar perfil local de sesión en tiempo real
      await _sessionService.updateRewardsAndXp(
        xp: result.totalXp,
        monedas: result.coinBalance,
        nivel: result.currentLevel,
      );

      _setState(TriviaState.finished);
    } catch (e) {
      debugPrint('❌ [TriviaController] Error al finalizar partida: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      // Incluso ante error de red al finalizar, consolidamos lo visible localmente
      final fallbackResult = TriviaFinalResult(
        sessionId: _session?.sessionId ?? '',
        correctCount: _session?.correctCount ?? 0,
        incorrectCount: 3,
        xpEarned: _session?.accumulatedXp ?? 0,
        coinsEarned: (_session?.correctCount ?? 0) ~/ 5,
        totalXp:
            (_sessionService.currentUser?.xp ?? 0) +
            (_session?.accumulatedXp ?? 0),
        coinBalance:
            (_sessionService.currentUser?.monedas ?? 0) +
            ((_session?.correctCount ?? 0) ~/ 5),
        currentLevel: _sessionService.currentUser?.nivel ?? 1,
        levelUp: false,
      );
      _finalResult = fallbackResult;
      _setState(TriviaState.finished);
    }
  }

  /// Reintenta la última acción tras un error
  Future<void> retry() async {
    if (_session == null) {
      await initGame();
    } else if (_currentQuestion == null) {
      await nextQuestion();
    } else {
      await nextQuestion();
    }
  }

  void _setState(TriviaState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
