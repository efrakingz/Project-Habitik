import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

enum BinType { organic, recyclable, inorganic }

class RecycleBin extends PositionComponent {
  final BinType type;
  
  late final RectangleComponent _background;
  late final TextComponent _icon;
  late final TextComponent _label;

  RecycleBin({
    required this.type,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    Color bgColor;
    String iconStr;
    String labelStr;

    switch (type) {
      case BinType.organic:
        bgColor = const Color(0xFF4CAF50); // Verde
        iconStr = '🌱';
        labelStr = 'Orgánico';
        break;
      case BinType.recyclable:
        bgColor = const Color(0xFFFFB300); // Amarillo
        iconStr = '♻️';
        labelStr = 'Reciclable';
        break;
      case BinType.inorganic:
        bgColor = const Color(0xFF757575); // Gris
        iconStr = '🗑️';
        labelStr = 'Inorgánico';
        break;
    }

    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = bgColor,
      anchor: Anchor.topLeft,
    );

    _icon = TextComponent(
      text: iconStr,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32),
      ),
      position: Vector2(size.x / 2, size.y / 2 - 10),
      anchor: Anchor.center,
    );

    _label = TextComponent(
      text: labelStr,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y - 15),
      anchor: Anchor.center,
    );

    add(_background);
    add(_icon);
    add(_label);
  }

  void flashGreen() {
    _background.add(
      ColorEffect(
        Colors.white,
        EffectController(duration: 0.1, alternate: true),
        opacityTo: 0.8,
      ),
    );
  }

  void flashRed() {
    _background.add(
      ColorEffect(
        Colors.red,
        EffectController(duration: 0.1, alternate: true),
        opacityTo: 0.8,
      ),
    );
  }
}
