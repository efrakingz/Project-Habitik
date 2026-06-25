import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
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

  late BackgroundComponent background;
  void Function(String)? onWarning;

  SpeedrunGame({
    this.onGameClosed,
    this.onChallengeCompleted,
  });

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
    }
  }

  // Se llama desde HUD cuando el botón de finalizar ducha es presionado
  void completeShower() {
    if (gameState == SpeedrunState.playing) {
      showerDurationSeconds = elapsedShowerSeconds;
      
      // Si superó los 4 minutos (240s), se considera una ducha excesiva (failure)
      if (elapsedShowerSeconds > 240.0) {
        gameState = SpeedrunState.failure;
      } else {
        gameState = SpeedrunState.success;
        // Notificar al shell del reto que se completó con éxito
        onChallengeCompleted?.call();
      }
    }
  }

  void closeGame() {
    onGameClosed?.call();
  }
}
