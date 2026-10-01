import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/data/models/family_energy_model.dart';
import 'package:habitik/data/models/family_feed_item.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/features/home/services/family_wall_service.dart';
import 'package:habitik/features/home/widgets/family_energy_card.dart';
import 'package:habitik/features/home/widgets/family_ranking_section.dart';
import 'package:habitik/features/home/widgets/family_feed_card.dart';

void main() {
  group('HU 4.1 – Modelos del Muro Social Familiar', () {
    test('FamilyEnergyModel calcula porcentaje y factor de forma correcta', () {
      const model = FamilyEnergyModel(
        totalXpMes: 2500,
        metaMensualXp: 5000,
      );

      expect(model.porcentaje, equals(50.0));
      expect(model.progresoFactor, equals(0.5));
      expect(model.xpRestante, equals(2500));
      expect(model.metaAlcanzada, isFalse);

      const completedModel = FamilyEnergyModel(
        totalXpMes: 6000,
        metaMensualXp: 5000,
      );
      expect(completedModel.porcentaje, equals(100.0));
      expect(completedModel.progresoFactor, equals(1.0));
      expect(completedModel.xpRestante, equals(0));
      expect(completedModel.metaAlcanzada, isTrue);
    });

    test('FamilyFeedItem gestiona reacciones y copyWith', () {
      final item = FamilyFeedItem(
        id: 'feed_test',
        usuarioId: 'u_1',
        nombreUsuario: 'Sofía',
        avatarLetra: 'S',
        avatarColor: '#E91E63',
        tipoReto: 'trivia',
        tituloReto: 'Trivia Ecológica',
        descripcion: 'Completó 8 preguntas consecutivas',
        xpGanada: 60,
        monedasGanadas: 1,
        fecha: DateTime.now().subtract(const Duration(minutes: 5)),
        reacciones: const {'👏': 2, '🔥': 3, '💧': 0, '❤️': 1},
      );

      expect(item.reacciones['🔥'], equals(3));
      expect(item.tiempoRelativo, contains('Hace'));

      final updated = item.copyWith(
        reacciones: {'👏': 3, '🔥': 3, '💧': 0, '❤️': 1},
        misReacciones: {'👏'},
      );

      expect(updated.reacciones['👏'], equals(3));
      expect(updated.misReacciones.contains('👏'), isTrue);
    });
  });

  group('HU 4.1 – Widgets del Muro Familiar', () {
    testWidgets('FamilyEnergyCard muestra porcentaje, XP y meta mensual (CA-4.1-1)', (
      tester,
    ) async {
      const energy = FamilyEnergyModel(
        totalXpMes: 3500,
        metaMensualXp: 5000,
        periodo: 'Octubre',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FamilyEnergyCard(energy: energy),
          ),
        ),
      );

      // Esperar la animación del TweenAnimationBuilder
      await tester.pumpAndSettle();

      expect(find.text('Energía Colectiva'), findsOneWidget);
      expect(find.text('70.0%'), findsOneWidget);
      expect(find.text('3500 XP acumulados'), findsOneWidget);
      expect(find.text('Meta: 5000 XP'), findsOneWidget);
      expect(find.textContaining('Faltan 1500 XP'), findsOneWidget);
    });

    testWidgets('FamilyRankingSection ordena por semanal/mensual y muestra rachas (CA-4.1-2)', (
      tester,
    ) async {
      final members = [
        const FamilyMember(
          id: '1',
          nombre: 'Hijo',
          rol: 'miembro',
          xp: 800,
          xpSemanal: 500, // Top semanal
          nivel: 3,
          rachaDias: 8,
          avatarLetra: 'H',
          avatarColor: '#1976D2',
        ),
        const FamilyMember(
          id: '2',
          nombre: 'Mamá',
          rol: 'jefe',
          xp: 2000, // Top mensual
          xpSemanal: 300,
          nivel: 5,
          rachaDias: 14,
          avatarLetra: 'M',
          avatarColor: '#9C27B0',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FamilyRankingSection(members: members),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Por defecto arranca en Semanal -> Hijo debe tener 500 XP
      expect(find.text('Ranking Familiar'), findsOneWidget);
      expect(find.text('Semanal'), findsOneWidget);
      expect(find.text('Mensual'), findsOneWidget);
      expect(find.text('500 XP'), findsOneWidget);
      expect(find.textContaining('8 d'), findsOneWidget); // Racha Hijo
      expect(find.textContaining('14 d'), findsOneWidget); // Racha Mamá

      // Cambiar a filtro Mensual
      await tester.tap(find.text('Mensual'));
      await tester.pumpAndSettle();

      // En mensual, Mamá tiene 2000 XP
      expect(find.text('2000 XP'), findsOneWidget);
    });

    testWidgets('FamilyFeedCard muestra reto y permite reaccionar (CA-4.1-3)', (
      tester,
    ) async {
      String? clickedEmoji;

      final item = FamilyFeedItem(
        id: 'f1',
        usuarioId: 'u1',
        nombreUsuario: 'Carlos',
        rolUsuario: 'Hermano',
        avatarLetra: 'C',
        avatarColor: '#4CAF50',
        tipoReto: 'ducha',
        tituloReto: 'Ducha Speedrun',
        descripcion: 'Ahorró 40 litros de agua en la ducha',
        xpGanada: 100,
        monedasGanadas: 2,
        fecha: DateTime.now().subtract(const Duration(minutes: 10)),
        reacciones: const {'👏': 1, '🔥': 4, '💧': 2, '❤️': 0},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FamilyFeedCard(
              item: item,
              onReactionTap: (emoji) => clickedEmoji = emoji,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Carlos'), findsOneWidget);
      expect(find.text('Ducha Speedrun'), findsOneWidget);
      expect(find.text('4'), findsOneWidget); // 4 de fuego

      // Tocar reacción de aplauso 👏
      await tester.tap(find.text('👏'));
      await tester.pumpAndSettle();

      expect(clickedEmoji, equals('👏'));
    });

    test('FamilyWallService toggleReaction actualiza el contador de inmediato', () async {
      final service = FamilyWallService();
      await service.loadWallData(notify: false);

      expect(service.feed.isNotEmpty, isTrue);
      final firstId = service.feed.first.id;
      final initialFire = service.feed.first.reacciones['🔥'] ?? 0;
      final initiallyReacted = service.feed.first.misReacciones.contains('🔥');

      service.toggleReaction(firstId, '🔥');

      final updated = service.feed.firstWhere((it) => it.id == firstId);
      if (initiallyReacted) {
        expect(updated.reacciones['🔥'], equals(initialFire - 1));
        expect(updated.misReacciones.contains('🔥'), isFalse);
      } else {
        expect(updated.reacciones['🔥'], equals(initialFire + 1));
        expect(updated.misReacciones.contains('🔥'), isTrue);
      }
    });
  });
}
