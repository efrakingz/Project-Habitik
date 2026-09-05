import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class HistoryService {
  /// Carga el historial de notificaciones directamente desde el backend a través de ApiClient
  static Future<List<Map<String, dynamic>>> cargarYSincronizar(String familyId) async {
    try {
      final response = await ApiClient().get('/notifications/familia/$familyId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exito'] == true) {
          final List remoteList = data['eventos'] ?? data['notificaciones'] ?? [];
          return remoteList.map((r) => Map<String, dynamic>.from(r)).toList();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error al obtener notificaciones del backend: $e');
    }

    return [];
  }

  /// Envía una alerta familiar al backend con reintento y headers gestionados por ApiClient
  static Future<bool> enviarAlertaFamilia({
    required String familyId,
    String? usuarioId,
    String? usuarioNombre,
    required String titulo,
    required String mensaje,
    String tipo = 'ALERTA_GENERAL',
    Map<String, dynamic>? visual,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final body = {
        'family_id': familyId,
        'user_id': usuarioId,
        'sender_id': usuarioId,
        'sender_name': usuarioNombre,
        'title': titulo,
        'desc_text': mensaje,
        'type': tipo,
        'visual': visual ?? {'icon': 'notifications', 'color': '#388E3C'},
        'payload': payload ?? {},
      };

      final response = await ApiClient().post('/notifications/evento', body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error enviando alerta al backend: $e');
      return false;
    }
  }

  /// Elimina el historial en el backend
  static Future<bool> borrarHistorial(String familyId) async {
    try {
      final response = await ApiClient().delete('/notifications/familia/$familyId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error borrando historial: $e');
      return false;
    }
  }
}
