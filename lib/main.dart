import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/navigation/app_router.dart';

import 'package:habitik/core/services/notification_service.dart';
import 'package:habitik/core/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones del sistema y servicio en segundo plano
  await NotificationService.initNotificationService();
  await BackgroundServiceManager.initializeService();

  // Configurar flutter_animate
  Animate.restartOnHotReload = true;

  // Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const HabitikApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// App root
// ─────────────────────────────────────────────────────────────────────────────
class HabitikApp extends StatelessWidget {
  const HabitikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Habitik',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const RootRouter(),
        );
      },
    );
  }
}
