import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/history_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'models/speedrun_state.dart';
import 'components/background_component.dart';

class SpeedrunGame extends FlameGame {
  final VoidCallback? onGameClosed;
  final VoidCallback? onChallengeCompleted;

  SpeedrunState _gameState = SpeedrunState.loading;

  // Temporizador de preparación: 30 segundos
  double prepRemainingSeconds = 30.0;
  // Cronómetro de la ducha (cuenta hacia adelante)
  double elapsedShowerSeconds = 0.0;
  double elapsedTime = 0.0;

  // Guarda el tiempo en que se resolvió para mostrarlo en la victoria
  double showerDurationSeconds = 0.0;

  // Datos de recompensas escalonadas y desempeño para la victoria
  int earnedXp = 0;
  int earnedMonedas = 0;
  bool bonusConstancia = false;
  int bonusXp = 0;
  int bonusMonedas = 0;
  String tierTitulo = "";
  String tierBadge = "";
  String tierDesempeno = "";

  late BackgroundComponent background;
  void Function(String)? onWarning;

  SpeedrunGame({this.onGameClosed, this.onChallengeCompleted, this.onWarning});

  static Map<String, dynamic> calculateTierRewards(int durationSeconds) {
    if (durationSeconds < 240) {
      return {
        'badge': '🚫',
        'titulo': 'Ducha no válida',
        'desempeno': 'Menos de 4 minutos (Anti-trampa)',
        'xp': 0,
        'monedas': 0,
        'valido': false,
      };
    } else if (durationSeconds <= 300) {
      // Entre 4 y 5 minutos (240s – 300s)
      return {
        'badge': '🏆',
        'titulo': '¡Ganaste el Speedrun!',
        'desempeno': 'Récord Óptimo (4 a 5 min)',
        'xp': 200,
        'monedas': 2,
        'valido': true,
      };
    } else if (durationSeconds <= 480) {
      // Entre 5 y 8 minutos (301s – 480s)
      return {
        'badge': '🥈',
        'titulo': '¡Buen Tiempo!',
        'desempeno': 'Tiempo Intermedio (5 a 8 min)',
        'xp': 100,
        'monedas': 1,
        'valido': true,
      };
    } else if (durationSeconds <= 600) {
      // Más de 8 minutos (> 480s hasta 10 min)
      return {
        'badge': '🥉',
        'titulo': '¡Ducha Completada!',
        'desempeno': 'Tiempo Extendido (8 a 10 min)',
        'xp': 50,
        'monedas': 0,
        'valido': true,
      };
    } else {
      return {
        'badge': '🚿⚠️',
        'titulo': 'Ducha Excesiva',
        'desempeno': 'Superó 10 minutos',
        'xp': 0,
        'monedas': 0,
        'valido': false,
      };
    }
  }

  SpeedrunState get gameState => _gameState;

  set gameState(SpeedrunState newState) {
    if (_gameState == newState) return;

    final oldState = _gameState;
    _gameState = newState;

    // Cambiar overlays
    overlays.remove(oldState.name);
    overlays.add(newState.name);

    // Lógica especial al entrar al estado
    if (newState == SpeedrunState.preparing) {
      prepRemainingSeconds = 30.0;
      elapsedShowerSeconds = 0.0;
      elapsedTime = 0.0;
    }
  }

