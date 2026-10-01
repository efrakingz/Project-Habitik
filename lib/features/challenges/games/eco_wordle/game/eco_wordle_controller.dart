import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/shared/widgets/effects/effects.dart';
import 'package:habitik/shared/widgets/feedback/habitik_feedback.dart';
import 'package:habitik/shared/widgets/modals/modals.dart';
import '../models/eco_wordle_state.dart';
import '../services/eco_wordle_service.dart';

/// Controlador que encapsula la lógica de negocio, animaciones secuenciales y el estado del juego EcoWordle.
/// Sigue las directrices de Clean Code y arquitectura desacoplada de Habitik.
class EcoWordleController extends ChangeNotifier {
  EcoWordleState _gameState = EcoWordleState.loading;
  int _largoPalabra = 5;
  final int _maxIntentos = 6;

  List<String> _attempts = [];
  String _currentAttempt = '';
  final List<List<String>> _evaluationMatrix = [];
  final Map<String, String> _keyboardState = {};

  String? _pistaEducativa;
  bool _pistaRevelada = false;
  Map<String, dynamic>? _recompensas;
  String? _palabraCorrecta;
  bool _isProcessing = false;

  // ── Getters ──
  EcoWordleState get gameState => _gameState;
  int get largoPalabra => _largoPalabra;
  int get maxIntentos => _maxIntentos;
  List<String> get attempts => List.unmodifiable(_attempts);
  String get currentAttempt => _currentAttempt;
  List<List<String>> get evaluationMatrix => _evaluationMatrix;
  Map<String, String> get keyboardState => Map.unmodifiable(_keyboardState);
  String? get pistaEducativa => _pistaEducativa;
  bool get pistaRevelada => _pistaRevelada;
  Map<String, dynamic>? get recompensas => _recompensas;
  bool get isProcessing => _isProcessing;

  /// Retorna la palabra correcta, ya sea provista por el backend o inferida por la pista.
  String? get palabraCorrecta {
    if (_palabraCorrecta != null && _palabraCorrecta!.isNotEmpty) {
      return _palabraCorrecta;
    }
    // Fallback inteligente por pista ecológica conocida
    if (_pistaEducativa != null) {
      final p = _pistaEducativa!.toLowerCase();
      if (p.contains('comunidad ecológica') || p.contains('región')) {
        return 'BIOMA';
      }
    }
    return null;
  }

  /// Carga el estado diario del EcoWordle desde el backend y restaura las evaluaciones locales.
  Future<void> init(BuildContext context) async {
    try {
      final status = await EcoWordleService().getTodayStatus();
      if (!context.mounted) return;

      if (status != null) {
        _largoPalabra = status.largoPalabra;
        _attempts = List.from(status.intentosRealizados);
        _pistaRevelada = status.pistaRevelada;
        _pistaEducativa = status.pistaEducativa;
        if (status.palabraCorrecta != null) {
          _palabraCorrecta = status.palabraCorrecta;
        }

        // Si el usuario no tiene intentos registrados en el backend,
        // aseguramos que el teclado y la matriz comiencen completamente limpios.
        if (_attempts.isEmpty) {
          _evaluationMatrix.clear();
          _keyboardState.clear();
          await _clearLocalEvaluations();
        } else {
          // Restaurar evaluaciones locales únicamente si el usuario ya tenía intentos
          await _loadLocalEvaluations();

          if (_evaluationMatrix.length > _attempts.length) {
            _evaluationMatrix.removeRange(_attempts.length, _evaluationMatrix.length);
          }

          // Si el backend tiene intentos previos sin evaluar en caché local,
          // poblar filas con estado neutro para mantener la integridad visual del tablero.
          while (_evaluationMatrix.length < _attempts.length) {
            final idx = _evaluationMatrix.length;
            final word = _attempts[idx];
            final rowLen = word.length > _largoPalabra ? _largoPalabra : word.length;
            _evaluationMatrix.add(List.filled(rowLen, 'gris'));
            for (int i = 0; i < rowLen; i++) {
              final letter = word[i].toUpperCase();
              _keyboardState.putIfAbsent(letter, () => 'gris');
            }
          }
        }

        if (status.estado == 'ganado') {
          // El usuario ya ganó anteriormente: no mostrar recompensas ni botón de reclamar
          _gameState = EcoWordleState.alreadyWon;
          if (_evaluationMatrix.isNotEmpty) {
            _evaluationMatrix.last = List.filled(_evaluationMatrix.last.length, 'verde');
          }
        } else if (status.estado == 'perdido') {
          _gameState = EcoWordleState.failure;
        }
        notifyListeners();
      } else {
        HabitikFeedback.showError(context, 'No se pudo cargar el Eco-Wordle de hoy.');
        Navigator.maybePop(context);
      }
    } catch (e) {
      debugPrint('❌ [EcoWordleController] Error al inicializar: $e');
      if (context.mounted) {
        HabitikFeedback.showError(context, 'Error al conectar con el servidor.');
        Navigator.maybePop(context);
      }
    }
  }

