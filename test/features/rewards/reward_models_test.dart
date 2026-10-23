import 'package:flutter_test/flutter_test.dart';
import 'package:habitik/data/models/reward_proposal.dart';
import 'package:habitik/data/models/reward.dart';

void main() {
  group('RewardProposal Model Tests', () {
    test('Parsea correctamente cuando el backend retorna "emoji"', () {
      final json = {
        'id': 1,
        'family_id': 'fam-123',
        'titulo': 'Noche de Películas',
        'descripcion': 'Ver una peli juntos en el sillón',
        'emoji': '🍿',
        'es_familiar': true,
        'created_at': '2026-10-22T20:00:00Z',
        'fecha_propuesta': '2026-10-22',
        'usuario_id': 'user-1',
        'usuario_nombre': 'Benjamín',
        'usuario_monedas': 50,
      };

      final proposal = RewardProposal.fromJson(json);

      expect(proposal.id, 1);
      expect(proposal.titulo, 'Noche de Películas');
      expect(proposal.emoji, '🍿');
      expect(proposal.esFamiliar, true);
      expect(proposal.usuarioNombre, 'Benjamín');
    });

    test('Parsea correctamente cuando el backend retorna "icono" (retrocompatibilidad)', () {
      final json = {
        'id': 2,
        'family_id': 'fam-123',
        'titulo': 'Paseo al Parque',
        'descripcion': 'Ir al parque a jugar',
        'icono': '🌳',
        'es_familiar': false,
        'created_at': '2026-10-22T20:00:00Z',
        'fecha_propuesta': '2026-10-22',
        'usuario_id': 'user-2',
        'usuario_nombre': 'Lucas',
        'usuario_monedas': 30,
      };

      final proposal = RewardProposal.fromJson(json);

      expect(proposal.id, 2);
      expect(proposal.titulo, 'Paseo al Parque');
      expect(proposal.emoji, '🌳');
      expect(proposal.esFamiliar, false);
    });

    test('Usa fallback predeterminado cuando ni emoji ni icono están presentes', () {
      final json = {
        'id': 3,
        'family_id': 'fam-123',
        'titulo': 'Premio sorpresa',
        'descripcion': 'Sin icono definido',
        'created_at': '2026-10-22T20:00:00Z',
        'fecha_propuesta': '2026-10-22',
        'usuario_id': 'user-3',
      };

      final proposal = RewardProposal.fromJson(json);

      expect(proposal.emoji, '🎁');
    });
  });

  group('RewardItem Model Tests', () {
    test('Parsea tanto "emoji" como "icono"', () {
      final withEmoji = RewardItem.fromJson({
        'id': 10,
        'titulo': 'Helado familiar',
        'costo': 25,
        'descripcion': 'Comer helado',
        'emoji': '🍦',
      });
      expect(withEmoji.emoji, '🍦');

      final withIcono = RewardItem.fromJson({
        'id': 11,
        'titulo': 'Salida al cine',
        'costo': 40,
        'descripcion': 'Entradas de cine',
        'icono': '🎬',
      });
      expect(withIcono.emoji, '🎬');

      final withFallback = RewardItem.fromJson({
        'id': 12,
        'titulo': 'Premio neutro',
        'costo': 10,
        'descripcion': '',
      });
      expect(withFallback.emoji, '🎁');
    });
  });
}
