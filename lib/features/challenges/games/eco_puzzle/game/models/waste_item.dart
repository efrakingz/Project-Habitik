import '../components/recycle_bin.dart';

/// Modelo de residuo que clasifica un emoji interactivo en su contenedor ecológico.
class WasteItem {
  final String id;
  final String emoji;
  final BinType targetType;
  final String label;

  const WasteItem({
    required this.id,
    required this.emoji,
    required this.targetType,
    required this.label,
  });

  /// Colección completa de residuos cotidianos categorizados
  static const List<WasteItem> allItems = [
    // ── 1. Orgánicos (Compostables y biodegradables) ──
    WasteItem(id: 'apple', emoji: '🍎', targetType: BinType.organic, label: 'Manzana'),
    WasteItem(id: 'banana', emoji: '🍌', targetType: BinType.organic, label: 'Plátano'),
    WasteItem(id: 'watermelon', emoji: '🍉', targetType: BinType.organic, label: 'Sandía'),
    WasteItem(id: 'avocado', emoji: '🥑', targetType: BinType.organic, label: 'Aguacate'),
    WasteItem(id: 'carrot', emoji: '🥕', targetType: BinType.organic, label: 'Zanahoria'),
    WasteItem(id: 'broccoli', emoji: '🥦', targetType: BinType.organic, label: 'Brócoli'),
    WasteItem(id: 'egg', emoji: '🥚', targetType: BinType.organic, label: 'Cáscara de huevo'),
    WasteItem(id: 'fish', emoji: '🐟', targetType: BinType.organic, label: 'Espina de pescado'),

    // ── 2. Reciclables (Limpios y secos: metal, plástico, cartón, vidrio, papel) ──
    WasteItem(id: 'can', emoji: '🥫', targetType: BinType.recyclable, label: 'Lata'),
    WasteItem(id: 'plastic_bottle', emoji: '🧴', targetType: BinType.recyclable, label: 'Botella de plástico'),
    WasteItem(id: 'glass_bottle', emoji: '🍾', targetType: BinType.recyclable, label: 'Botella de vidrio'),
    WasteItem(id: 'cardboard', emoji: '📦', targetType: BinType.recyclable, label: 'Caja de cartón'),
    WasteItem(id: 'newspaper', emoji: '📰', targetType: BinType.recyclable, label: 'Periódico'),
    WasteItem(id: 'juice_box', emoji: '🧃', targetType: BinType.recyclable, label: 'Envase de jugo'),

    // ── 3. Inorgánicos / Rechazo (No reciclables, contaminados o especiales) ──
    WasteItem(id: 'battery', emoji: '🔋', targetType: BinType.inorganic, label: 'Pila / Batería'),
    WasteItem(id: 'lightbulb', emoji: '💡', targetType: BinType.inorganic, label: 'Foco'),
    WasteItem(id: 'plastic_bag', emoji: '🛍️', targetType: BinType.inorganic, label: 'Bolsa plástica'),
    WasteItem(id: 'tissue', emoji: '🧻', targetType: BinType.inorganic, label: 'Papel usado'),
    WasteItem(id: 'coffee_cup', emoji: '☕', targetType: BinType.inorganic, label: 'Vaso desechable'),
  ];
}
