import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/navigation/app_router.dart';
import 'package:habitik/core/services/network_service.dart';
import 'package:habitik/core/services/notification_service.dart';
import 'package:habitik/core/services/background_service.dart';
import 'package:habitik/shared/widgets/modals/no_internet_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Lanzar la aplicación de inmediato para mostrar el primer frame sin esperas
  runApp(const HabitikApp());

  // Inicializaciones en segundo plano concurrentes (no bloqueantes para la UI)
  NetworkService().init();
  NotificationService.initNotificationService();
  BackgroundServiceManager.initializeService();

  // Configurar flutter_animate
  Animate.restartOnHotReload = true;
}

// ─────────────────────────────────────────────────────────────────────────────
// App root
// ─────────────────────────────────────────────────────────────────────────────
class HabitikApp extends StatefulWidget {
  const HabitikApp({super.key});

  @override
  State<HabitikApp> createState() => _HabitikAppState();
}

class _HabitikAppState extends State<HabitikApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundServiceManager.detenerServicio();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si la app se cierra o se elimina de tareas recientes, detener el servicio de inmediato
    if (state == AppLifecycleState.detached) {
      BackgroundServiceManager.detenerServicio();
    }
  }

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
          builder: (context, child) => NoInternetBarrier(child: child ?? const SizedBox.shrink()),
          home: const RootRouter(),
        );
      },
    );
  }
}
