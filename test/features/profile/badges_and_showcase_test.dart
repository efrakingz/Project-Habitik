import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/badge_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/achievement.dart';
import 'package:habitik/data/models/challenge.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/features/profile/widgets/badge_svg_icons.dart';
import 'package:habitik/features/profile/widgets/badge_tile.dart';
import 'package:habitik/features/profile/widgets/profile_badges_card.dart';
import 'package:habitik/features/profile/widgets/profile_identity_card.dart';
import 'package:habitik/features/profile/widgets/profile_invite_card.dart';
import 'package:habitik/features/profile/trophy_showcase_screen.dart';
import 'package:habitik/shared/widgets/cards/ranking_card.dart';
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

    testWidgets('ProfileIdentityCard: Módulo de usuario exhibe la medalla destacada junto al nombre y avatar', (WidgetTester tester) async {
      final userWithFeaturedBadge = const UserProfile(
        id: 'user-destacado',
        nombre: 'Benja',
        email: 'benja@habitik.com',
        rol: 'jefe',
        nivel: 6,
        monedas: 59,
        rachaDias: 1,
        xp: 2680,
        badgeDestacado: 'PRIMERA_DUCHA',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileIdentityCard(
                user: userWithFeaturedBadge,
                isDark: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar que el nombre y rol aparecen
      expect(find.text('Benja'), findsOneWidget);
      expect(find.text('benja@habitik.com'), findsOneWidget);
      expect(find.text('👑 Jefe'), findsOneWidget);

      // Verificar que la insignia destacada está presente únicamente junto al nombre del usuario
      expect(find.text('⭐'), findsWidgets);

      // Al pulsar sobre la insignia destacada (el logo), se abre el modal que muestra cuál es el logro
      await tester.tap(find.text('⭐'));
      await tester.pumpAndSettle();

      expect(find.text('Ducha Eficiente'), findsOneWidget);
      expect(find.text('INSIGNIA DESTACADA'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);
    });

    test('Normalización de títulos de medallas: RECICLADOR_PERFECTO y snake_case a nombres originales', () {
      expect(BadgeSvgIcons.getBadgeTitle('RECICLADOR_PERFECTO'), 'Reciclador Perfecto');
      expect(BadgeSvgIcons.getBadgeTitle('RECICLADOR_IMPECABLE'), 'Reciclador Impecable');
      expect(BadgeSvgIcons.getBadgeTitle('MAESTRO_ECO'), 'Maestro del Reciclaje');
      expect(BadgeSvgIcons.getBadgeTitle('EXPERTO_RECICLAJE'), 'Experto del Reciclaje');
      expect(BadgeSvgIcons.getBadgeTitle('PRIMERA_DUCHA'), 'Ducha Eficiente');
      expect(BadgeSvgIcons.getBadgeTitle('DUCHA_BRONCE'), 'Ducha de Bronce');
      expect(BadgeSvgIcons.getBadgeTitle('GUARDIAN_BOLETAS'), 'Guardián de Boletas');
      expect(BadgeSvgIcons.getBadgeTitle('CEREBRO_VERDE'), 'Cerebro Verde');
      expect(BadgeSvgIcons.getBadgeTitle('AHORRO_AGUA_SUPREMO'), 'Ahorro Agua Supremo');
      expect(BadgeSvgIcons.getBadgeTitle('♻️'), 'Reciclador Perfecto');
      expect(BadgeSvgIcons.getBadgeTitle('🚿'), 'Ducha Eficiente');
    });

    testWidgets('RankingCard: Miembros del Hogar exhibe la insignia destacada en avatar y fila', (WidgetTester tester) async {
      const memberWithBadge = FamilyMember(
        id: 'user-member-1',
        nombre: 'Benja',
        rol: 'jefe',
        nivel: 6,
        xp: 2680,
        badgeDestacado: 'RECICLADOR_PERFECTO',
        avatarLetra: 'B',
        avatarColor: '#2E7D32',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RankingCard(
              position: 1,
              member: memberWithBadge,
              maxXp: 3000,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar nombre del miembro, rol y nivel
      expect(find.text('Benja'), findsOneWidget);
      expect(find.text('👑 Jefe'), findsOneWidget);
      expect(find.text('Nivel 6'), findsOneWidget);

      // Verificar que el indicador de estrella está presente en el pill
      expect(find.text('⭐'), findsWidgets);

      // Al pulsar sobre la insignia destacada (pill), se abre el modal con el detalle del logro
      await tester.tap(find.text('⭐').first);
      await tester.pumpAndSettle();

      // Verificar que en el modal emergente se muestra el nombre real del logro
      expect(find.text('Reciclador Perfecto'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);
    });

    testWidgets('TrophyShowcaseScreen: En modo claro las cards superiores se muestran claras/blanquecinas y en modo oscuro verde bosque', (WidgetTester tester) async {
      const user = UserProfile(
        id: 'user-mode-test',
        nombre: 'Benjamín',
        nivel: 3,
        monedas: 120,
        xp: 450,
      );

      // 1. Modo claro: las cards superiores deben tener fondo claro/blanquecino
      isDarkModeNotifier.value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TrophyShowcaseScreen(
            user: user,
            initialBadges: AchievementItem.mockList,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightContainers = tester.widgetList<Container>(find.byType(Container));
      final hasLightCards = lightContainers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == const Color(0xFFF7FBF8);
        }
        return false;
      });
      expect(hasLightCards, isTrue);

      // 2. Modo oscuro: las cards superiores deben tener fondo verde bosque oscuro
      isDarkModeNotifier.value = true;
      await tester.pumpWidget(
        MaterialApp(
          home: TrophyShowcaseScreen(
            user: user,
            initialBadges: AchievementItem.mockList,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkContainers = tester.widgetList<Container>(find.byType(Container));
      final hasDarkCards = darkContainers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == const Color(0xFF10271D) || decoration.color == const Color(0xFF112A1E);
        }
        return false;
      });
      expect(hasDarkCards, isTrue);

      // Restaurar estado
      isDarkModeNotifier.value = false;
    });

    test('BadgeService.enrichMembers: Respeta estrictamente el backend como única fuente de verdad (sin inventar badges)', () async {
      final members = [
        const FamilyMember(
          id: 'mati-id',
          nombre: 'Mati',
          rol: 'miembro',
          xp: 730,
          nivel: 2,
          avatarLetra: 'M',
          avatarColor: '#2E7D32',
          badgeDestacado: null, // No tiene badge en BD
        ),
        const FamilyMember(
          id: 'benja-id',
          nombre: 'Benja',
          rol: 'jefe',
          xp: 2680,
          nivel: 6,
          avatarLetra: 'B',
          avatarColor: '#2E7D32',
          badgeDestacado: 'CONSTANCIA_3', // Trae su badge desde la BD
        ),
      ];

      final enriched = await BadgeService().enrichMembers(members);

      expect(enriched.length, 2);
      // Mati no tiene badge en la BD: debe permanecer null (no inventar badges por nivel o XP)
      expect(enriched[0].badgeDestacado, isNull);

      // Benja sí tiene badge en la BD: se mantiene intacto
      expect(enriched[1].badgeDestacado, 'CONSTANCIA_3');
    });

    testWidgets('RankingCard: Miembros secundarios (otros usuarios) exhiben su insignia destacada al lado del nombre', (WidgetTester tester) async {
      const otherMember = FamilyMember(
        id: 'other-user-99',
        nombre: 'Mati',
        rol: 'miembro',
        xp: 730,
        nivel: 2,
        avatarLetra: 'M',
        avatarColor: '#2E7D32',
        badgeDestacado: 'RECICLADOR_PERFECTO',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RankingCard(
              position: 2,
              member: otherMember,
              maxXp: 3000,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe mostrar el nombre Mati, su rol y nivel
      expect(find.text('Mati'), findsOneWidget);
      expect(find.text('👤 Miembro'), findsOneWidget);
      expect(find.text('Nivel 2'), findsOneWidget);

      // Debe exhibir el pill con la estrella junto a su nombre
      expect(find.text('⭐'), findsWidgets);

      // Al pulsar sobre su insignia, debe abrir el modal con el detalle
      await tester.tap(find.text('⭐').first);
      await tester.pumpAndSettle();

      expect(find.text('Reciclador Perfecto'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);
    });

    testWidgets('RankingCard: Miembro sin insignia destacada en BD NO exhibe ningún pill ni estrella ⭐', (WidgetTester tester) async {
      const memberWithoutBadge = FamilyMember(
        id: 'user-no-badge',
        nombre: 'Carlos',
        rol: 'miembro',
        xp: 540,
        nivel: 2,
        avatarLetra: 'C',
        avatarColor: '#E65100',
        badgeDestacado: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RankingCard(
              position: 3,
              member: memberWithoutBadge,
              maxXp: 3000,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Carlos'), findsOneWidget);
      expect(find.text('👤 Miembro'), findsOneWidget);
      expect(find.text('Nivel 2'), findsOneWidget);

      // NO debe tener ninguna estrella ni píldora de insignia
      expect(find.text('⭐'), findsNothing);
    });

    test('FamilyMember.fromJson: Extrae badge únicamente si está desbloqueado en la BD', () {
      // 1. Miembro con logro desbloqueado en la BD
      final memberWithUnlocked = FamilyMember.fromJson({
        'id': 'benja-1',
        'nombre': 'Benja',
        'rol': 'jefe',
        'xp': 2680,
        'nivel': 6,
        'logros': [
          {
            'codigo': 'PRIMERA_DUCHA',
            'titulo': 'Ducha Eficiente',
            'desbloqueado': true,
          }
        ]
      });
      expect(memberWithUnlocked.badgeDestacado, 'PRIMERA_DUCHA');

      // 2. Miembro con logros todos bloqueados en la BD
      final memberWithLocked = FamilyMember.fromJson({
        'id': 'carlos-1',
        'nombre': 'Carlos',
        'rol': 'miembro',
        'xp': 540,
        'nivel': 2,
        'logros': [
          {
            'codigo': 'PRIMERA_DUCHA',
            'titulo': 'Ducha Eficiente',
            'desbloqueado': false,
          }
        ]
      });
      expect(memberWithLocked.badgeDestacado, isNull);

      // 3. Miembro sin lista de logros ni badge en la BD
      final memberEmpty = FamilyMember.fromJson({
        'id': 'efra-1',
        'nombre': 'Efra',
        'rol': 'miembro',
        'xp': 100,
        'nivel': 1,
      });
      expect(memberEmpty.badgeDestacado, isNull);
    });

    test('Eco-Puzzle: Recompensas en ChallengeType alineadas exactamente con el backend (150 XP, 2 monedas)', () {
      final puzzleChallenge = ChallengeType.allChallenges.firstWhere((c) => c.id == 'puzzle');
      expect(puzzleChallenge.xp, 150);
      expect(puzzleChallenge.monedas, 2);
    });

    testWidgets('ProfileInviteCard: Es compacto para Jefe/Admin y dispara onInvite', (WidgetTester tester) async {
      bool inviteTriggered = false;
      final adminUser = UserProfile(
        id: 'admin-1',
        nombre: 'Benja',
        email: 'benja@habitik.com',
        rol: 'jefe',
        familyId: 'fam-1',
        familyName: 'Familia Demo',
        xp: 2830,
        nivel: 6,
        monedas: 61,
        rachaDias: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileInviteCard(
              user: adminUser,
              isDark: false,
              isGenerating: false,
              onInvite: () => inviteTriggered = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe mostrar el título conciso y botón Invitar
      expect(find.text('Invitar a mi Familia'), findsOneWidget);
      expect(find.text('Comparte código o enlace QR'), findsOneWidget);
      expect(find.text('Invitar'), findsOneWidget);
      expect(find.text('🎟️'), findsOneWidget);

      // Al pulsar sobre el botón o card, se dispara onInvite
      await tester.tap(find.text('Invitar'));
      await tester.pumpAndSettle();
      expect(inviteTriggered, isTrue);
    });

    testWidgets('ProfileInviteCard: No se muestra si el usuario no es Jefe/Admin', (WidgetTester tester) async {
      final memberUser = UserProfile(
        id: 'member-1',
        nombre: 'Mati',
        email: 'mati@habitik.com',
        rol: 'miembro',
        familyId: 'fam-1',
        familyName: 'Familia Demo',
        xp: 730,
        nivel: 2,
        monedas: 10,
        rachaDias: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileInviteCard(
              user: memberUser,
              isDark: false,
              isGenerating: false,
              onInvite: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invitar a mi Familia'), findsNothing);
      expect(find.text('Invitar'), findsNothing);
    });
  });
}



