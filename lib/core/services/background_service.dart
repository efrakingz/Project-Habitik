import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart';
import 'history_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await NotificationService.initNotificationService(requestPermission: false);

  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: '🌿 Habitik',
      content: 'Conectado a la red familiar en tiempo real',
    );

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  io.Socket? socket;
  String? currentFamilyId;
  String? currentUserId;
  String backendUrl = ApiClient.baseUrl;

  void conectarSocket(String familyId, String url) {
    if (socket != null) {
      try {
        socket!.disconnect();
        socket!.dispose();
      } catch (_) {}
      socket = null;
    }

    debugPrint('🔄 [BackgroundService] Conectando a $url para la familia $familyId');

    socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('⚡ [BackgroundService] Socket conectado exitosamente a $url');
      socket!.emit('unirse_familia', familyId);
      if (currentUserId != null && currentUserId!.isNotEmpty) {
        socket!.emit('unirse_usuario', currentUserId);
      }
    });

    socket!.on('reconnect', (_) {
      debugPrint('⚡ [BackgroundService] Socket reconectado');
      socket!.emit('unirse_familia', familyId);
      if (currentUserId != null && currentUserId!.isNotEmpty) {
        socket!.emit('unirse_usuario', currentUserId);
      }
    });

    socket!.on('evento_en_vivo', (data) async {
      debugPrint('🔔 [BackgroundService] Evento recibido en segundo plano: $data');
      try {
        Map<String, dynamic> parsedData;
        if (data is String) {
          parsedData = Map<String, dynamic>.from(jsonDecode(data));
        } else if (data is Map) {
          parsedData = Map<String, dynamic>.from(data);
        } else {
          return;
        }

        final String notifKey = '${parsedData['id'] ?? parsedData['titulo']}_${parsedData['tipo'] ?? 'ALERTA'}';
        final int notifId = notifKey.hashCode.abs() % 100000;
        final String sender = parsedData['usuario_nombre'] ?? parsedData['sender_name'] ?? 'Familiar';
        final String titulo = '${parsedData['titulo'] ?? parsedData['title'] ?? 'Alerta Familiar'}';
        final String cuerpo = '${parsedData['mensaje'] ?? parsedData['desc_text'] ?? 'Nueva notificación'}';

        // 1. Mostrar notificación nativa emergente en el sistema con diseño parametrizado
        await NotificationService.mostrarNotificacionSistema(
          id: notifId,
          titulo: '$sender: $titulo',
          cuerpo: cuerpo,
          tipo: parsedData['tipo'],
          deduplicationKey: notifKey,
          payload: jsonEncode(parsedData),
        );

        // 2. Guardar en el historial local persistente
        await HistoryService.guardarEventoLocal(familyId, parsedData);

        // 3. Emitir evento a la UI activa si está abierta
        service.invoke('nuevo_evento', parsedData);
      } catch (e) {
        debugPrint('⚠️ [BackgroundService] Error procesando evento en segundo plano: $e');
      }
    });

    socket!.onDisconnect((_) {
      debugPrint('🔌 [BackgroundService] Socket desconectado temporalmente');
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ [BackgroundService] Error de conexión Socket.io: $err');
    });
  }

  // 1. Recuperar sesión guardada autónomamente de SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    currentFamilyId = prefs.getString('bg_family_id');
    currentUserId = prefs.getString('bg_user_id');
    final savedUrl = prefs.getString('bg_backend_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      backendUrl = savedUrl;
    }

    if (currentFamilyId != null && currentFamilyId.isNotEmpty) {
      debugPrint('🚀 [BackgroundService] Sesión recuperada de almacenamiento para familia $currentFamilyId');
      conectarSocket(currentFamilyId, backendUrl);
    }
  } catch (e) {
    debugPrint('⚠️ [BackgroundService] Error recuperando sesión en arranque de fondo: $e');
  }

  // 2. Escuchar comandos desde la app principal
  service.on('conectar_familia').listen((event) async {
    if (event != null && event['familyId'] != null) {
      currentFamilyId = event['familyId'].toString();
      if (event['userId'] != null) {
        currentUserId = event['userId'].toString();
      }
      if (event['backendUrl'] != null && event['backendUrl'].toString().isNotEmpty) {
        backendUrl = event['backendUrl'].toString();
      }

      try {
        final p = await SharedPreferences.getInstance();
        await p.setString('bg_family_id', currentFamilyId!);
        if (currentUserId != null) {
          await p.setString('bg_user_id', currentUserId!);
        }
        await p.setString('bg_backend_url', backendUrl);
      } catch (_) {}

      conectarSocket(currentFamilyId!, backendUrl);
    }
  });

  service.on('stopService').listen((event) {
    debugPrint('🛑 [BackgroundService] Deteniendo servicio en segundo plano');
    try {
      socket?.disconnect();
      socket?.dispose();
    } catch (_) {}
    service.stopSelf();
  });
}

@pragma('vm:entry-point')
class BackgroundServiceManager {
  /// Inicializa la configuración del servicio en segundo plano
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: true,
        notificationChannelId: 'canal_servicio_segundo_plano',
        initialNotificationTitle: '🌿 Habitik',
        initialNotificationContent: 'Conectado a la red familiar en tiempo real',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Vincula la sesión familiar al servicio en segundo plano
  static Future<void> conectarFamilia(
    String familyId, {
    String? userId,
    String? backendUrl,
  }) async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
    service.invoke('conectar_familia', {
      'familyId': familyId,
      ...?userId != null ? {'userId': userId} : null,
      'backendUrl': backendUrl ?? ApiClient.baseUrl,
    });
  }

  /// Detiene el servicio en segundo plano al cerrar sesión
  static Future<void> detenerServicio() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stopService');
    }
  }
}
