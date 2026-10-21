import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeService - Caché y Persistencia Inteligente', () {
    test('Si nunca se modificó manualmente, sigue los cambios del sistema celular', () async {
      SharedPreferences.setMockInitialValues({});
      isDarkModeNotifier.value = false;

      // Cambio del sistema operativo a oscuro
      await ThemeService.onSystemBrightnessChanged(Brightness.dark);
      expect(isDarkModeNotifier.value, isTrue);

      // Cambio del sistema operativo a claro
      await ThemeService.onSystemBrightnessChanged(Brightness.light);
      expect(isDarkModeNotifier.value, isFalse);

      final hasOverride = await ThemeService.hasManualOverride();
      expect(hasOverride, isFalse);
    });

    test('Si el usuario fijó manualmente modo oscuro, el celular NO sobrescribe la preferencia', () async {
      SharedPreferences.setMockInitialValues({});

      // El usuario activa el modo oscuro en la app
      await ThemeService.setDarkMode(true);
      expect(isDarkModeNotifier.value, isTrue);
      expect(await ThemeService.hasManualOverride(), isTrue);

      // El sistema operativo cambia a día (Brightness.light)
      await ThemeService.onSystemBrightnessChanged(Brightness.light);

      // Debe mantenerse en oscuro según la orden del usuario
      expect(isDarkModeNotifier.value, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ThemeService.keyDarkMode), isTrue);
      expect(prefs.getBool(ThemeService.keyManualOverride), isTrue);
    });

    test('Si el usuario fijó manualmente modo claro, el cambio nocturno del celular se ignora', () async {
      SharedPreferences.setMockInitialValues({});

      // El usuario activa modo claro
      await ThemeService.setDarkMode(false);
      expect(isDarkModeNotifier.value, isFalse);

      // Llega la noche en el celular (Brightness.dark)
      await ThemeService.onSystemBrightnessChanged(Brightness.dark);

      // Debe mantenerse en claro
      expect(isDarkModeNotifier.value, isFalse);
    });

    test('resetToSystem vuelve a activar el seguimiento automático', () async {
      SharedPreferences.setMockInitialValues({});

      // Manual
      await ThemeService.setDarkMode(true);
      expect(await ThemeService.hasManualOverride(), isTrue);

      // Restablecer a automático
      await ThemeService.resetToSystem();
      expect(await ThemeService.hasManualOverride(), isFalse);

      // Ahora el sistema vuelve a tener el control
      await ThemeService.onSystemBrightnessChanged(Brightness.light);
      expect(isDarkModeNotifier.value, isFalse);
    });
  });
}
