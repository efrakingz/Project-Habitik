import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/data/models/challenge.dart';
import 'package:habitik/data/models/inspeccion_evidencia.dart';
import 'package:habitik/features/challenges/games/cazador_sombras/cazador_sombras_screen.dart';

void main() {
  group('HU 2.2 — Modelos de Inspección Fotográfica (Cazador de Sombras)', () {
    test('InspeccionEvidencia.fromJson parsea el contrato del backend de subida de evidencia', () {
      final json = {
        'id': 'e5b871f3-1234-5678-90ab-cdef12345678',
        'family_id': 'fam-uuid-123',
        'user_id': 'usr-uuid-456',
        'titulo_mision': 'Inspección de luces apagadas',
        'foto_url': 'https://backend.railway.app/uploads/inspecciones/foto.jpg',
        'estado': 'pendiente',
      };

      final item = InspeccionEvidencia.fromJson(json);

      expect(item.id, 'e5b871f3-1234-5678-90ab-cdef12345678');
      expect(item.familyId, 'fam-uuid-123');
      expect(item.userId, 'usr-uuid-456');
      expect(item.tituloMision, 'Inspección de luces apagadas');
      expect(item.fotoUrl, 'https://backend.railway.app/uploads/inspecciones/foto.jpg');
      expect(item.estado, 'pendiente');
    });

    test('InspeccionEvidencia.fromJson parsea evidencias pendientes del panel del jefe', () {
      final json = {
        'id': 'e5b871f3-1234-5678-90ab-cdef12345678',
        'titulo_mision': 'Inspección de luces apagadas',
        'foto_url': 'https://backend.railway.app/uploads/inspecciones/foto.jpg',
        'created_at': '2026-10-28T09:30:00.000Z',
        'user_id': 'profile-uuid-123',
        'usuario_nombre': 'Camila',
        'usuario_avatar': 'avatar_2.png',
      };

      final item = InspeccionEvidencia.fromJson(json);

      expect(item.usuarioNombre, 'Camila');
      expect(item.usuarioAvatar, 'avatar_2.png');
      expect(item.createdAt, isNotNull);
      expect(item.createdAt!.year, 2026);
    });

    test('AprobarEvidenciaResult.fromJson extrae las recompensas oficiales (+80 XP y +4 Monedas)', () {
      final json = {
        'ok': true,
        'data': {
          'exito': true,
          'mensaje': 'Evidencia aprobada con éxito.',
          'recompensas': {
            'xp_ganada': 80,
            'monedas_ganadas': 4,
            'nuevo_saldo_monedas': 28,
            'total_xp': 480,
          },
        },
      };

      final result = AprobarEvidenciaResult.fromJson(json);

      expect(result.exito, isTrue);
      expect(result.xpGanada, 80);
      expect(result.monedasGanadas, 4);
      expect(result.nuevoSaldoMonedas, 28);
      expect(result.totalXp, 480);
    });

    test('ChallengeType inspeccion está disponible y configurado con +80 XP y +4 monedas', () {
      final inspeccion = ChallengeType.allChallenges.firstWhere((c) => c.id == 'inspeccion');

      expect(inspeccion.isAvailable, isTrue);
      expect(inspeccion.xp, 80);
      expect(inspeccion.monedas, 4);
      expect(inspeccion.displayTitle, 'Cazador Sombras');
    });
  });

  group('HU 2.2 — CazadorSombrasScreen Widgets y CA-2.2-1', () {
    testWidgets('CA-2.2-1: El botón "Enviar Evidencia" está deshabilitado mientras no haya foto', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CazadorSombrasScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verificar que el título y descripción se muestran
      expect(find.text('Cazador de Sombras'), findsOneWidget);
      expect(find.text('+80 XP'), findsOneWidget);
      expect(find.text('+4 🪙'), findsOneWidget);

      // Verificar que los botones de captura existen
      expect(find.byKey(const Key('btn_tomar_foto_camara')), findsOneWidget);
      expect(find.byKey(const Key('btn_seleccionar_galeria')), findsOneWidget);

      // Verificar el botón Enviar Evidencia
      final enviarBtnFinder = find.byKey(const Key('btn_enviar_evidencia'));
      expect(enviarBtnFinder, findsOneWidget);

      // El ElevatedButton debe estar deshabilitado (onPressed == null)
      final ElevatedButton btnWidget = tester.widget(enviarBtnFinder);
      expect(btnWidget.onPressed, isNull);

      // El contenedor contenedor del botón debe tener Opacity 0.5 según CA-2.2-1
      final Opacity opacityWidget = tester.widget(
        find.ancestor(of: enviarBtnFinder, matching: find.byType(Opacity)).first,
      );
      expect(opacityWidget.opacity, 0.5);
    });
  });
}
