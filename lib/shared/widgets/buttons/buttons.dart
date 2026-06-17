import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrimaryButton – botón principal con gradiente y animación de tap
// ─────────────────────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  final Gradient? gradient;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
    this.gradient,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: _AnimatedTapWrapper(
        onTap: loading ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? HabitikColors.heroGreen,
            borderRadius: HabitikRadius.md_,
            boxShadow: onTap != null ? HabitikShadows.colored(HabitikColors.green600) : [],
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SecondaryButton – botón secundario con borde
// ─────────────────────────────────────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? HabitikColors.green700;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: _AnimatedTapWrapper(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: HabitikRadius.md_,
            border: Border.all(color: c, width: 2),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: c, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IconActionButton – botón circular con icono (para header)
// ─────────────────────────────────────────────────────────────────────────────
class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? iconColor;
  final double size;
  final bool hasBadge;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.bgColor,
    this.iconColor,
    this.size = 36,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: bgColor ?? HabitikColors.whiteOverlay20,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: iconColor ?? Colors.white, size: size * 0.5)),
            if (hasBadge)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    color: HabitikColors.orange400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedTapWrapper – escala al presionar (micro-animación)
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedTapWrapper({required this.child, this.onTap});

  @override
  State<_AnimatedTapWrapper> createState() => _AnimatedTapWrapperState();
}

class _AnimatedTapWrapperState extends State<_AnimatedTapWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 80.ms, reverseDuration: 120.ms);
    _scale = Tween(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null ? (_) { _ctrl.reverse(); widget.onTap!(); } : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
