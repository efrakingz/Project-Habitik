import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiClient {
  /// IP local de la computadora en la red Wi-Fi / Ethernet
  static const String localIp = '192.168.1.16';

  /// Servidor backend:
  /// - En Web o Desktop usa localhost:3000.
  /// - En emulador Android usa 10.0.2.2:3000 (el túnel directo de QEMU a localhost de Windows).
  /// - En dispositivos móviles físicos usa la IP local (192.168.1.16:3000).
  static String get localBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://$localIp:3000';
  }

  static String productionBaseUrl = 'https://backend-habitik.onrender.com';

  /// URL activa del backend (por defecto local cuando se está desarrollando)
  static String baseUrl = productionBaseUrl;

  /// Permite alternar y configurar la URL base del backend
  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Cliente HTTP persistente con connection pooling y keep-alive
  final http.Client _httpClient = http.Client();
  final _sessionService = SessionService();

  static const Duration _timeout = Duration(seconds: 15);

  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final activeToken = token ?? _sessionService.token;
    if (activeToken != null && activeToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $activeToken';
    }
    return headers;
  }

  bool _canFallbackIp() {
    return baseUrl.contains('10.0.2.2') || baseUrl.contains(localIp);
  }

  void _switchFallbackIp() {
    if (baseUrl.contains('10.0.2.2')) {
      debugPrint('🔄 [ApiClient] Alternando automáticamente a IP de red: http://$localIp:3000');
      baseUrl = 'http://$localIp:3000';
    } else if (baseUrl.contains(localIp) && defaultTargetPlatform == TargetPlatform.android) {
      debugPrint('🔄 [ApiClient] Alternando automáticamente a emulador: http://10.0.2.2:3000');
      baseUrl = 'http://10.0.2.2:3000';
    }
  }

  /// Realiza una petición GET con re-intento transparente si el token caducó
  Future<http.Response> get(String path, {bool isRetry = false}) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient
          .get(url, headers: _headers())
          .timeout(_timeout);
      return await _processResponse(response, () => get(path, isRetry: true), isRetry);
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      if (!isRetry && _canFallbackIp()) {
        _switchFallbackIp();
        return get(path, isRetry: true);
      }
      if (e is TimeoutException) throw Exception('Tiempo de espera agotado con el servidor ($baseUrl).');
      throw Exception('Error de conexión con el servidor ($baseUrl): $e');
    }
  }

  /// Realiza una petición POST con re-intento transparente
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient
          .post(
            url,
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return await _processResponse(
        response,
        () => post(path, body, token: token, isRetry: true),
        isRetry,
      );
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      if (!isRetry && _canFallbackIp()) {
        _switchFallbackIp();
        return post(path, body, token: token, isRetry: true);
      }
      if (e is TimeoutException) throw Exception('Tiempo de espera agotado con el servidor ($baseUrl).');
      throw Exception('Error de conexión con el servidor ($baseUrl): $e');
    }
  }

  /// Realiza una petición PATCH con re-intento transparente
  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient
          .patch(
            url,
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return await _processResponse(
        response,
        () => patch(path, body, isRetry: true),
        isRetry,
      );
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      if (!isRetry && _canFallbackIp()) {
        _switchFallbackIp();
        return patch(path, body, isRetry: true);
      }
      if (e is TimeoutException) throw Exception('Tiempo de espera agotado con el servidor ($baseUrl).');
      throw Exception('Error de conexión con el servidor ($baseUrl): $e');
    }
  }

  /// Realiza una petición PUT con re-intento transparente
  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient
          .put(
            url,
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return await _processResponse(
        response,
        () => put(path, body, isRetry: true),
        isRetry,
      );
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      if (!isRetry && _canFallbackIp()) {
        _switchFallbackIp();
        return put(path, body, isRetry: true);
      }
      if (e is TimeoutException) throw Exception('Tiempo de espera agotado con el servidor ($baseUrl).');
      throw Exception('Error de conexión con el servidor ($baseUrl): $e');
    }
  }

  /// Realiza una petición DELETE con re-intento transparente
  Future<http.Response> delete(String path, {bool isRetry = false}) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient
          .delete(url, headers: _headers())
          .timeout(_timeout);
      return await _processResponse(
        response,
        () => delete(path, isRetry: true),
        isRetry,
      );
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      if (!isRetry && _canFallbackIp()) {
        _switchFallbackIp();
        return delete(path, isRetry: true);
      }
      if (e is TimeoutException) throw Exception('Tiempo de espera agotado con el servidor ($baseUrl).');
      throw Exception('Error de conexión con el servidor ($baseUrl): $e');
    }
  }

  /// Procesa la respuesta HTTP y realiza re-autenticación silenciosa en 401 antes de desloguear
  Future<http.Response> _processResponse(
    http.Response response,
    Future<http.Response> Function() retryAction,
    bool isRetry,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    String errorMsg = 'Error en la solicitud (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        errorMsg = data['message'];
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      // Intentar re-autenticación silenciosa antes de expulsar al usuario
      if (!isRetry) {
        final relogged = await _sessionService.silentRelogin();
        if (relogged) {
          // Reintentar la petición original con el nuevo token
          return await retryAction();
        }
      }
      // Solo si el re-login silencioso falla, desloguear
      await _sessionService.clearSession();
      throw UnauthorizedException(errorMsg);
    } else if (response.statusCode == 410) {
      throw GoneException(errorMsg);
    } else if (response.statusCode == 403) {
      throw ForbiddenException(errorMsg);
    }

    throw Exception(errorMsg);
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class GoneException implements Exception {
  final String message;
  GoneException(this.message);
  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => message;
}
