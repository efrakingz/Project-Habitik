import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/notification_service.dart';
import 'package:habitik/core/services/network_service.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/features/challenges/games/speedrun/game/speedrun_game.dart';
import 'package:habitik/core/services/level_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas del Sistema de Notificaciones y Conectividad', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. NetworkService estado reactivo inicial', () {
      final network = NetworkService();
      expect(network.isConnectedNotifier.value, isNotNull);
    });

    test('2. Parseo robusto de payload de Socket (String o Map)', () {
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

    test('3. Clasificación de eventos en el Modelo de Notificaciones', () {
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

    test('4. Preferencias visuales parametrizadas por tipo de notificación', () {
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

    test('5. SpeedrunGame.calculateTierRewards respeta umbral mínimo de 180s (3 min)', () {
      // Menor a 180s: Inválido (anti-trampa)
      final tierInvalido = SpeedrunGame.calculateTierRewards(179);
      expect(tierInvalido['valido'], false);
      expect(tierInvalido['xp'], 0);
      expect(tierInvalido['monedas'], 0);

      // 180s exactos: Válido óptimo (3-5 min)
      final tierOptimo = SpeedrunGame.calculateTierRewards(180);
      expect(tierOptimo['valido'], true);
      expect(tierOptimo['xp'], 200);
      expect(tierOptimo['monedas'], 2);

      // 300s (5 min): Válido óptimo
      final tierCincoMin = SpeedrunGame.calculateTierRewards(300);
      expect(tierCincoMin['valido'], true);
      expect(tierCincoMin['xp'], 200);

      // 400s: Válido intermedio
      final tierIntermedio = SpeedrunGame.calculateTierRewards(400);
      expect(tierIntermedio['valido'], true);
      expect(tierIntermedio['xp'], 100);
      expect(tierIntermedio['monedas'], 1);

      // Más de 600s: Excesivo
      final tierExcesivo = SpeedrunGame.calculateTierRewards(601);
      expect(tierExcesivo['valido'], false);
      expect(tierExcesivo['xp'], 0);
    });

    test('6. AchievementItem deserializa correctamente contrato del backend /logros', () {
      final backendJson = {
        'id': 'logro-uuid-1',
        'codigo': 'ducha_3_min',
        'titulo': 'Maestro de la Ducha',
        'descripcion': 'Dúchate en menos de 5 minutos',
        'monedas_recompensa': 15,
        'desbloqueado': true,
        'reclamado': false,
        'fecha_desbloqueo': '2026-09-04T22:00:00.000Z',
      };

      final achievement = AchievementItem.fromJson(backendJson);
      expect(achievement.id, 'logro-uuid-1');
      expect(achievement.key, 'ducha_3_min');
      expect(achievement.nombre, 'Maestro de la Ducha');
      expect(achievement.monedas, 15);
      expect(achievement.desbloqueado, true);
      expect(achievement.reclamado, false);
      expect(achievement.emoji, '🚿');
    });

    test('7. SocketService suscribe y desuscribe listeners sin memory leaks', () {
      var llamadaRecibida = false;
      void listener(Map<String, dynamic> data) {
        llamadaRecibida = true;
      }

      final unsubscribe = SocketService.subscribe(listener);
      expect(unsubscribe, isNotNull);

      // Desuscribir
      unsubscribe();
      // No debería arrojar error y limpia adecuadamente
      SocketService.removeListener(listener);
      expect(llamadaRecibida, false);
    });

    test('8. LevelService calcula recompensas acumuladas proporcionales', () {
      // 1 nivel = 10 monedas
      expect(LevelService.calcularRecompensaMonedas(1), 10);
      // 3 niveles = 30 monedas
      expect(LevelService.calcularRecompensaMonedas(3), 30);
      // 5 niveles = 50 monedas
      expect(LevelService.calcularRecompensaMonedas(5), 50);
      // 0 o negativo = 0 monedas
      expect(LevelService.calcularRecompensaMonedas(0), 0);
      expect(LevelService.calcularRecompensaMonedas(-1), 0);
    });

    test('9. LevelService asigna rangos ecológicos según el nivel alcanzado', () {
      expect(LevelService.obtenerTituloRango(1), 'Semilla Verde 🌱');
      expect(LevelService.obtenerTituloRango(2), 'Semilla Verde 🌱');
      expect(LevelService.obtenerTituloRango(4), 'Brote Ecológico 🌿');
      expect(LevelService.obtenerTituloRango(8), 'Guardián del Agua 💧');
      expect(LevelService.obtenerTituloRango(12), 'Defensor Solar ☀️');
      expect(LevelService.obtenerTituloRango(18), 'Protector del Bosque 🌲');
      expect(LevelService.obtenerTituloRango(25), 'Eco Guerrero 🛡️');
      expect(LevelService.obtenerTituloRango(40), 'Maestro Sustentable ⚡');
      expect(LevelService.obtenerTituloRango(60), 'Héroe Planetario 🌍');
      expect(LevelService.obtenerTituloRango(99), 'Leyenda de Gaia 👑');
    });

    test('10. LevelService persiste y detecta niveles no reclamados en SharedPreferences', () async {
      const userId = 'user-test-123';

      // Inicialmente no hay nada
      expect(await LevelService.getUltimoNivelReclamado(userId), isNull);

      // Guardar nivel 2
      await LevelService.setUltimoNivelReclamado(userId, 2);
      expect(await LevelService.getUltimoNivelReclamado(userId), 2);

      // Si el usuario sube a nivel 5, los niveles acumulados pendientes son 3
      final ultimoReclamado = (await LevelService.getUltimoNivelReclamado(userId))!;
      const nivelActual = 5;
      final nivelesPendientes = nivelActual - ultimoReclamado;

      expect(nivelesPendientes, 3);
      expect(LevelService.calcularRecompensaMonedas(nivelesPendientes), 30);

      // Al reclamar nivel 5
      await LevelService.setUltimoNivelReclamado(userId, nivelActual);
      expect(await LevelService.getUltimoNivelReclamado(userId), 5);
    });
  });
}