  /// Concluye la pantalla de carga.
  void onLoadingComplete() {
    if (_gameState != EcoWordleState.success && _gameState != EcoWordleState.failure) {
      _gameState = EcoWordleState.start;
      notifyListeners();
    }
  }

  /// Inicia el juego activo.
  void onStartGame() {
    _gameState = EcoWordleState.playing;
    notifyListeners();
  }

  /// Inserción de letra en el intento actual.
  void onKeyPressed(String key) {
    if (_gameState != EcoWordleState.playing || _isProcessing) return;
    if (_currentAttempt.length < _largoPalabra) {
      AudioService.playSFX('click.mp3');
      _currentAttempt += key;
      notifyListeners();
    }
  }

  /// Borrado del último caracter.
  void onBackspacePressed() {
    if (_gameState != EcoWordleState.playing || _isProcessing) return;
    if (_currentAttempt.isNotEmpty) {
      AudioService.playSFX('click.mp3');
      _currentAttempt = _currentAttempt.substring(0, _currentAttempt.length - 1);
      notifyListeners();
    }
  }

  /// Envío y evaluación secuencial del intento actual con animación letra por letra.
  Future<void> onEnterPressed(BuildContext context, {VoidCallback? onChallengeCompleted}) async {
    if (_gameState != EcoWordleState.playing || _isProcessing) return;

    if (_currentAttempt.length != _largoPalabra) {
      HabitikFeedback.showInfo(context, 'La palabra debe tener $_largoPalabra letras.');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final attemptWord = _currentAttempt;
      final result = await EcoWordleService().submitAttempt(attemptWord);
      if (!context.mounted) return;

      if (result != null && result.success) {
        _attempts.add(attemptWord);
        _currentAttempt = '';
        _pistaEducativa = result.pistaEducativa;
        if (result.palabraCorrecta != null) {
          _palabraCorrecta = result.palabraCorrecta;
        }

        final rowIdx = _attempts.length - 1;
        // Inicializar fila con 'typing' antes de la revelación animada
        _evaluationMatrix.add(List.filled(attemptWord.length, 'typing'));
        notifyListeners();

        // ── Animación Secuencial: Revelación fluida letra por letra ──
        for (int c = 0; c < result.evaluacion.length; c++) {
          await Future.delayed(const Duration(milliseconds: 250));
          if (!context.mounted) return;

          final eval = result.evaluacion[c];
          _evaluationMatrix[rowIdx][c] = eval.estado;

          // Actualizar teclado para esta letra
          final existing = _keyboardState[eval.letra];
          if (existing != 'verde') {
            if (eval.estado == 'verde' || (eval.estado == 'amarillo' && existing != 'amarillo')) {
              _keyboardState[eval.letra] = eval.estado;
            } else if (existing == null) {
              _keyboardState[eval.letra] = eval.estado;
            }
          }

          AudioService.playSFX('click.mp3');
          notifyListeners();
        }

        await _saveLocalEvaluations();

        // Pausa estética tras terminar de revelar la última letra
        await Future.delayed(const Duration(milliseconds: 400));
        if (!context.mounted) return;

        if (result.estado == 'ganado') {
          _recompensas = result.recompensas;
          _gameState = EcoWordleState.success;
          if (_recompensas != null) {
            final user = SessionService().currentUser;
            if (user != null) {
              final rachaRecibida = _recompensas!['racha_dias'] as int?;
              await SessionService().updateRewardsAndXp(
                xp: user.xp + (_recompensas!['xp'] as int? ?? 0),
                monedas: user.monedas + (_recompensas!['monedas'] as int? ?? 0),
                nivel: _recompensas!['nivel_actual'] as int? ?? user.nivel,
                rachaDias: rachaRecibida ?? ((user.rachaDias == 0) ? 1 : user.rachaDias),
              );
            }
          }
          if (context.mounted) {
            CelebrationConfetti.show(context);
            // La compleción del desafío se invoca exclusivamente al pulsar el botón de reclamar recompensa en el overlay de victoria
          }
        } else if (result.estado == 'perdido') {
          _gameState = EcoWordleState.failure;
        } else {
          _gameState = EcoWordleState.playing;
        }
      } else {
        if (context.mounted) {
          HabitikFeedback.showError(context, 'Palabra no válida o error en el servidor.');
        }
      }
    } catch (e) {
      debugPrint('❌ [EcoWordleController] Error al evaluar intento: $e');
      if (context.mounted) {
        HabitikFeedback.showError(context, 'Error al enviar el intento.');
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Compra de pista educativa con monedas.
  Future<void> buyHint(BuildContext context) async {
    if (_pistaRevelada) {
      HabitikFeedback.showInfo(context, 'Ya compraste la pista: $_pistaEducativa');
      return;
    }

    final user = SessionService().currentUser;
    if (user == null || user.monedas < 3) {
      HabitikFeedback.showError(context, 'No tienes suficientes monedas (3 necesarias).');
      return;
    }

    final confirmed = await HabitikConfirmDialog.show(
      context,
      title: '¿Gastar 3 monedas para revelar la pista?',
      description: 'Te ayudará a resolver la palabra ecológica de hoy.',
      confirmLabel: 'Comprar',
    );

    if (confirmed && context.mounted) {
      final pista = await EcoWordleService().unlockHint();
      if (!context.mounted) return;

      if (pista != null) {
        _pistaRevelada = true;
        _pistaEducativa = pista;
        await SessionService().updateRewardsAndXp(
          xp: user.xp,
          monedas: user.monedas - 3,
          nivel: user.nivel,
          rachaDias: user.rachaDias,
        );
        notifyListeners();
        if (context.mounted) {
          HabitikFeedback.showSuccess(context, 'Pista: $pista');
        }
      }
    }
  }

  // ── Persistencia Local de Evaluaciones del Día (Por Usuario) ──

  String get _todayKey {
    final userId = SessionService().currentUser?.id ?? 'guest';
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    return 'wordle_${userId}_$dateStr';
  }

  Future<void> _clearLocalEvaluations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_todayKey}_eval');
      await prefs.remove('${_todayKey}_keyb');
      // Limpiar también posibles claves legacy sin userId del día de hoy
      final legacyDate = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.remove('wordle_${legacyDate}_eval');
      await prefs.remove('wordle_${legacyDate}_keyb');
    } catch (e) {
      debugPrint('⚠️ [EcoWordleController] Error al limpiar evaluaciones locales: $e');
    }
  }

  Future<void> _loadLocalEvaluations() async {
    if (_attempts.isEmpty) {
      _evaluationMatrix.clear();
      _keyboardState.clear();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final evalStr = prefs.getString('${_todayKey}_eval');
      final keybStr = prefs.getString('${_todayKey}_keyb');

      if (evalStr != null) {
        final List<dynamic> decoded = jsonDecode(evalStr);
        _evaluationMatrix.clear();
        for (final row in decoded) {
          _evaluationMatrix.add(List<String>.from(row as List));
        }
      }
      if (keybStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(keybStr);
        _keyboardState.clear();
        decoded.forEach((key, value) {
          _keyboardState[key] = value.toString();
        });
      }
    } catch (e) {
      debugPrint('⚠️ [EcoWordleController] Error al cargar evaluaciones locales: $e');
    }
  }

  Future<void> _saveLocalEvaluations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_todayKey}_eval', jsonEncode(_evaluationMatrix));
      await prefs.setString('${_todayKey}_keyb', jsonEncode(_keyboardState));
    } catch (e) {
      debugPrint('⚠️ [EcoWordleController] Error al guardar evaluaciones locales: $e');
    }
  }
}
