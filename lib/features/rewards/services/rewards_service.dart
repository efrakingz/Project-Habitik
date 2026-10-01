import 'dart:convert';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/data/models/models.dart';

class RewardsService {
  final ApiClient _apiClient = ApiClient();

  /// Obtiene el catálogo completo de recompensas de la familia
  Future<List<RewardItem>> getRewards() async {
    try {
      final response = await _apiClient.get('/rewards');
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => RewardItem.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar recompensas: $e');
    }
  }

  /// Permite al Jefe crear una nueva recompensa
  Future<RewardItem> createReward(Map<String, dynamic> rewardPayload) async {
    try {
      final response = await _apiClient.post('/rewards/crear', rewardPayload);
      final data = jsonDecode(response.body);

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Error desconocido');
      }

      // El backend retorna 201 Created con los datos del premio creado
      if (response.statusCode == 201 || data['success'] == true) {
        final parsed = data['data'] ?? data;
        return RewardItem.fromJson(parsed as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] ?? 'No se pudo crear el premio.');
      }
    } catch (e) {
      throw Exception('Error al crear premio: $e');
    }
  }

  /// Permite a cualquier miembro canjear una recompensa
  Future<Map<String, dynamic>> redeemReward(int rewardId) async {
    try {
      final response = await _apiClient.post('/rewards/canjear', {
        'rewardId': rewardId,
      });
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return {
          'message': data['message'],
          'monedas_restantes': data['monedas_restantes'],
        };
      } else {
        throw Exception(data['message'] ?? 'Error al canjear premio.');
      }
    } catch (e) {
      throw Exception('Error de canje: $e');
    }
  }

  /// Permite al Jefe obtener las solicitudes de canje pendientes
  Future<List<PendingCanje>> getPendingCanjes() async {
    try {
      final response = await _apiClient.get('/rewards/canjes/pendientes');
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => PendingCanje.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar solicitudes pendientes: $e');
    }
  }

  /// Permite al Jefe aprobar una solicitud de canje
  Future<void> approveCanje(String canjeId) async {
    try {
      final response = await _apiClient.patch(
        '/rewards/canjes/$canjeId/aprobar',
        {},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al aprobar solicitud.');
      }
    } catch (e) {
      throw Exception('Error al aprobar: $e');
    }
  }

  /// Permite al Jefe rechazar una solicitud de canje
  Future<void> rejectCanje(String canjeId) async {
    try {
      final response = await _apiClient.patch(
        '/rewards/canjes/$canjeId/rechazar',
        {},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al rechazar solicitud.');
      }
    } catch (e) {
      throw Exception('Error al rechazar: $e');
    }
  }
}
