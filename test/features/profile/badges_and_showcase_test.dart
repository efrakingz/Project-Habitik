import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/features/profile/widgets/badge_tile.dart';
import 'package:habitik/features/profile/widgets/profile_badges_card.dart';
import 'package:habitik/features/profile/trophy_showcase_screen.dart';
import 'package:habitik/shared/widgets/modals/badge_unlocked_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Módulo de Logros y Vitrina - Sprint 4', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SessionService().init();
    });

    test('Contrato Backend: Deserialización de AchievementItem según PDF oficial', () {
      final backendJson = {
        'id': 'ca5f187f-9bbb-46fc-bda1-b65f959cd4fd',
        'codigo': 'PRIMERA_DUCHA',
        'titulo': 'Ducha Eficiente',
        'descripcion': 'Completa tu primer Speedrun de Ducha válido',
        'monedas_recompensa': 10,
        'desbloqueado': true,
        'reclamado': false,
        'fecha_desbloqueo': '2026-10-26T20:00:00.000Z',
      };

      final badge = AchievementItem.fromJson(backendJson);

      expect(badge.id, 'ca5f187f-9bbb-46fc-bda1-b65f959cd4fd');
      expect(badge.key, 'PRIMERA_DUCHA');
      expect(badge.nombre, 'Ducha Eficiente');
      expect(badge.descripcion, 'Completa tu primer Speedrun de Ducha válido');
      expect(badge.monedas, 10);
      expect(badge.desbloqueado, isTrue);
      expect(badge.reclamado, isFalse);
      expect(badge.desbloqueadoEn, '2026-10-26T20:00:00.000Z');
      expect(badge.emoji, '🚿');
      expect(badge.fechaFormateada.contains('26 de octubre de 2026'), isTrue);
    });

    testWidgets('CP-VITRINA-01: Usuario con 2 medallas ganadas y 3 pendientes ve exactamente 2 a color y 3 en escala de grises', (WidgetTester tester) async {
      final badges = AchievementItem.mockList; // Contiene exactamente 2 ganadas y 3 pendientes
      expect(badges.length, 5);
      expect(badges.where((b) => b.desbloqueado).length, 2);
      expect(badges.where((b) => !b.desbloqueado).length, 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: badges.map((b) => BadgeTile(badge: b, isDark: false)).toList(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Encontrar las celdas que contienen Opacity de 0.4 (escala de grises)
      final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
      final grayedOutTiles = opacities.where((w) => w.opacity == 0.4).toList();

      // Exactamente 3 en escala de grises al 40% de opacidad
      expect(grayedOutTiles.length, equals(3));

      // Exactamente 3 candados visibles para las bloqueadas
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(3));

      // Las 2 desbloqueadas muestran el título normal sin Opacity 0.4
      expect(find.text('Ducha Ninja'), findsOneWidget);
      expect(find.text('Maestro del Reciclaje'), findsOneWidget);
      expect(find.text('Cerebro Verde'), findsOneWidget);
      expect(find.text('Racha Legendaria'), findsOneWidget);
      expect(find.text('Guardián de Boletas'), findsOneWidget);
    });

    testWidgets('CA-4.2C.2-2: Tocar medalla desbloqueada abre modal con fecha y acción', (WidgetTester tester) async {
      const unlockedBadge = AchievementItem(
        id: '1',
        key: 'DUCHA_TEST',
        nombre: 'Ducha Ninja',
        descripcion: 'Dúchate en menos de 5 minutos',
        emoji: '🚿',
        monedas: 10,
        desbloqueado: true,
        reclamado: false,
        desbloqueadoEn: '2026-10-26T20:00:00.000Z',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeTile(badge: unlockedBadge, isDark: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tocar la medalla
      await tester.tap(find.byType(BadgeTile));
      await tester.pumpAndSettle();

      // Modal de desbloqueada
      expect(find.textContaining('¡Desbloqueaste este logro el 26 de octubre de 2026!'), findsOneWidget);
      expect(find.text('Reclamar 10 Monedas'), findsOneWidget);
      expect(find.text('Destacar en Feed y Perfil'), findsOneWidget);
    });

    testWidgets('CA-4.2C.2-2: Tocar medalla bloqueada abre modal con Requisitos Pendientes', (WidgetTester tester) async {
      const lockedBadge = AchievementItem(
        id: '2',
        key: 'CEREBRO_VERDE',
        nombre: 'Cerebro Verde',
        descripcion: 'Responde correctamente todas las preguntas',
        emoji: '🧠',
        monedas: 20,
        desbloqueado: false,
        reclamado: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BadgeTile(badge: lockedBadge, isDark: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tocar la medalla
      await tester.tap(find.byType(BadgeTile));
      await tester.pumpAndSettle();

      // Modal de bloqueada
      expect(find.text('Requisitos Pendientes'), findsOneWidget);
      expect(find.textContaining('10 trivias'), findsOneWidget);
      expect(find.text('Entendido, ¡voy a lograrlo!'), findsOneWidget);
    });

    testWidgets('CP-POPUP-01: Al recibir payload de nuevo logro, el pop-up se abre antes de retornar a la pantalla principal', (WidgetTester tester) async {
      const newBadge = AchievementItem(
        id: 'pop-1',
        key: 'NUEVA_DUCHA',
        nombre: 'Ducha Ninja',
        descripcion: 'Completaste 5 duchas de menos de 5 minutos',
        emoji: '🚿',
        xp: 100,
        monedas: 10,
        desbloqueado: true,
      );

      bool dialogShown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    // Simular llegada de payload de nuevo logro
                    await BadgeUnlockedDialog.show(context, badge: newBadge);
                    dialogShown = true;
                  },
                  child: const Text('Completar Reto'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Presionar para completar reto
      await tester.tap(find.text('Completar Reto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // El pop-up debe estar visible en pantalla con todos sus componentes requeridos
      expect(find.byType(BadgeUnlockedDialog), findsOneWidget);
      expect(find.text('¡NUEVO LOGRO DESBLOQUEADO!'), findsOneWidget);
      expect(find.text('Ducha Ninja'), findsOneWidget);
      expect(find.text('Completaste 5 duchas de menos de 5 minutos'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('+10 '), findsOneWidget);
      expect(find.text('¡GENIAL! 🏆'), findsOneWidget);

      // Aún no ha continuado el flujo posterior
      expect(dialogShown, isFalse);

      // Cerrar el pop-up
      await tester.tap(find.text('¡GENIAL! 🏆'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Ahora el diálogo se cerró y continúa el flujo hacia la pantalla principal
      expect(find.byType(BadgeUnlockedDialog), findsNothing);
      expect(dialogShown, isTrue);
    });

    testWidgets('CA-4.2C-3: Pantalla TrophyShowcaseScreen muestra vitrina con filtros y selector de insignia destacada', (WidgetTester tester) async {
      final user = const UserProfile(
        id: 'user-1',
        nombre: 'Benjamín',
        nivel: 3,
        monedas: 120,
        xp: 450,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TrophyShowcaseScreen(
            user: user,
            initialBadges: AchievementItem.mockList,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar elementos principales de la Vitrina
      expect(find.text('Vitrina de Trofeos'), findsOneWidget);
      expect(find.text('INSIGNIA DESTACADA'), findsOneWidget);
      expect(find.text('Desbloqueadas'), findsOneWidget);
      expect(find.text('Monedas de Logros'), findsOneWidget);
      expect(find.text('Nv. 3'), findsOneWidget);

      // Filtros
      expect(find.text('Todas (5)'), findsOneWidget);
      expect(find.text('Desbloqueadas (2)'), findsOneWidget);
      expect(find.text('Por Desbloquear (3)'), findsOneWidget);

      // Filtrar solo por desbloqueadas
      await tester.tap(find.text('Desbloqueadas (2)'));
      await tester.pumpAndSettle();

      // Ahora solo hay 2 medallas visibles en la grilla
      expect(find.byType(BadgeTile), findsNWidgets(2));
      expect(find.text('Ducha Ninja'), findsOneWidget);
      expect(find.text('Maestro del Reciclaje'), findsOneWidget);
      expect(find.text('Cerebro Verde'), findsNothing);
    });

    testWidgets('CA-4.2C.2-1 & HU 4.2C.2: ProfileBadgesCard es compacto, cerrado (sin GridView gigante en perfil) y navega a la Vitrina al pulsar el botón', (WidgetTester tester) async {
      final user = const UserProfile(
        id: 'user-compact-test',
        nombre: 'Benjamín',
        nivel: 5,
        monedas: 10,
        xp: 2080,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileBadgesCard(
                user: user,
                isDark: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar que es cerrado: NO tiene un GridView de medallas ocupando espacio en el perfil
      expect(find.byType(GridView), findsNothing);

      // Verificar elementos del diseño compacto inspirado en Canjes / Admin
      expect(find.text('Mis Medallas'), findsOneWidget);
      expect(find.text('Ver Vitrina'), findsOneWidget);
      expect(find.text('🏆'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Presionar el botón "Ver Vitrina" para entrar al panel completo de medallas
      await tester.tap(find.text('Ver Vitrina'));
      await tester.pumpAndSettle();

      // Verifica que abre TrophyShowcaseScreen exitosamente
      expect(find.byType(TrophyShowcaseScreen), findsOneWidget);
      expect(find.text('Vitrina de Trofeos'), findsOneWidget);
    });
  });
}
