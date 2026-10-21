import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo oficial de Habitik renderizado con fidelidad vectorial desde assets/images/logo_habitik.svg.
/// Diseño limpio, exacto y sin artefactos, halos ni manchas difusas.
class HabitikLogo extends StatelessWidget {
  /// Dimensión (ancho y alto) del logo.
  final double size;

  /// Si es true, aplica una micro-animación sutil de respiración para pantallas de carga.
  final bool pulseEffect;

  /// Decoración o redondeo personalizado opcional.
  final BorderRadius? borderRadius;

  const HabitikLogo({
    super.key,
    this.size = 64.0,
    this.pulseEffect = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = SvgPicture.asset(
      'assets/images/logo_habitik.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (borderRadius != null) {
      logoWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: logoWidget,
      );
    }

    if (pulseEffect) {
      return logoWidget
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.04, 1.04),
            duration: 1200.ms,
            curve: Curves.easeInOut,
          );
    }

    return logoWidget;
  }
}
