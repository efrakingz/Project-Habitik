import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/features/challenges/games/speedrun/game/models/speedrun_state.dart';
import 'package:habitik/features/challenges/games/speedrun/game/speedrun_game.dart';

void main() {
  group('Speedrun Ducha Validation & Tier Rewards Tests', () {
    test('Ducha menor a 3 minutos (< 180s) es inválida y no otorga recompensas', () {
      final tier30s = SpeedrunGame.calculateTierRewards(30);
      expect(tier30s['valido'], false);
      expect(tier30s['xp'], 0);
      expect(tier30s['monedas'], 0);
      expect(tier30s['titulo'], contains('no válida'));

      final tier179s = SpeedrunGame.calculateTierRewards(179);
      expect(tier179s['valido'], false);
      expect(tier179s['xp'], 0);
      expect(tier179s['monedas'], 0);
    });

    test('Ducha óptima (180s - 300s / 3 a 5 min) es válida y entrega 200 XP y 2 monedas', () {
      final tier180s = SpeedrunGame.calculateTierRewards(180);
      expect(tier180s['valido'], true);
      expect(tier180s['xp'], 200);
      expect(tier180s['monedas'], 2);

      final tier300s = SpeedrunGame.calculateTierRewards(300);
      expect(tier300s['valido'], true);
      expect(tier300s['xp'], 200);
      expect(tier300s['monedas'], 2);
    });

    test('Ducha intermedia (301s - 480s / 5 a 8 min) entrega 100 XP y 1 moneda', () {
      final tier301s = SpeedrunGame.calculateTierRewards(301);
      expect(tier301s['valido'], true);
      expect(tier301s['xp'], 100);
      expect(tier301s['monedas'], 1);

      final tier480s = SpeedrunGame.calculateTierRewards(480);
      expect(tier480s['valido'], true);
      expect(tier480s['xp'], 100);
      expect(tier480s['monedas'], 1);
    });

    test('Ducha extendida (481s - 600s / 8 a 10 min) entrega 50 XP y 0 monedas', () {
      final tier481s = SpeedrunGame.calculateTierRewards(481);
      expect(tier481s['valido'], true);
      expect(tier481s['xp'], 50);
      expect(tier481s['monedas'], 0);

      final tier600s = SpeedrunGame.calculateTierRewards(600);
      expect(tier600s['valido'], true);
      expect(tier600s['xp'], 50);
      expect(tier600s['monedas'], 0);
    });

    test('Ducha excesiva (> 600s / > 10 min) es inválida y entrega 0 XP', () {
      final tier601s = SpeedrunGame.calculateTierRewards(601);
      expect(tier601s['valido'], false);
      expect(tier601s['xp'], 0);
      expect(tier601s['monedas'], 0);
      expect(tier601s['titulo'], contains('Excesiva'));
    });

    test('completeShower con tiempo < 180s transiciona a failure con ShowerFailureReason.tooShort', () {
      final game = SpeedrunGame();
      game.gameState = SpeedrunState.playing;
      game.elapsedShowerSeconds = 30.0;

      game.completeShower();

      expect(game.gameState, SpeedrunState.failure);
      expect(game.failureReason, ShowerFailureReason.tooShort);
      expect(game.earnedXp, 0);
      expect(game.earnedMonedas, 0);
    });

    test('completeShower con tiempo > 600s transiciona a failure con ShowerFailureReason.tooLong', () {
      final game = SpeedrunGame();
      game.gameState = SpeedrunState.playing;
      game.elapsedShowerSeconds = 650.0;

      game.completeShower();

      expect(game.gameState, SpeedrunState.failure);
      expect(game.failureReason, ShowerFailureReason.tooLong);
      expect(game.earnedXp, 0);
      expect(game.earnedMonedas, 0);
    });
  });
}
