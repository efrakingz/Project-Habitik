import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiClient {
  /// IP local de la computadora en la red Wi-Fi
  static const String localIp = '192.168.1.14';

  /// Servidor backend:
  /// En Web o Desktop usa localhost:3000.
  /// En dispositivos móviles (físicos o emuladores) usa la IP local para conectividad total en la red.
  static String localBaseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://$localIp:3000';

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

  final _sessionService = SessionService();

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

  /// Realiza una petición GET con re-intento transparente si el token caducó
  Future<http.Response> get(String path, {bool isRetry = false}) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.get(url, headers: _headers());
      return await _processResponse(response, () => get(path, isRetry: true), isRetry);
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      throw Exception('Error de conexión con el servidor: $e');
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
      final response = await http.post(
        url,
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return await _processResponse(
        response,
        () => post(path, body, token: token, isRetry: true),
        isRetry,
      );
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      throw Exception('Error de conexión con el servidor: $e');
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
      final response = await http.patch(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );
      return await _processResponse(
        response,
        () => patch(path, body, isRetry: true),
        isRetry,
      );
    } catch (e) {
      if (e is UnauthorizedException || e is GoneException || e is ForbiddenException) rethrow;
      throw Exception('Error de conexión con el servidor: $e');
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
