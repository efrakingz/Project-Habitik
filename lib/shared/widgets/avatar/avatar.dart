import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserAvatar – avatar con foto de red o letra inicial
// ─────────────────────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String letra;
  final String colorHex;
  final String? avatarUrl;
  final double radius;
  final bool showBorder;

  const UserAvatar({
    super.key,
    required this.letra,
    required this.colorHex,
    this.avatarUrl,
    this.radius = 20,
    this.showBorder = false,
  });

  Color get _color {
    try { return Color(int.parse(colorHex.replaceAll('#', '0xFF'))); }
    catch (_) { return HabitikColors.green600; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.white, width: 2.5) : null,
        boxShadow: showBorder ? HabitikShadows.card : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _color,
        backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
        child: (avatarUrl == null || avatarUrl!.isEmpty)
            ? Text(
                letra.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.75,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito',
                ),
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FamilyAvatarStack – múltiples avatares apilados (para la familia)
// ─────────────────────────────────────────────────────────────────────────────
class FamilyAvatarStack extends StatelessWidget {
  final List<({String letra, String color, String? url})> members;
  final double radius;
  final int maxVisible;

  const FamilyAvatarStack({
    super.key,
    required this.members,
    this.radius = 16,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visible = members.take(maxVisible).toList();
    final extra = members.length > maxVisible ? members.length - maxVisible : 0;

    return SizedBox(
      height: radius * 2 + 4,
      width: (visible.length + (extra > 0 ? 1 : 0)) * (radius * 1.2) + radius * 0.8,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            return Positioned(
              left: i * radius * 1.2,
              child: UserAvatar(
                letra: m.letra,
                colorHex: m.color,
                avatarUrl: m.url,
                radius: radius,
                showBorder: true,
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: visible.length * radius * 1.2,
              child: Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  color: HabitikColors.green200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      color: HabitikColors.green900,
                      fontSize: radius * 0.65,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
