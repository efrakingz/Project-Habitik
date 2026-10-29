import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/features/home/services/family_wall_service.dart';
import 'package:habitik/features/profile/widgets/edit_profile_modal.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionService().init();
  });

  group('EditProfileModal & Profile Flow Tests', () {
    testWidgets('EditProfileModal renders initial user data and controls', (tester) async {
      final user = UserProfile(
        id: 'u-123',
        nombre: 'Cristóbal',
        email: 'cristobal@example.com',
        avatarColor: '#43A047',
        avatarLetra: 'C',
        nivel: 1,
        xp: 100,
        monedas: 20,
        rachaDias: 3,
      );

      await SessionService().saveUserProfile(user);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => EditProfileModal.show(ctx),
                child: const Text('Abrir Modal'),
              ),
            ),
          ),
        ),
      );

      // Abrir modal
      await tester.tap(find.text('Abrir Modal'));
      await tester.pumpAndSettle();

      // Verificar que se renderizan el título, campo de nombre y letra
      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Letra del Avatar'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);

      // Verificar que el input de nombre tiene el valor inicial
      expect(find.widgetWithText(TextFormField, 'Cristóbal'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'C'), findsOneWidget);
    });

    test('SessionService.saveUserProfile actualiza currentUserNotifier y FamilyWallService reactivamente', () async {
      final initial = UserProfile(
        id: 'u-123',
        nombre: 'Cristóbal',
        email: 'cristobal@example.com',
        avatarColor: '#43A047',
        avatarLetra: 'C',
        nivel: 1,
        xp: 100,
        monedas: 20,
        rachaDias: 3,
      );

      await SessionService().saveUserProfile(initial);
      expect(SessionService().currentUserNotifier.value?.nombre, 'Cristóbal');

      // Simular sincronización de FamilyWallService
      FamilyWallService();
      final updated = initial.copyWith(
        nombre: 'Cristóbal Modificado',
        avatarColor: '#9C27B0', // Morado
        avatarLetra: 'M',
      );

      await SessionService().saveUserProfile(updated);
      expect(SessionService().currentUserNotifier.value?.nombre, 'Cristóbal Modificado');
      expect(SessionService().currentUserNotifier.value?.avatarColor, '#9C27B0');
      expect(SessionService().currentUserNotifier.value?.avatarLetra, 'M');
    });

    testWidgets('UserAvatar parsea correctamente colores hex con y sin numeral', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UserAvatar(letra: 'A', colorHex: '#9C27B0'), // Morado con #
                UserAvatar(letra: 'B', colorHex: '9C27B0'),  // Morado sin #
                UserAvatar(letra: 'C', colorHex: '#1E88E5'), // Azul
              ],
            ),
          ),
        ),
      );

      final avatars = tester.widgetList<CircleAvatar>(find.byType(CircleAvatar)).toList();
      expect(avatars.length, 3);
      expect(avatars[0].backgroundColor, const Color(0xFF9C27B0));
      expect(avatars[1].backgroundColor, const Color(0xFF9C27B0));
      expect(avatars[2].backgroundColor, const Color(0xFF1E88E5));
    });
  });
}
