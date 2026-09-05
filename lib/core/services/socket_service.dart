import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart';

typedef OnEventoRecibido = void Function(Map<String, dynamic> data);

class SocketService {
  static io.Socket? _socket;
  static String? _currentFamilyId;
  static String? _currentBaseUrl;

  /// Suscriptores activos al bus de eventos de WebSocket
  static final List<OnEventoRecibido> _listeners = [];

  /// Conecta o asegura la conexión a la sala familiar sin destruir conexiones activas
  static void initSocket(String familyId, [OnEventoRecibido? onEvento]) {
    if (onEvento != null && !_listeners.contains(onEvento)) {
      _listeners.add(onEvento);
    }

    // Si ya estamos conectados al mismo backend y sala, no reiniciar
    if (_socket != null &&
        _socket!.connected &&
        _currentFamilyId == familyId &&
        _currentBaseUrl == ApiClient.baseUrl) {
      return;
    }

    // Si la sala o URL cambiaron, desconectar el anterior
    if (_socket != null) {
      try {
        _socket!.disconnect();
        _socket!.dispose();
      } catch (_) {}
      _socket = null;
    }

    _currentFamilyId = familyId;
    _currentBaseUrl = ApiClient.baseUrl;

    _socket = io.io(
      ApiClient.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1500)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('⚡ [SocketService] Conectado exitosamente al backend en ${ApiClient.baseUrl}');
      _socket!.emit('unirse_familia', familyId);
    });

    _socket!.on('reconnect', (_) {
      debugPrint('⚡ [SocketService] Socket reconectado a sala familiar');
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

        // Difundir a todos los suscriptores activos
        final listenersCopy = List<OnEventoRecibido>.from(_listeners);
        for (final listener in listenersCopy) {
          try {
            listener(parsedData);
          } catch (e) {
            debugPrint('⚠️ [SocketService] Error en listener: $e');
          }
        }
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

  /// Suscribe un listener al bus de eventos y retorna una función para cancelar la suscripción
  static VoidCallback subscribe(OnEventoRecibido listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
    return () {
      _listeners.remove(listener);
    };
  }

  /// Desuscribe un listener específico
  static void removeListener(OnEventoRecibido listener) {
    _listeners.remove(listener);
  }

  /// Desconecta y libera recursos del socket
  static void disconnect() {
    _listeners.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentFamilyId = null;
    _currentBaseUrl = null;
  }
}
