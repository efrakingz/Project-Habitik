import 'package:flutter/material.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/core/theme/theme.dart';

/// 1. Cabecera del Dashboard (Home)
Widget buildHomeHeader({
  required BuildContext context,
  required String familyName,
  required String userName,
  required String userRol,
  required String avatarLetra,
  required String avatarColor,
  String? avatarUrl,
  String? familyAvatarUrl,
  required int notifCount,
  required VoidCallback onNotifTap,
  required VoidCallback onAvatarTap,
  required VoidCallback onFamilyTap,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        // Family avatar
        GestureDetector(
          onTap: onFamilyTap,
          child: UserAvatar(
            letra: familyName.isNotEmpty ? familyName[0] : 'F',
            colorHex: avatarColor,
            avatarUrl: familyAvatarUrl,
            radius: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $familyName!',
                style: const TextStyle(
                  color: HabitikColors.green200,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Muro Familiar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        // Notif button
        IconActionButton(
          icon: Icons.notifications_outlined,
          onTap: onNotifTap,
          hasBadge: notifCount > 0,
        ),
        const SizedBox(width: 8),
        // User avatar
        GestureDetector(
          onTap: onAvatarTap,
          child: UserAvatar(
            letra: avatarLetra,
            colorHex: avatarColor,
            avatarUrl: avatarUrl,
            radius: 20,
            showBorder: true,
          ),
        ),
      ],
    ),
  );
}

/// 2. Cabecera del Perfil (ProfileScreen)
Widget buildProfileHeader({
  required BuildContext context,
  required String nombre,
  required String rol,
  String? familyName,
  required String avatarLetra,
  required String avatarColor,
  String? avatarUrl,
  double avatarRadius = 34,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(
      children: [
        if (Navigator.canPop(context)) ...[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
        UserAvatar(
          letra: avatarLetra,
          colorHex: avatarColor,
          avatarUrl: avatarUrl,
          radius: avatarRadius,
          showBorder: true,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              RolBadge(rol),
              const SizedBox(height: 6),
              Text(
                familyName ?? 'Sin familia',
                style: const TextStyle(
                  color: HabitikColors.green200,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 3. Cabecera general de las otras pantallas (usada por ScreenShell)
Widget buildScreenHeader({
  required BuildContext context,
  required String titulo,
  String? subtitulo,
  Widget? customTitle,
  Widget? headerLeft,
  Widget? leadingWidget,
  List<Widget>? headerActions,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 16, 20, 12),
}) {
  return Padding(
    padding: padding,
    child: Row(
      children: [
        if (headerLeft != null) ...[
          headerLeft,
        ] else if (Navigator.canPop(context)) ...[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
        ],
        if (leadingWidget != null) ...[
          leadingWidget,
          const SizedBox(width: 14),
        ],
        Expanded(
          child: customTitle ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitulo != null)
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: HabitikColors.green200,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
        ),
        if (headerActions != null) Row(children: headerActions),
      ],
    ),
  );
}
