import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart';

typedef OnEventoRecibido = void Function(Map<String, dynamic> data);

class SocketService {
  static io.Socket? _socket;

  /// Inicializa la conexión en tiempo real con Socket.io en la sala de la familia
  static void initSocket(String familyId, OnEventoRecibido onEvento) {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _socket = io.io(
      ApiClient.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('⚡ [SocketService] Conectado exitosamente al backend en ${ApiClient.baseUrl}');
      _socket!.emit('unirse_familia', familyId);
    });

    _socket!.on('evento_en_vivo', (data) {
      debugPrint('🔔 [SocketService] Evento recibido en vivo: $data');
      try {
        Map<String, dynamic> parsedData;
        if (data is String) {
          parsedData = Map<String, dynamic>.from(jsonDecode(data));
        } else if (data is Map) {
          parsedData = Map<String, dynamic>.from(data);
        } else {
          return;
        }
        onEvento(parsedData);
      } catch (e) {
        debugPrint('⚠️ [SocketService] Error procesando evento de WebSocket: $e');
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 [SocketService] Socket desconectado');
    });

    _socket!.onConnectError((err) {
      debugPrint('⚠️ [SocketService] Error de conexión Socket.io: $err');
    });
  }

  /// Desconecta y libera recursos del socket
  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
