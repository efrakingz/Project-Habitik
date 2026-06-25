import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiClient {
  // En emuladores Android, 'localhost' es '10.0.2.2'. Para simuladores iOS y Desktop es 'localhost'.
  // Para pruebas en celular físico o emulador con base de datos en la nube, apuntamos a producción en Railway:
  static String baseUrl =
      'https://project-habitik-production-f935.up.railway.app';

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

  /// Realiza una petición GET
  Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.get(url, headers: _headers());
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  /// Realiza una petición POST
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.post(
        url,
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  /// Realiza una petición PATCH
  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.patch(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  /// Maneja y valida la respuesta HTTP
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // Decodificar mensaje de error si está en formato JSON
    String errorMsg = 'Error en la solicitud (${response.statusCode})';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('message')) {
        errorMsg = data['message'];
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      // Token inválido o expirado -> Cerrar sesión
      _sessionService.clearSession();
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
