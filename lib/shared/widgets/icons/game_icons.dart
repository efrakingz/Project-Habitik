import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';

/// Un icono vectorial con gradiente para emular gráficos de videojuego
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // Requerido para que el ShaderMask aplique correctamente
      ),
    );
  }
}

/// Icono premium de Racha (Fuego Degradado 3D)
class GameFireIcon extends StatelessWidget {
  final double size;
  const GameFireIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3D00).withAlpha(40),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: GradientIcon(
        icon: Icons.local_fire_department_rounded,
        size: size,
        gradient: HabitikColors.fireStreak,
      ),
    );
  }
}

/// Icono premium de Monedas (Moneda de Oro con relieve 3D)
class GameCoinIcon extends StatelessWidget {
  final double size;
  const GameCoinIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF176), Color(0xFFF57F17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: size * 0.08,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withAlpha(120),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'c',
        style: TextStyle(
          color: const Color(0xFFF57F17),
          fontSize: size * 0.55,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          height: 1.0,
        ),
      ),
    );
  }
}

/// Icono premium de XP o Nivel (Estrella Brillante 3D)
class GameStarIcon extends StatelessWidget {
  final double size;
  const GameStarIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFEA00).withAlpha(60),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const GradientIcon(
        icon: Icons.star_rounded,
        size: 24,
        gradient: LinearGradient(
          colors: [Color(0xFFFFEA00), Color(0xFFFF8F00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

/// Icono premium del juego/reto específico
class GameChallengeIcon extends StatelessWidget {
  final String challengeId;
  final double size;
  final Color? color;
  final bool solidWhite;

  const GameChallengeIcon({
    super.key,
    required this.challengeId,
    this.size = 32,
    this.color,
    this.solidWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Gradient gradient;

    switch (challengeId) {
      case 'ducha':
        iconData = Icons.water_drop_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF1565C0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'inspeccion':
        iconData = Icons.photo_camera_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'trivia':
        iconData = Icons.lightbulb_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFFE040FB), Color(0xFF6A1B9A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'puzzle':
        iconData = Icons.extension_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFC62828)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'wordle':
        iconData = Icons.abc_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'sopa':
        iconData = Icons.grid_on_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF00796B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      case 'pesca':
        iconData = Icons.sailing_rounded;
        gradient = const LinearGradient(
          colors: [Color(0xFF48CAE4), Color(0xFF0096C7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        break;
      default:
        iconData = Icons.help_rounded;
        gradient = const LinearGradient(
          colors: [Colors.grey, Colors.black],
        );
    }

    if (solidWhite) {
      return Icon(
        iconData,
        size: size,
        color: Colors.white,
      );
    }

    if (color != null) {
      gradient = LinearGradient(colors: [color!, color!.withAlpha(150)]);
    }

    return GradientIcon(
      icon: iconData,
      size: size,
      gradient: gradient,
    );
  }
}
