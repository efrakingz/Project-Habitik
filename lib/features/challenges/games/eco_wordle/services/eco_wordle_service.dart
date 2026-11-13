import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:habitik/core/services/api_client.dart';
import '../models/eco_wordle_models.dart';

class EcoWordleService {
  static final EcoWordleService _instance = EcoWordleService._internal();
  factory EcoWordleService() => _instance;
  EcoWordleService._internal();

  Future<EcoWordleStatus?> getTodayStatus() async {
    try {
      final response = await ApiClient().get('/wordle/hoy');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return EcoWordleStatus.fromJson(data['data']);
      }
    } catch (e) {
      debugPrint('❌ [EcoWordleService] Error al obtener estado: $e');
    }
    return null;
  }

  Future<EcoWordleStatus?> startNewGame() async {
    try {
      final response = await ApiClient().post('/wordle/nueva', {});
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return EcoWordleStatus.fromJson(data['data']);
      }
    } catch (e) {
      debugPrint('❌ [EcoWordleService] Error al iniciar nueva partida: $e');
    }
    return null;
  }

  Future<EcoWordleAttemptResult?> submitAttempt(String word, {String? sesionId}) async {
    try {
      final response = await ApiClient().post(
        '/wordle/intentar',
        {
          'intento': word,
          if (sesionId != null && sesionId.isNotEmpty) 'sesion_id': sesionId,
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return EcoWordleAttemptResult.fromJson(data);
      }
    } catch (e) {
      debugPrint('❌ [EcoWordleService] Error al enviar intento: $e');
    }
    return null;
  }

  Future<String?> unlockHint({String? sesionId}) async {
    try {
      final response = await ApiClient().post(
        '/wordle/pista',
        {
          if (sesionId != null && sesionId.isNotEmpty) 'sesion_id': sesionId,
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['pista'] as String?;
      }
    } catch (e) {
      debugPrint('❌ [EcoWordleService] Error al desbloquear pista: $e');
    }
    return null;
  }
}
