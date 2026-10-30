import 'dart:convert';
import '../../data/models/user.dart';
import 'api_client.dart';
import 'session_service.dart';

/// Servicio Singleton para la gestión y edición del perfil de usuario (HU Perfil).
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ApiClient _apiClient = ApiClient();
  final SessionService _sessionService = SessionService();

  /// Actualiza los atributos del perfil (nombre, color, letra, url, telefono)
  /// mediante PUT /perfil/editar
  Future<UserProfile> editarPerfil({
    String? nombre,
    String? color,
    String? letra,
    String? url,
    String? telefono,
  }) async {
    final Map<String, dynamic> body = {};
    if (nombre != null && nombre.trim().isNotEmpty) {
      body['nombre'] = nombre.trim();
    }
    if (color != null && color.trim().isNotEmpty) {
      body['color'] = color.trim();
    }
    if (letra != null && letra.trim().isNotEmpty) {
      body['letra'] = letra.trim().toUpperCase().substring(0, 1);
    }
    if (url != null) {
      body['url'] = url.trim().isEmpty ? null : url.trim();
    }
    if (telefono != null) {
      body['telefono'] = telefono.trim();
    }

    if (body.isEmpty) {
      throw ArgumentError('Debes proporcionar al menos un campo a modificar.');
    }

    // 1. Actualización optimista local inmediata para evitar cualquier desfase visual
    final current = _sessionService.currentUser;
    if (current != null) {
      final optimistic = current.copyWith(
        nombre: (nombre != null && nombre.trim().isNotEmpty) ? nombre.trim() : current.nombre,
        avatarColor: (color != null && color.trim().isNotEmpty) ? color.trim() : current.avatarColor,
        avatarLetra: (letra != null && letra.trim().isNotEmpty) ? letra.trim().toUpperCase() : current.avatarLetra,
        avatarUrl: url != null ? (url.trim().isEmpty ? null : url.trim()) : current.avatarUrl,
        telefono: telefono != null ? (telefono.trim().isEmpty ? null : telefono.trim()) : current.telefono,
      );
      await _sessionService.saveUserProfile(optimistic);
    }

    final response = await _apiClient.put('/perfil/editar', body);
    final dynamic data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300 && data is Map && data['ok'] == true) {
      final updatedUser = UserProfile.fromJson(data['data'] as Map<String, dynamic>);

      // Confirmar estado final retornado por el servidor
      await _sessionService.saveUserProfile(updatedUser);
      return updatedUser;
    } else {
      // Revertir si hubo error en el servidor
      if (current != null) {
        await _sessionService.saveUserProfile(current);
      }
      final errorMsg = data is Map ? (data['error'] ?? data['message']) : null;
      throw Exception(errorMsg ?? 'Error al actualizar el perfil (${response.statusCode})');
    }
  }
}
