import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Tipos de notificaciones disponibles en la plataforma Habitik
enum HabitikNotificationType {
  duchaSpeedrun,
  retoCompletado,
  recordatorioHabito,
  alertaConsumo,
  conexionFamiliar,
  general,
}

/// Modelo de configuración visual y preferencias para un tipo de notificación
class NotificationVisualPreferences {
  final String canalId;
  final String canalNombre;
  final String canalDescripcion;
  final String prefijoEmoji;
  final Color color;
  final String icono;
  final Importance importancia;
  final Priority prioridad;
  final bool conSonido;
  final bool conVibracion;

  const NotificationVisualPreferences({
    required this.canalId,
    required this.canalNombre,
    required this.canalDescripcion,
    required this.prefijoEmoji,
    required this.color,
    this.icono = 'ic_notification_leaf',
    this.importancia = Importance.max,
    this.prioridad = Priority.high,
    this.conSonido = true,
    this.conVibracion = true,
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _timezonesInitialized = false;

  /// Diccionario centralizado de preferencias visuales por tipo de notificación
  static final Map<HabitikNotificationType, NotificationVisualPreferences>
      _preferenciasPorTipo = {
    HabitikNotificationType.duchaSpeedrun: const NotificationVisualPreferences(
      canalId: 'canal_alertas_ducha',
      canalNombre: 'Alertas Eco-Ducha',
      canalDescripcion: 'Notificaciones en tiempo real del reto de ahorro en la ducha',
      prefijoEmoji: '🚿',
      color: Color(0xFF00ACC1), // Cyan Agua
      icono: 'ic_notification_shower',
      importancia: Importance.max,
      prioridad: Priority.high,
    ),
    HabitikNotificationType.retoCompletado: const NotificationVisualPreferences(
      canalId: 'canal_alertas_familiares',
      canalNombre: 'Retos del Hogar Completados',
      canalDescripcion: 'Logros y retos completados por miembros de la familia',
      prefijoEmoji: '🏆',
      color: Color(0xFF2E7D32), // Verde Habitik
      icono: 'ic_notification_trophy',
      importancia: Importance.high,
      prioridad: Priority.high,
    ),
    HabitikNotificationType.recordatorioHabito: const NotificationVisualPreferences(
      canalId: 'canal_recordatorios_programados',
      canalNombre: 'Recordatorios de Hábitos',
      canalDescripcion: 'Recordatorios programados de ahorro y acciones sostenibles',
      prefijoEmoji: '🌿',
      color: Color(0xFF43A047), // Verde Hoja
      icono: 'ic_notification_leaf',
      importancia: Importance.high,
      prioridad: Priority.high,
    ),
    HabitikNotificationType.alertaConsumo: const NotificationVisualPreferences(
      canalId: 'canal_alertas_familiares',
      canalNombre: 'Alertas de Consumo Energético',
      canalDescripcion: 'Notificaciones sobre picos o metas de consumo de luz y agua',
      prefijoEmoji: '⚡',
      color: Color(0xFFFFA000), // Ámbar Alerta
      icono: 'ic_notification_bolt',
      importancia: Importance.max,
      prioridad: Priority.high,
    ),
    HabitikNotificationType.conexionFamiliar: const NotificationVisualPreferences(
      canalId: 'canal_servicio_segundo_plano',
      canalNombre: 'Red Familiar en Vivo',
      canalDescripcion: 'Servicio de sincronización continua con el hogar',
      prefijoEmoji: '🌿',
      color: Color(0xFF2E7D32),
      icono: 'ic_notification_leaf',
      importancia: Importance.low,
      prioridad: Priority.low,
      conSonido: false,
      conVibracion: false,
    ),
    HabitikNotificationType.general: const NotificationVisualPreferences(
      canalId: 'canal_alertas_familiares',
      canalNombre: 'Notificaciones Generales',
      canalDescripcion: 'Avisos y mensajes generales del hogar',
      prefijoEmoji: '🌱',
      color: Color(0xFF2E7D32),
      icono: 'ic_notification_leaf',
      importancia: Importance.defaultImportance,
      prioridad: Priority.defaultPriority,
    ),
  };

  /// Obtiene las preferencias visuales (icono, color, canal, emoji) según el tipo
  static NotificationVisualPreferences obtenerPreferencias(dynamic tipo) {
    if (tipo is HabitikNotificationType) {
      return _preferenciasPorTipo[tipo] ??
          _preferenciasPorTipo[HabitikNotificationType.general]!;
    }

    final tipoStr = tipo?.toString().toUpperCase() ?? '';
    if (tipoStr.contains('DUCHA')) {
      return _preferenciasPorTipo[HabitikNotificationType.duchaSpeedrun]!;
    } else if (tipoStr.contains('RETO') || tipoStr.contains('EVIDENCIA')) {
      return _preferenciasPorTipo[HabitikNotificationType.retoCompletado]!;
    } else if (tipoStr.contains('RECORDATORIO') || tipoStr.contains('HABITO')) {
      return _preferenciasPorTipo[HabitikNotificationType.recordatorioHabito]!;
    } else if (tipoStr.contains('CONSUMO') || tipoStr.contains('LUZ') || tipoStr.contains('AGUA')) {
      return _preferenciasPorTipo[HabitikNotificationType.alertaConsumo]!;
    }

    return _preferenciasPorTipo[HabitikNotificationType.general]!;
  }

  /// Inicializa los canales nativos de Android y opcionalmente los permisos
  static Future<void> initNotificationService({bool requestPermission = true}) async {
    if (!_timezonesInitialized) {
      tz.initializeTimeZones();
      _timezonesInitialized = true;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification_leaf');

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
      // Registrar todos los canales parametrizados
      for (final pref in _preferenciasPorTipo.values) {
        final channel = AndroidNotificationChannel(
          pref.canalId,
          pref.canalNombre,
          description: pref.canalDescripcion,
          importance: pref.importancia,
          playSound: pref.conSonido,
          enableVibration: pref.conVibracion,
          showBadge: pref.importancia != Importance.low,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

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

  static final Map<String, int> _ultimasNotificaciones = {};

  /// Muestra una notificación parametrizada en tiempo real con icono de marca y prevención de duplicados
  static Future<void> mostrarNotificacionSistema({
    required int id,
    required String titulo,
    required String cuerpo,
    dynamic tipo,
    String? payload,
    String? deduplicationKey,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final key = deduplicationKey ?? '${id}_${titulo}_$cuerpo';

    // Si la misma notificación se disparó hace menos de 3 segundos, ignorar el duplicado
    if (_ultimasNotificaciones.containsKey(key)) {
      final lastTime = _ultimasNotificaciones[key]!;
      if (now - lastTime < 3000) {
        debugPrint('🛡️ [NotificationService] Notificación duplicada bloqueada: $titulo');
        return;
      }
    }
    _ultimasNotificaciones[key] = now;
    _ultimasNotificaciones.removeWhere((k, t) => now - t > 15000);

    final pref = obtenerPreferencias(tipo);

    final String tituloFormateado = titulo.startsWith(pref.prefijoEmoji)
        ? titulo
        : '${pref.prefijoEmoji} $titulo';

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      pref.canalId,
      pref.canalNombre,
      channelDescription: pref.canalDescripcion,
      importance: pref.importancia,
      priority: pref.prioridad,
      icon: pref.icono,
      largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      color: pref.color,
      showWhen: true,
      enableVibration: pref.conVibracion,
      playSound: pref.conSonido,
      category: AndroidNotificationCategory.event,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      tituloFormateado,
      cuerpo,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Programa una notificación parametrizada en el reloj nativo de Android (AlarmManager)
  static Future<void> programarNotificacionLocal({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaHora,
    dynamic tipo,
    String? payload,
  }) async {
    if (!_timezonesInitialized) {
      tz.initializeTimeZones();
      _timezonesInitialized = true;
    }

    final pref = obtenerPreferencias(tipo ?? HabitikNotificationType.recordatorioHabito);
    final scheduledDate = tz.TZDateTime.from(fechaHora, tz.local);

    final String tituloFormateado = titulo.startsWith(pref.prefijoEmoji)
        ? titulo
        : '${pref.prefijoEmoji} $titulo';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      pref.canalId,
      pref.canalNombre,
      channelDescription: pref.canalDescripcion,
      importance: pref.importancia,
      priority: pref.prioridad,
      icon: pref.icono,
      largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      color: pref.color,
      playSound: pref.conSonido,
      enableVibration: pref.conVibracion,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      tituloFormateado,
      cuerpo,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('⏰ [NotificationService] ${pref.prefijoEmoji} Notificación programada para $fechaHora con id $id');
  }

  /// Cancela una notificación programada por ID
  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