  void showWarning(String message) {
    onWarning?.call(message);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Agregar el fondo animado
    background = BackgroundComponent();
    await add(background);

    // Iniciar en estado loading, Flame mostrará el overlay de carga
    overlays.add(SpeedrunState.loading.name);

    // Simular un tiempo de carga llamativo de 2.0 segundos para inicializar recursos
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (gameState == SpeedrunState.loading) {
        gameState = SpeedrunState.start;
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    elapsedTime += dt;

    // Si estamos en la etapa de preparación (30 segundos para entrar)
    if (gameState == SpeedrunState.preparing) {
      prepRemainingSeconds -= dt;
      if (prepRemainingSeconds <= 0.0) {
        prepRemainingSeconds = 0.0;
        gameState = SpeedrunState.playing;
      }
    }

    // Si estamos bañándonos, el tiempo corre hacia arriba
    if (gameState == SpeedrunState.playing) {
      elapsedShowerSeconds += dt;
      // Si superó los 10 minutos (600s), se considera automáticamente ducha excesiva (failure)
      if (elapsedShowerSeconds >= 600.0) {
        showerDurationSeconds = elapsedShowerSeconds;
        _persistShowerLog(elapsedShowerSeconds.toInt(), isSuccess: false);
        gameState = SpeedrunState.failure;
      }
    }
  }

  // Se llama desde HUD cuando el botón de finalizar ducha es presionado
  void completeShower() {
    if (gameState == SpeedrunState.playing) {
      showerDurationSeconds = elapsedShowerSeconds;

      // Si superó los 10 minutos (600s), se considera una ducha excesiva (failure)
      if (elapsedShowerSeconds > 600.0) {
        _persistShowerLog(elapsedShowerSeconds.toInt(), isSuccess: false);
        gameState = SpeedrunState.failure;
      } else {
        // Ducha exitosa (entre 4 minutos y 10 minutos)
        _persistShowerLog(elapsedShowerSeconds.toInt(), isSuccess: true);
        gameState = SpeedrunState.success;
        // Notificar al shell del reto que se completó con éxito
        onChallengeCompleted?.call();
      }
    }
  }

  Future<void> _persistShowerLog(int durationSeconds, {bool isSuccess = true}) async {
    final tier = calculateTierRewards(durationSeconds);
    tierBadge = tier['badge'] ?? '🏆';
    tierTitulo = tier['titulo'] ?? '¡Ducha Completada!';
    tierDesempeno = tier['desempeno'] ?? '';
    earnedXp = tier['xp'] ?? 50;
    earnedMonedas = tier['monedas'] ?? 0;

    try {
      final response = await ApiClient().post('/reto/ducha', {
        'duracion_segundos': durationSeconds,
      });

      if (isSuccess) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = jsonDecode(response.body);
          Map<String, dynamic>? recompensas;
          if (body is Map<String, dynamic>) {
            if (body['recompensas'] is Map<String, dynamic>) {
              recompensas = body['recompensas'];
            } else if (body['data'] is Map<String, dynamic> &&
                body['data']['recompensas'] is Map<String, dynamic>) {
              recompensas = body['data']['recompensas'];
            } else if (body['data'] is Map<String, dynamic>) {
              recompensas = body['data'];
            }
          }

          final current = SessionService().currentUser;
          if (current != null) {
            int baseScoreXp = earnedXp;
            int baseScoreMonedas = earnedMonedas;

            if (recompensas != null) {
              baseScoreXp = recompensas['xp_ganada'] ??
                  recompensas['xp_ganado'] ??
                  recompensas['xp'] ??
                  earnedXp;
              baseScoreMonedas = recompensas['monedas_ganadas'] ??
                  recompensas['monedas'] ??
                  earnedMonedas;

              if (recompensas['bonus_constancia'] == true ||
                  body['bonus_constancia'] == true ||
                  recompensas['bonus_diario'] == true) {
                bonusConstancia = true;
                bonusXp = 30;
                bonusMonedas = 5;
              }
            }

            earnedXp = baseScoreXp;
            earnedMonedas = baseScoreMonedas;

            final totalToApplyXp = earnedXp + (bonusConstancia ? bonusXp : 0);
            final totalToApplyMonedas =
                earnedMonedas + (bonusConstancia ? bonusMonedas : 0);

            await SessionService().updateRewardsAndXp(
              xp: (recompensas != null && recompensas['total_xp'] != null)
                  ? (recompensas['total_xp'] as int)
                  : (current.xp + totalToApplyXp),
              monedas: (recompensas != null && recompensas['saldo_monedas'] != null)
                  ? (recompensas['saldo_monedas'] as int)
                  : (current.monedas + totalToApplyMonedas),
              nivel: (recompensas != null && recompensas['nivel_actual'] != null)
                  ? (recompensas['nivel_actual'] as int)
                  : current.nivel,
            );

            _notificarFamilia(durationSeconds, totalToApplyXp, totalToApplyMonedas);
          }
        } else {
          await _applyLocalRewards(durationSeconds);
        }
      }
    } catch (e) {
      debugPrint('Error persistiendo registro de ducha: $e');
      if (isSuccess) {
        await _applyLocalRewards(durationSeconds);
      }
    }
  }

  Future<void> _applyLocalRewards(int durationSeconds) async {
    final current = SessionService().currentUser;
    if (current != null) {
      final tier = calculateTierRewards(durationSeconds);
      tierBadge = tier['badge'] ?? '🏆';
      tierTitulo = tier['titulo'] ?? '¡Ducha Completada!';
      tierDesempeno = tier['desempeno'] ?? '';
      earnedXp = tier['xp'] ?? 50;
      earnedMonedas = tier['monedas'] ?? 0;

      await SessionService().updateRewardsAndXp(
        xp: current.xp + earnedXp,
        monedas: current.monedas + earnedMonedas,
      );

      _notificarFamilia(durationSeconds, earnedXp, earnedMonedas);
    }
  }

  void _notificarFamilia(int durationSeconds, int xpGanada, int monedasGanadas) {
    final current = SessionService().currentUser;
    if (current != null && current.familyId != null && current.familyId!.isNotEmpty) {
      final durMin = (durationSeconds / 60).toStringAsFixed(1);
      HistoryService.enviarAlertaFamilia(
        familyId: current.familyId!,
        usuarioId: current.id,
        usuarioNombre: current.nombre,
        titulo: '🚿 ¡Eco-Ducha Completada!',
        mensaje:
            '${current.nombre} completó su ducha en $durMin min y sumó $xpGanada XP al hogar.',
        tipo: 'RETO_COMPLETADO',
        visual: {'icon': 'emoji_events', 'color': '#10B981'},
        payload: {
          'tipo': 'ducha',
          'duracion_segundos': durationSeconds,
          'xp': xpGanada,
          'monedas': monedasGanadas,
        },
      );
    }
  }

  void closeGame() {
    onGameClosed?.call();
  }
}
