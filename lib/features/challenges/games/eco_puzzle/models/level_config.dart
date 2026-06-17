enum GameLevel { level1, level2, level3 }

class LevelConfig {
  final GameLevel level;
  final String title;
  final String subtitle;
  final List<String> binIds;
  final List<String> itemIds;
  final double beltSpeed;
  final int timeLimitSeconds;
  final int targetClassified;

  const LevelConfig({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.binIds,
    required this.itemIds,
    required this.beltSpeed,
    required this.timeLimitSeconds,
    required this.targetClassified,
  });

  static const level1 = LevelConfig(
    level: GameLevel.level1,
    title: 'Nivel 1',
    subtitle: 'Inicio de Planta',
    binIds: ['plastico', 'papel', 'vidrio', 'organico'],
    itemIds: [
      'pet_bottle', 'detergent_bottle', 'plastic_bag', 'plastic_cup',
      'newspaper', 'cardboard', 'envelope', 'notebook',
      'glass_bottle', 'glass_jar', 'wine_glass', 'mirror',
      'orange_peel', 'apple_core', 'banana_peel', 'coffee'
    ],
    beltSpeed: 45.0,
    timeLimitSeconds: 60,
    targetClassified: 8,
  );

  static const level2 = LevelConfig(
    level: GameLevel.level2,
    title: 'Nivel 2',
    subtitle: 'Desafío Orgánico',
    binIds: ['plastico', 'papel', 'vidrio', 'organico', 'peligroso'],
    itemIds: [
      'pet_bottle', 'detergent_bottle', 'plastic_bag', 'plastic_cup',
      'newspaper', 'cardboard', 'envelope', 'notebook',
      'glass_bottle', 'glass_jar', 'wine_glass', 'mirror',
      'orange_peel', 'apple_core', 'banana_peel', 'coffee',
      'battery', 'phone', 'lightbulb', 'spray_can'
    ],
    beltSpeed: 55.0,
    timeLimitSeconds: 60,
    targetClassified: 10,
  );

  static const level3 = LevelConfig(
    level: GameLevel.level3,
    title: 'Nivel 3',
    subtitle: 'Más Tipos',
    binIds: ['plastico', 'papel', 'vidrio', 'organico', 'peligroso', 'metal'],
    itemIds: [
      'pet_bottle', 'detergent_bottle', 'plastic_bag', 'plastic_cup',
      'newspaper', 'cardboard', 'envelope', 'notebook',
      'glass_bottle', 'glass_jar', 'wine_glass', 'mirror',
      'orange_peel', 'apple_core', 'banana_peel', 'coffee',
      'battery', 'phone', 'lightbulb', 'spray_can',
      'can', 'food_can', 'metal_screw', 'key'
    ],
    beltSpeed: 65.0,
    timeLimitSeconds: 60,
    targetClassified: 10,
  );
}
