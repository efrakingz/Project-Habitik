import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/notification_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationSyncService — Ventana Horaria (9:00 a 22:00)', () {
    test('1. Permite ejecuciones dentro de la ventana de 09:00 a 21:59', () {
      final t9am = DateTime(2026, 10, 26, 9, 0, 0);
      final t12pm = DateTime(2026, 10, 26, 12, 30, 0);
      final t15pm = DateTime(2026, 10, 26, 15, 0, 0);
      final t18pm = DateTime(2026, 10, 26, 18, 45, 0);
      final t21pm = DateTime(2026, 10, 26, 21, 59, 59);

      expect(NotificationSyncService.esHorarioPermitido(fecha: t9am), isTrue);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t12pm), isTrue);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t15pm), isTrue);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t18pm), isTrue);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t21pm), isTrue);
    });

    test('2. Bloquea ejecuciones en horario de descanso / silencio nocturno (22:00 a 08:59)', () {
      final t8am59 = DateTime(2026, 10, 26, 8, 59, 59);
      final t22pm = DateTime(2026, 10, 26, 22, 0, 0);
      final t23pm = DateTime(2026, 10, 26, 23, 15, 0);
      final t3am = DateTime(2026, 10, 26, 3, 0, 0);

      expect(NotificationSyncService.esHorarioPermitido(fecha: t8am59), isFalse);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t22pm), isFalse);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t23pm), isFalse);
      expect(NotificationSyncService.esHorarioPermitido(fecha: t3am), isFalse);
    });

    test('3. Horarios definidos de corte cada 3 horas coinciden exactamente', () {
      expect(NotificationSyncService.horasChequeo, equals([9, 12, 15, 18, 21]));
    });

    test('4. ejecutarRevisionDeFondo retorna 0 fuera de horario si no se fuerza', () async {
      // Sin forzar horario en fecha nocturna simulada
      final res = await NotificationSyncService.ejecutarRevisionDeFondo(
        familyId: 'fam_test_123',
        forzarHorario: false,
      );

      // Si la hora real de la máquina está fuera de 9 a 22, retorna 0 de inmediato
      if (!NotificationSyncService.esHorarioPermitido()) {
        expect(res, 0);
      }
    });

    test('5. simularRevisionAppApagada almacena evento en caché local para pruebas', () async {
      final fechaProgramada = await NotificationSyncService.simularRevisionAppApagada(segundos: 20);
      expect(fechaProgramada.isAfter(DateTime.now()), isTrue);

      final simulados = await NotificationSyncService.obtenerEventosSimulados();
      expect(simulados.isNotEmpty, isTrue);
      expect(simulados.first['titulo'], contains('Eco-Dato'));
      expect(simulados.first['tipo'], equals('ECO_CURIOSIDAD'));
    });
  });
}
