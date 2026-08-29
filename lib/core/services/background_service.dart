import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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

  io.Socket? socket;
  String? currentFamilyId;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    socket?.disconnect();
    socket?.dispose();
    service.stopSelf();
  });

  service.on('conectar_familia').listen((event) {
    if (event != null && event['familyId'] != null) {
      currentFamilyId = event['familyId'].toString();

      if (socket != null) {
        socket!.disconnect();
        socket!.dispose();
      }

      socket = io.io(
        ApiClient.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .build(),
      );

      socket!.onConnect((_) {
        debugPrint('⚡ [BackgroundService] Socket conectado exitosamente');
        if (currentFamilyId != null) {
          socket!.emit('unirse_familia', currentFamilyId);
        }
      });

      socket!.on('evento_en_vivo', (data) async {
        debugPrint('🔔 [BackgroundService] Evento recibido: $data');
        try {
          Map<String, dynamic> parsedData;
          if (data is String) {
            parsedData = Map<String, dynamic>.from(jsonDecode(data));
          } else if (data is Map) {
            parsedData = Map<String, dynamic>.from(data);
          } else {
            return;
          }

          final int notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final String sender = parsedData['usuario_nombre'] ?? parsedData['sender_name'] ?? 'Familiar';
          final String titulo = '${parsedData['titulo'] ?? parsedData['title'] ?? 'Alerta Familiar'}';
          final String cuerpo = '${parsedData['mensaje'] ?? parsedData['desc_text'] ?? 'Nueva notificación'}';

          // 1. Mostrar notificación nativa en el sistema
          await NotificationService.mostrarNotificacionSistema(
            id: notifId,
            titulo: '$sender: $titulo',
            cuerpo: cuerpo,
          );

          // 2. Guardar en el historial local persistente
          if (currentFamilyId != null) {
            await HistoryService.guardarEventoLocal(currentFamilyId!, parsedData);
          }

          // 3. Emitir evento a la UI activa
          service.invoke('nuevo_evento', parsedData);
        } catch (e) {
          debugPrint('⚠️ [BackgroundService] Error procesando evento: $e');
        }
      });
    }
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
        autoStart: false,
        isForegroundMode: false,
        notificationChannelId: 'canal_servicio_segundo_plano',
        initialNotificationTitle: 'Habitik Activo',
        initialNotificationContent: 'Escuchando alertas familiares en segundo plano...',
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
  static Future<void> conectarFamilia(String familyId) async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
    service.invoke('conectar_familia', {'familyId': familyId});
  }
}
