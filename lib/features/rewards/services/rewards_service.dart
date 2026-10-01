import 'dart:convert';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/data/models/reward.dart';

class RewardsService {
  final ApiClient _apiClient = ApiClient();

  /// Obtiene el catálogo completo de recompensas de la familia
  Future<List<RewardItem>> getRewards() async {
    try {
      final response = await _apiClient.get('/rewards');
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((e) => RewardItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar recompensas: $e');
    }
  }

  /// Permite al Jefe crear una nueva recompensa
  Future<RewardItem> createReward(Map<String, dynamic> rewardData) async {
    try {
      final response = await _apiClient.post('/rewards/crear', rewardData);
      final data = jsonDecode(response.body);

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Error desconocido');
      }

      // El backend retorna 201 Created y podría retornar los datos o solo un éxito
      if (response.statusCode == 201 || data['success'] == true) {
        return RewardItem.fromJson(data);
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
      final response = await _apiClient.post('/rewards/canjear', {'rewardId': rewardId});
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
}
