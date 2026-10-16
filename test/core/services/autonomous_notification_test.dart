import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Autonomous Notification & Channels (Habitik)', () {
    test('1. Eco-Curiosidades Gemini: mapeo y preferencias de canal', () {
      final pref = NotificationService.obtenerPreferencias('ECO_CURIOSIDAD');
      expect(pref.canalId, 'canal_eco_curiosidades');
      expect(pref.prefijoEmoji, '💡');
      expect(pref.color, const Color(0xFF00C853));
      expect(pref.canalNombre, contains('Eco-Curiosidades'));

      final prefCuriosidad = NotificationService.obtenerPreferencias('CURIOSIDAD_HABITIK');
      expect(prefCuriosidad.canalId, 'canal_eco_curiosidades');
    });

    test('2. Alertas de Racha: mapeo y preferencias de alta prioridad', () {
      final pref = NotificationService.obtenerPreferencias('ALERTA_RACHA');
      expect(pref.canalId, 'canal_alertas_racha');
      expect(pref.prefijoEmoji, '🔥');
      expect(pref.color, const Color(0xFFFF6D00));
      expect(pref.canalNombre, contains('Racha'));
    });

    test('3. Tips de Onboarding y Hábitos: mapeo y preferencias', () {
      final pref = NotificationService.obtenerPreferencias('TIP_ONBOARDING');
      expect(pref.canalId, 'canal_tips_onboarding');
      expect(pref.prefijoEmoji, '🏡');
      expect(pref.color, const Color(0xFF0091EA));
      expect(pref.canalNombre, contains('Hábitos'));
    });

    test('4. Compatibilidad directa con enum HabitikNotificationType', () {
      final prefEco = NotificationService.obtenerPreferencias(HabitikNotificationType.ecoCuriosidad);
      expect(prefEco.canalId, 'canal_eco_curiosidades');

      final prefRacha = NotificationService.obtenerPreferencias(HabitikNotificationType.alertaRacha);
      expect(prefRacha.canalId, 'canal_alertas_racha');

      final prefTip = NotificationService.obtenerPreferencias(HabitikNotificationType.tipOnboarding);
      expect(prefTip.canalId, 'canal_tips_onboarding');
    });

    test('5. Tipos no reconocidos se degradan grácilmente a general', () {
      final pref = NotificationService.obtenerPreferencias('TIPO_DESCONOCIDO_123');
      expect(pref.canalId, 'canal_alertas_familiares');
      expect(pref.prefijoEmoji, '🌱');
    });
  });
}
