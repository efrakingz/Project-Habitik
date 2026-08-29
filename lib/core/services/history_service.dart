import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class HistoryService {
  static const String _keyPrefix = 'historial_notificaciones_fam_';

  /// Guarda un evento individual en la memoria local (SharedPreferences)
  static Future<void> guardarEventoLocal(String familyId, Map<String, dynamic> evento) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$familyId';
      final List<String> actualList = prefs.getStringList(key) ?? [];

      final jsonStr = jsonEncode(evento);

      // Evitar duplicados por id o timestamp/título
      final yaExiste = actualList.any((itemStr) {
        try {
          final item = jsonDecode(itemStr);
          if (evento['id'] != null && item['id'] != null && item['id'] == evento['id']) {
            return true;
          }
          final bool mismoTitulo = (item['titulo'] ?? item['title']) == (evento['titulo'] ?? evento['title']);
          final bool mismoCreado = (item['creado_en'] ?? item['created_at']) == (evento['creado_en'] ?? evento['created_at']);
          return mismoTitulo && mismoCreado;
        } catch (_) {
          return false;
        }
      });

      if (!yaExiste) {
        actualList.insert(0, jsonStr); // El más reciente primero
        if (actualList.length > 100) {
          actualList.removeRange(100, actualList.length);
        }
        await prefs.setStringList(key, actualList);
        debugPrint('💾 [HistoryService] Evento guardado localmente en caché');
      }
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error al guardar evento localmente: $e');
    }
  }

  /// Obtiene el historial guardado localmente
  static Future<List<Map<String, dynamic>>> obtenerHistorialLocal(String familyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$familyId';
      final List<String> listStr = prefs.getStringList(key) ?? [];

      return listStr.map((str) => Map<String, dynamic>.from(jsonDecode(str))).toList();
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error leyendo historial local: $e');
      return [];
    }
  }

  /// Carga y sincroniza el historial remoto del backend con el caché local
  static Future<List<Map<String, dynamic>>> cargarYSincronizar(String familyId) async {
    final localList = await obtenerHistorialLocal(familyId);

    try {
      final url = Uri.parse('${ApiClient.baseUrl}/notifications/familia/$familyId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exito'] == true) {
          final List remoteList = data['eventos'] ?? data['notificaciones'] ?? [];
          final List<Map<String, dynamic>> combinados = [];

          for (var r in remoteList) {
            final Map<String, dynamic> itemMap = Map<String, dynamic>.from(r);
            combinados.add(itemMap);
            await guardarEventoLocal(familyId, itemMap);
          }

          return combinados;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [HistoryService] No se pudo conectar al backend remoto: $e');
    }

    return localList;
  }

  /// Envía una alerta familiar al backend y la almacena localmente
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
      final url = Uri.parse('${ApiClient.baseUrl}/notifications/evento');
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

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['evento'] != null) {
          await guardarEventoLocal(familyId, Map<String, dynamic>.from(data['evento']));
        }
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error enviando alerta al backend: $e');
    }

    // Si no hay red, guardar en local de todos modos
    final localEvento = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'family_id': familyId,
      'usuario_nombre': usuarioNombre ?? 'Familiar',
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'creado_en': DateTime.now().toIso8601String(),
    };
    await guardarEventoLocal(familyId, localEvento);
    return true;
  }

  /// Limpia el historial tanto en memoria local como en el backend
  static Future<bool> borrarHistorial(String familyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$familyId';
      await prefs.remove(key);

      final url = Uri.parse('${ApiClient.baseUrl}/notifications/familia/$familyId');
      await http.delete(url);
      return true;
    } catch (e) {
      debugPrint('⚠️ [HistoryService] Error borrando historial: $e');
      return false;
    }
  }
}
