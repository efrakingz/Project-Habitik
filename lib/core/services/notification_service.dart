import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa los canales nativos de Android y opcionalmente los permisos (solo en UI principal)
  static Future<void> initNotificationService({bool requestPermission = true}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Canal silencioso para el servicio en segundo plano
      const AndroidNotificationChannel backgroundChannel = AndroidNotificationChannel(
        'canal_servicio_segundo_plano',
        'Servicio Habitik en Segundo Plano',
        description: 'Servicio para escuchar notificaciones y alertas familiares en tiempo real',
        importance: Importance.low,
      );

      // Canal de máxima prioridad para alertas y notificaciones del hogar
      const AndroidNotificationChannel alertChannel = AndroidNotificationChannel(
        'canal_alertas_familiares',
        'Alertas Familiares Habitik',
        description: 'Canal de notificaciones y retos en tiempo real para el hogar',
        importance: Importance.max,
      );

      await androidImplementation.createNotificationChannel(backgroundChannel);
      await androidImplementation.createNotificationChannel(alertChannel);

      if (requestPermission) {
        try {
          final granted = await androidImplementation.requestNotificationsPermission();
          debugPrint('🔔 [NotificationService] Permiso de notificaciones concedido: $granted');
        } catch (e) {
          debugPrint('⚠️ [NotificationService] Solicitud de permiso omitida en background: $e');
        }
      }
    }
  }

  /// Muestra una notificación emergente (Heads-Up) con sonido y vibración
  static Future<void> mostrarNotificacionSistema({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'canal_alertas_familiares',
      'Alertas Familiares Habitik',
      channelDescription: 'Canal de notificaciones y retos en tiempo real para el hogar',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      titulo,
      cuerpo,
      platformChannelSpecifics,
    );
  }
}
