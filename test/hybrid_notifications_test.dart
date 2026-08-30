import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/history_service.dart';
import 'package:habitik/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas del Sistema de Notificaciones Híbridas (Frontend)', () {
    const String testFamilyId = 'test-fam-uuid-12345';

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. Guardar y cargar eventos locales en HistoryService', () async {
      final eventoDucha = {
        'id': 'notif-001',
        'family_id': testFamilyId,
        'usuario_nombre': 'Bastian',
        'titulo': '🚿 ¡Hora de la Ducha!',
        'mensaje': 'Bastian ha iniciado una Eco-Ducha de 3 minutos.',
        'tipo': 'DUCHA_SPEEDRUN',
        'creado_en': DateTime.now().toIso8601String(),
        'visual': {'icon': 'shower', 'color': '#00ACC1'},
        'payload': {'duracion_estimada': 180}
      };

      await HistoryService.guardarEventoLocal(testFamilyId, eventoDucha);

      final historial = await HistoryService.obtenerHistorialLocal(testFamilyId);
      expect(historial.length, 1);
      expect(historial.first['titulo'], '🚿 ¡Hora de la Ducha!');
      expect(historial.first['tipo'], 'DUCHA_SPEEDRUN');
      expect(historial.first['usuario_nombre'], 'Bastian');
    });

    test('2. Prevención de eventos duplicados en HistoryService', () async {
      final eventoReto = {
        'id': 'notif-002',
        'family_id': testFamilyId,
        'usuario_nombre': 'Pedro',
        'titulo': '🏆 Reto completado',
        'mensaje': 'Pedro completó la clasificación de plásticos.',
        'tipo': 'RETO_COMPLETADO',
        'creado_en': '2026-08-30T12:00:00.000Z',
      };

      // Guardar dos veces el mismo evento
      await HistoryService.guardarEventoLocal(testFamilyId, eventoReto);
      await HistoryService.guardarEventoLocal(testFamilyId, eventoReto);

      final historial = await HistoryService.obtenerHistorialLocal(testFamilyId);
      expect(historial.length, 1, reason: 'No debe guardar duplicados del mismo ID');
    });

    test('3. Parseo robusto de payload de Socket (String o Map)', () {
      final rawMap = {
        'id': 'notif-003',
        'titulo': 'Alerta en Vivo',
        'mensaje': 'Consumo elevado de agua',
        'tipo': 'ALERTA_GENERAL',
        'usuario_nombre': 'Sistema'
      };

      final jsonString = jsonEncode(rawMap);

      // Simulación de deserialización que realiza el BackgroundService
      Map<String, dynamic> parsedFromString = Map<String, dynamic>.from(jsonDecode(jsonString));
      Map<String, dynamic> parsedFromMap = Map<String, dynamic>.from(rawMap);

      expect(parsedFromString['titulo'], 'Alerta en Vivo');
      expect(parsedFromMap['titulo'], 'Alerta en Vivo');
      expect(parsedFromString['usuario_nombre'], 'Sistema');
    });

    test('4. Clasificación de eventos en el Modelo Híbrido', () {
      final eventos = [
        {'tipo': 'DUCHA_SPEEDRUN', 'urgente': true},
        {'tipo': 'ALERTA_CONSUMO', 'urgente': true},
        {'tipo': 'RETO_COMPLETADO', 'urgente': false},
        {'tipo': 'EVIDENCIA_APROBADA', 'urgente': false},
      ];

      final eventosEnVivo = eventos.where((e) => e['tipo'] == 'DUCHA_SPEEDRUN' || e['tipo'] == 'ALERTA_CONSUMO').toList();
      final eventosFeed = eventos.where((e) => e['tipo'] == 'RETO_COMPLETADO' || e['tipo'] == 'EVIDENCIA_APROBADA').toList();

      expect(eventosEnVivo.length, 2);
      expect(eventosFeed.length, 2);
    });

    test('5. Preferencias visuales parametrizadas por tipo de notificación', () {
      final prefDucha = NotificationService.obtenerPreferencias('DUCHA_SPEEDRUN');
      expect(prefDucha.prefijoEmoji, '🚿');
      expect(prefDucha.canalId, 'canal_alertas_ducha');

      final prefReto = NotificationService.obtenerPreferencias('RETO_COMPLETADO');
      expect(prefReto.prefijoEmoji, '🏆');

      final prefHabito = NotificationService.obtenerPreferencias('RECORDATORIO_HABITO');
      expect(prefHabito.prefijoEmoji, '🌿');

      final prefConsumo = NotificationService.obtenerPreferencias('ALERTA_CONSUMO');
      expect(prefConsumo.prefijoEmoji, '⚡');
    });
  });
}
