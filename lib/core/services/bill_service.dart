import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/bill_record.dart';
import 'api_client.dart';

/// Servicio Singleton para el registro, consulta y auditoría histórica de boletas (HU 3.2).
/// Conecta con `POST /bills` y `GET /bills`, manteniendo persistencia local
/// tolerante a desconexión y sincronización reactiva vía ValueNotifier.
class BillService {
  static final BillService _instance = BillService._internal();
  factory BillService() => _instance;
  BillService._internal();

  static const String _storageKey = 'habitik_bills_history';

  final ApiClient _apiClient = ApiClient();
  final List<BillRecord> _bills = [];
  bool _initialized = false;

  /// Notificador reactivo para que la UI se actualice automáticamente
  final ValueNotifier<List<BillRecord>> billsNotifier =
      ValueNotifier<List<BillRecord>>([]);

  List<BillRecord> get bills => List.unmodifiable(_bills);

  /// Inicializa el servicio cargando el historial desde caché local
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadBills();
  }

  /// Carga el historial de boletas locales y sincroniza con el backend
  Future<List<BillRecord>> loadBills() async {
    // 1. Cargar desde SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final decoded = jsonDecode(savedJson);
        if (decoded is List) {
          _bills.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _bills.add(BillRecord.fromJson(item));
            }
          }
          billsNotifier.value = List.unmodifiable(_bills);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [BillService] Error cargando boletas locales: $e');
    }

    // 2. Intentar refrescar desde el backend si está disponible (timeout no bloqueante)
    try {
      final response = await _apiClient
          .get('/bills')
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic body = jsonDecode(response.body);
        final list = (body is List)
            ? body
            : (body is Map && body['data'] is List ? body['data'] as List : null);

        if (list != null) {
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final remote = BillRecord.fromJson(item);
              if (!_bills.any((b) => b.id == remote.id)) {
                _bills.add(remote);
              }
            }
          }
          await _persistLocal();
          billsNotifier.value = List.unmodifiable(_bills);
        }
      }
    } catch (e) {
      // Backend no disponible o offline: se mantiene el historial local sin romper la UX
      debugPrint('ℹ️ [BillService] Backend offline o sin endpoint /bills, usando historial local');
    }

    return List.unmodifiable(_bills);
  }

  /// Registra una nueva boleta auditada con respaldo documental temporal vinculado
  Future<BillRecord> registerBill(BillRecord bill) async {
    final recordToSave = bill.id.isEmpty
        ? bill.copyWith(id: 'bill_${DateTime.now().millisecondsSinceEpoch}')
        : bill;

    // 1. Guardar de inmediato en memoria y caché local (auditoría persistente)
    _bills.insert(0, recordToSave);
    billsNotifier.value = List.unmodifiable(_bills);
    await _persistLocal();
    debugPrint('📄 [BillService] Boleta registrada localmente: ${recordToSave.id} (${recordToSave.tipoServicio})');

    // 2. Transmitir datos estructurados al backend (POST /bills)
    try {
      final response = await _apiClient.post(
        '/bills',
        recordToSave.toBackendPayload(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final remoteRecord = BillRecord.fromJson(body);
          final index = _bills.indexWhere((item) => item.id == recordToSave.id);
          if (index >= 0) {
            _bills[index] = remoteRecord;
            billsNotifier.value = List.unmodifiable(_bills);
            await _persistLocal();
          }
        }
        debugPrint('✅ [BillService] Boleta sincronizada exitosamente con el backend');
      } else {
        debugPrint('⚠️ [BillService] Servidor respondió con código ${response.statusCode}, guardada en caché');
      }
    } catch (e) {
      debugPrint('⚠️ [BillService] Error de red al enviar a /bills: $e. Registro preservado en dispositivo.');
    }

    return recordToSave;
  }

  /// Guarda en SharedPreferences
  Future<void> _persistLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = _bills.map((b) => b.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(listMap));
    } catch (e) {
      debugPrint('⚠️ [BillService] Error persistiendo historial local: $e');
    }
  }

  /// Limpia todo el historial local (utilizado para pruebas)
  Future<void> clearAll() async {
    _bills.clear();
    billsNotifier.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
