import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Notificador reactivo del estado de conexión a internet real
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);

  bool get isConnected => isConnectedNotifier.value;

  /// Inicializa la escucha pasiva de cambios de interfaces de red
  void init() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
    // Verificación inicial de salida a internet
    checkInternet();
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Maneja cambios en interfaces de red (Wi-Fi, datos móviles, desconexión)
  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    final hasNoInterface = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);

    if (hasNoInterface) {
      isConnectedNotifier.value = false;
      return;
    }

    // Si hay una interfaz conectada, verificar acceso real a internet
    await checkInternet();
  }

  /// Verifica activamente si el dispositivo tiene salida a internet real global.
  /// 
  /// NOTA IMPORTANTE: Esta verificación comprueba acceso a internet público,
  /// aislando completamente cualquier error interno del backend de Habitik o
  /// de la base de datos (500, 503, timeout de API). Si el backend falla pero
  /// hay internet, este método retorna `true`.
  Future<bool> checkInternet() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasNoInterface = connectivityResults.isEmpty ||
        (connectivityResults.length == 1 &&
            connectivityResults.first == ConnectivityResult.none);

    if (hasNoInterface) {
      isConnectedNotifier.value = false;
      return false;
    }

    bool hasRealAccess = false;

    if (kIsWeb) {
      try {
        final resp = await http
            .get(Uri.parse('https://clients3.google.com/generate_204'))
            .timeout(const Duration(seconds: 3));
        hasRealAccess = resp.statusCode == 204 || resp.statusCode == 200;
      } catch (_) {
        hasRealAccess = false;
      }
    } else {
      try {
        // Intento 1: Resolución de DNS estándar a google.com
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        hasRealAccess = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        // Intento 2: Fallback por IP directa (Cloudflare DNS 1.1.1.1) por si hay bloqueo de DNS
        try {
          final socket = await Socket.connect('1.1.1.1', 53,
                  timeout: const Duration(seconds: 2))
              .timeout(const Duration(seconds: 3));
          socket.destroy();
          hasRealAccess = true;
        } catch (_) {
          hasRealAccess = false;
        }
      }
    }

    isConnectedNotifier.value = hasRealAccess;
    return hasRealAccess;
  }
}
