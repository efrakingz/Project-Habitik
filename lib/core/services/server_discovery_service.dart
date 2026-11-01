import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio de descubrimiento automático del servidor local Habitik en la red Wi-Fi.
///
/// Utiliza dos estrategias complementarias:
/// 1. Baliza de difusión UDP (Broadcast en puerto 3334) de latencia ultra baja (< 15 ms).
/// 2. Barrido inteligente de subred HTTP (/ en puerto 3000) como respaldo si el router bloquea UDP.
class ServerDiscoveryService {
  static final ServerDiscoveryService _instance = ServerDiscoveryService._internal();
  factory ServerDiscoveryService() => _instance;
  ServerDiscoveryService._internal();

  static const int udpDiscoveryPort = 3334;
  static const int defaultHttpPort = 3000;

  /// Busca automáticamente el servidor Habitik en la red local actual.
  /// Devuelve la URL base (ej: 'http://192.168.1.10:3000') o null si no se localiza.
  Future<String?> discoverServer({
    Duration udpTimeout = const Duration(milliseconds: 1200),
    Duration sweepTimeout = const Duration(milliseconds: 350),
  }) async {
    if (kIsWeb) {
      debugPrint('🔍 [ServerDiscovery] Entorno Web detectado, usando localhost:3000');
      return 'http://localhost:3000';
    }

    // Estrategia 1: Baliza UDP Broadcast (instantánea)
    try {
      debugPrint('🔍 [ServerDiscovery] Iniciando búsqueda por difusión UDP en puerto $udpDiscoveryPort...');
      final udpResult = await _discoverViaUdp(udpTimeout);
      if (udpResult != null && udpResult.isNotEmpty) {
        debugPrint('✅ [ServerDiscovery] ¡Servidor detectado vía UDP Broadcast en $udpResult!');
        return udpResult;
      }
    } catch (e) {
      debugPrint('⚠️ [ServerDiscovery] UDP Broadcast no disponible o bloqueado: $e');
    }

    // Estrategia 2: Barrido inteligente de subred HTTP
    try {
      debugPrint('🔍 [ServerDiscovery] Iniciando barrido inteligente de subred Wi-Fi...');
      final sweepResult = await _discoverViaSubnetSweep(sweepTimeout);
      if (sweepResult != null && sweepResult.isNotEmpty) {
        debugPrint('✅ [ServerDiscovery] ¡Servidor detectado vía barrido HTTP en $sweepResult!');
        return sweepResult;
      }
    } catch (e) {
      debugPrint('⚠️ [ServerDiscovery] Error en barrido de subred: $e');
    }

    debugPrint('❌ [ServerDiscovery] No se pudo encontrar un servidor Habitik activo en la red local.');
    return null;
  }

  /// Estrategia 1: Envía datagrama broadcast 'HABITIK_DISCOVER' y espera respuesta JSON
  Future<String?> _discoverViaUdp(Duration timeout) async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final completer = Completer<String?>();
      final payload = utf8.encode('HABITIK_DISCOVER');

      // Escuchar respuestas de datagrama
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket?.receive();
          if (datagram != null) {
            try {
              final text = utf8.decode(datagram.data);
              final json = jsonDecode(text) as Map<String, dynamic>;
              if (json['app'] != null && json['url'] != null) {
                if (!completer.isCompleted) {
                  completer.complete(json['url'].toString());
                }
              } else if (json['ip'] != null) {
                final ip = json['ip'];
                final port = json['port'] ?? defaultHttpPort;
                if (!completer.isCompleted) {
                  completer.complete('http://$ip:$port');
                }
              }
            } catch (_) {}
          }
        }
      });

      // Enviar a dirección universal de broadcast
      socket.send(payload, InternetAddress('255.255.255.255'), udpDiscoveryPort);

      // Enviar también a los broadcast específicos de cada interfaz local
      try {
        final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
        for (final iface in interfaces) {
          for (final addr in iface.addresses) {
            if (!addr.isLoopback) {
              final parts = addr.address.split('.');
              if (parts.length == 4) {
                final subnetBroadcast = '${parts[0]}.${parts[1]}.${parts[2]}.255';
                socket.send(payload, InternetAddress(subnetBroadcast), udpDiscoveryPort);
              }
            }
          }
        }
      } catch (_) {}

      // Temporizador de espera
      Timer(timeout, () {
        if (!completer.isCompleted) completer.complete(null);
      });

      return await completer.future;
    } finally {
      socket?.close();
    }
  }

  /// Estrategia 2: Identifica la subred de este dispositivo y prueba los hosts candidatos
  Future<String?> _discoverViaSubnetSweep(Duration perRequestTimeout) async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    String? localIp;

    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback &&
            !addr.address.startsWith('127.') &&
            !addr.address.startsWith('169.254.')) {
          localIp = addr.address;
          break;
        }
      }
      if (localIp != null) break;
    }

    if (localIp == null) {
      debugPrint('⚠️ [ServerDiscovery] No se identificó IP de red local válida.');
      return null;
    }

    final parts = localIp.split('.');
    if (parts.length != 4) return null;
    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

    // Lista priorizada de candidatos (notebooks suelen recibir IPs bajas o comunes)
    final prioritySuffixes = [10, 50, 2, 3, 4, 5, 15, 16, 20, 25, 100, 101, 102, 1];
    final remainingSuffixes = <int>[];
    for (int i = 1; i <= 254; i++) {
      if (!prioritySuffixes.contains(i)) {
        remainingSuffixes.add(i);
      }
    }

    final allCandidates = [...prioritySuffixes, ...remainingSuffixes];

    // Ejecutar en lotes concurrentes para no saturar los descriptores de red
    const batchSize = 25;
    for (int i = 0; i < allCandidates.length; i += batchSize) {
      final batch = allCandidates.sublist(
        i,
        i + batchSize > allCandidates.length ? allCandidates.length : i + batchSize,
      );

      final futures = batch.map((suffix) async {
        final host = '$subnet.$suffix';
        final testUrl = 'http://$host:$defaultHttpPort/';
        try {
          final res = await http.get(Uri.parse(testUrl)).timeout(perRequestTimeout);
          if (res.statusCode == 200 && res.body.contains('Habitik')) {
            return 'http://$host:$defaultHttpPort';
          }
        } catch (_) {}
        return null;
      });

      final results = await Future.wait(futures);
      for (final found in results) {
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Mide la latencia HTTP hacia un servidor determinado
  Future<int?> pingServer(String baseUrl) async {
    try {
      final sw = Stopwatch()..start();
      String clean = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
        clean = 'http://$clean';
      }
      final res = await http.get(Uri.parse('$clean/')).timeout(const Duration(seconds: 3));
      sw.stop();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return sw.elapsedMilliseconds;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

