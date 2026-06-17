import 'dart:ui' as ui;
import 'package:flame/components.dart';

mixin VisibilityAwareUpdate on PositionComponent {
  @override
  void update(double dt) {
    if (!isMounted) return;
    try {
      final gameRef = findGame();
      if (gameRef != null) {
        final rect = gameRef.camera.visibleWorldRect;
        // Margen de seguridad generoso de 50px alrededor del componente
        final componentRect = ui.Rect.fromLTRB(
          position.x - size.x - 50.0,
          position.y - size.y - 50.0,
          position.x + size.x + 50.0,
          position.y + size.y + 50.0,
        );
        if (!rect.overlaps(componentRect)) return;
      }
    } catch (_) {}
    super.update(dt);
  }
}
