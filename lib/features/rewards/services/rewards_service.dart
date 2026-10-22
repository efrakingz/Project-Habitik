import 'dart:convert';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/data/models/models.dart';

class RewardsCatalogResponse {
  final List<RewardItem> rewards;
  final RewardItem? propuestaHoy;
  final List<FamilyColecta> colectasActivas;

  const RewardsCatalogResponse({
    required this.rewards,
    this.propuestaHoy,
    this.colectasActivas = const [],
  });
}

class RewardsService {
  final ApiClient _apiClient = ApiClient();

  /// Obtiene el catálogo completo de recompensas, propuesta diaria y colectas activas
  Future<RewardsCatalogResponse> getCatalog() async {
    try {
      final response = await _apiClient.get('/rewards');
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<RewardItem> rewards = [];
        final rawRewards = data['rewards'] ?? data['data'];
        if (rawRewards is List) {
          for (final item in rawRewards) {
            if (item is Map<String, dynamic>) {
              rewards.add(RewardItem.fromJson(item));
            } else if (item is Map) {
              rewards.add(RewardItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }

        RewardItem? propuestaHoy;
        if (data['propuesta_hoy'] != null && data['propuesta_hoy'] is Map) {
          propuestaHoy = RewardItem.fromJson(Map<String, dynamic>.from(data['propuesta_hoy']));
        }

        final List<FamilyColecta> colectas = [];
        if (data['colectas_activas'] is List) {
          for (final c in data['colectas_activas']) {
            if (c is Map) {
              colectas.add(FamilyColecta.fromJson(Map<String, dynamic>.from(c)));
            }
          }
        }

        return RewardsCatalogResponse(
          rewards: rewards,
          propuestaHoy: propuestaHoy,
          colectasActivas: colectas,
        );
      }
      return const RewardsCatalogResponse(rewards: []);
    } catch (e) {
      throw Exception('Error al cargar recompensas: $e');
    }
  }

  /// Wrapper de compatibilidad para obtener solo la lista de recompensas
  Future<List<RewardItem>> getRewards() async {
    final catalog = await getCatalog();
    return catalog.rewards;
  }

  /// Permite al Jefe crear una nueva recompensa directamente
  Future<RewardItem> createReward(Map<String, dynamic> rewardPayload) async {
    try {
      final response = await _apiClient.post('/rewards/crear', rewardPayload);
      final data = jsonDecode(response.body);

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Error desconocido');
      }

      if (response.statusCode == 201 || data['success'] == true) {
        final parsed = data['data'] ?? data;
        return RewardItem.fromJson(Map<String, dynamic>.from(parsed as Map));
      } else {
        throw Exception(data['message'] ?? 'No se pudo crear el premio.');
      }
    } catch (e) {
      throw Exception('Error al crear premio: $e');
    }
  }

  /// Permite a cualquier miembro proponer un premio personal (máx 1 al día)
  Future<RewardItem> proposeReward({
    required String titulo,
    String? descripcion,
    String? emoji,
  }) async {
    try {
      final response = await _apiClient.post('/rewards/proponer', {
        'titulo': titulo,
        'descripcion': descripcion,
        'emoji': emoji ?? '🎁',
      });
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return RewardItem.fromJson(Map<String, dynamic>.from(data['data'] as Map));
      } else {
        throw Exception(data['message'] ?? 'No se pudo enviar la propuesta.');
      }
    } catch (e) {
      throw Exception('Error al enviar propuesta: $e');
    }
  }

  /// Permite al Jefe obtener las propuestas de premios pendientes
  Future<List<RewardProposal>> getPendingProposals() async {
    try {
      final response = await _apiClient.get('/rewards/propuestas/pendientes');
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => RewardProposal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar propuestas pendientes: $e');
    }
  }

  /// Permite al Jefe aprobar una propuesta, fijar monedas y opcionalmente convertirla en premio familiar colaborativo
  Future<void> approveProposal(
    int proposalId, 
    int costo, {
    bool? esFamiliar,
    String? titulo,
    String? descripcion,
    String? icono,
  }) async {
    try {
      final body = <String, dynamic>{
        'costo': costo,
        'es_familiar': ?esFamiliar,
        if (titulo != null && titulo.isNotEmpty) 'titulo': titulo,
        'descripcion': ?descripcion,
        if (icono != null && icono.isNotEmpty) 'icono': icono,
      };
      final response = await _apiClient.patch(
        '/rewards/propuestas/$proposalId/aprobar',
        body,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al aprobar propuesta.');
      }
    } catch (e) {
      throw Exception('Error al aprobar propuesta: $e');
    }
  }

  /// Permite al Jefe rechazar una propuesta de premio
  Future<void> rejectProposal(int proposalId, {String? motivo}) async {
    try {
      final response = await _apiClient.patch(
        '/rewards/propuestas/$proposalId/rechazar',
        {'motivo': motivo},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Error al rechazar propuesta.');
      }
    } catch (e) {
      throw Exception('Error al rechazar propuesta: $e');
    }
  }

  /// Inicia o aporta a una colecta familiar colaborativa
  Future<Map<String, dynamic>> contributeColecta(int rewardId) async {
    try {
      final response = await _apiClient.post('/rewards/colecta/aportar', {
        'rewardId': rewardId,
      });
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data as Map<String, dynamic>;
      } else {
        throw Exception(data['message'] ?? 'Error al aportar a la colecta.');
      }
    } catch (e) {
      throw Exception('Error de aporte colectivo: $e');
    }
  }

  /// Permite a cualquier miembro canjear una recompensa personal
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
  Future<void> rejectCanje(String canjeId, {String? motivo}) async {
    try {
      final response = await _apiClient.patch(
        '/rewards/canjes/$canjeId/rechazar',
        {'motivo': motivo},
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
