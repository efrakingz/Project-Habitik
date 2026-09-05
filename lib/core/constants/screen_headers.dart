import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';


/// 3. Cabecera general de las otras pantallas (usada por ScreenShell)
Widget buildScreenHeader({
  required BuildContext context,
  required String titulo,
  String? subtitulo,
  Widget? customTitle,
  Widget? headerLeft,
  Widget? leadingWidget,
  List<Widget>? headerActions,
  bool showBackButton = false,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 16, 20, 12),
}) {
  return Padding(
    padding: padding,
    child: Row(
      children: [
        if (headerLeft != null) ...[
          headerLeft,
          const SizedBox(width: 12),
        ] else if (showBackButton && Navigator.canPop(context)) ...[
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
