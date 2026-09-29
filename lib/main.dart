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

  // Cargar preferencia de tema (caché persistente de SharedPreferences o modo del celular)
  await ThemeService.init();

  // Lanzar la aplicación
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
    // Verificar y sincronizar el brillo del sistema tras adjuntar el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ThemeService.checkOnResume();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundServiceManager.detenerServicio();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    ThemeService.onSystemBrightnessChanged(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ThemeService.checkOnResume();
    }
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
