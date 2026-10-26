import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_service.dart';
import 'notification_service.dart';

/// Servicio responsable de la sincronización periódica de notificaciones en segundo plano,
/// validación de ventanas horarias permitidas (9:00 AM - 10:00 PM) y simulación de alertas.
class NotificationSyncService {
  static const String keyUltimoEventoId = 'notif_sync_ultimo_evento_id';
  static const String keyUltimoCheckTimestamp = 'notif_sync_ultimo_check_ts';
  static const String keyEventosSimulados = 'notif_sync_eventos_simulados';

  /// Horarios definidos de chequeo cada 3 horas entre 09:00 y 22:00
  static const List<int> horasChequeo = [9, 12, 15, 18, 21];

  /// Valida si la hora especificada (o la actual) se encuentra dentro de la ventana
  /// permitida: de 9:00 AM a 10:00 PM (09:00 a 21:59:59).
  static bool esHorarioPermitido({DateTime? fecha}) {
    final hora = (fecha ?? DateTime.now()).hour;
    return hora >= 9 && hora < 22;
  }

  /// Ejecuta la revisión periódica de notificaciones familiares contra el backend.
  /// Si está fuera de horario (22:00 - 08:59), descarta la revisión a menos que se fuerce.
  /// Retorna la cantidad de nuevas alertas notificadas.
  static Future<int> ejecutarRevisionDeFondo({
    String? familyId,
    bool forzarHorario = false,
  }) async {
    final now = DateTime.now();
    if (!forzarHorario && !esHorarioPermitido(fecha: now)) {
      debugPrint(
        '🌙 [NotificationSyncService] Fuera de ventana activa (09:00 a 22:00). Hora actual: ${now.hour}:00. Chequeo omitido.',
      );
      return 0;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final String? targetFamilyId =
          familyId ?? prefs.getString('bg_family_id');

      if (targetFamilyId == null || targetFamilyId.isEmpty) {
        debugPrint(
          'ℹ️ [NotificationSyncService] Sin familia vinculada para revisión de fondo.',
        );
        return 0;
      }

      await prefs.setInt(keyUltimoCheckTimestamp, now.millisecondsSinceEpoch);

      // 1. Obtener eventos remotos del historial familiar
      final List<Map<String, dynamic>> remotos =
          await HistoryService.cargarYSincronizar(targetFamilyId);

      if (remotos.isEmpty) {
        return 0;
      }

      final String? ultimoIdVisto = prefs.getString(keyUltimoEventoId);

      // 2. Si no había ID previo registrado, marcar el más reciente como base para no saturar al usuario
      if (ultimoIdVisto == null || ultimoIdVisto.isEmpty) {
        final primerId = remotos.first['id']?.toString() ??
            remotos.first['_id']?.toString() ??
            '';
        if (primerId.isNotEmpty) {
          await prefs.setString(keyUltimoEventoId, primerId);
        }
        return 0;
      }

      // 3. Filtrar eventos nuevos no procesados
      final List<Map<String, dynamic>> nuevos = [];
      for (final ev in remotos) {
        final evId = ev['id']?.toString() ?? ev['_id']?.toString() ?? '';
        if (evId == ultimoIdVisto) {
          break; // Llegamos a los eventos ya conocidos
        }
        nuevos.add(ev);
      }

      if (nuevos.isEmpty) {
        debugPrint('✅ [NotificationSyncService] Sin nuevas notificaciones en el chequeo.');
        return 0;
      }

      debugPrint(
        '🔔 [NotificationSyncService] ${nuevos.length} nueva(s) notificación(es) encontrada(s) en revisión de fondo.',
      );

      // 4. Mostrar notificaciones nativas de los nuevos eventos
      int notificadas = 0;
      for (final ev in nuevos.reversed) {
        final String titulo = ev['titulo']?.toString() ??
            ev['title']?.toString() ??
            'Alerta Familiar';
        final String cuerpo = ev['mensaje']?.toString() ??
            ev['desc_text']?.toString() ??
            'Nueva notificación';
        final dynamic tipo = ev['tipo'] ?? ev['type'] ?? 'GENERAL';
        final String evId = ev['id']?.toString() ?? ev['_id']?.toString() ?? '';

        await NotificationService.mostrarNotificacionSistema(
          id: evId.hashCode.abs() % 100000,
          titulo: titulo,
          cuerpo: cuerpo,
          tipo: tipo,
          deduplicationKey: 'sync_${evId}_$titulo',
          payload: jsonEncode(ev),
        );
        notificadas++;
      }

      // 5. Actualizar el puntero del último evento visto
      final nuevoUltimoId = nuevos.first['id']?.toString() ??
          nuevos.first['_id']?.toString() ??
          ultimoIdVisto;
      await prefs.setString(keyUltimoEventoId, nuevoUltimoId);

      return notificadas;
    } catch (e) {
      debugPrint('⚠️ [NotificationSyncService] Error en revisión de fondo: $e');
      return 0;
    }
  }

  /// Programa las alertas fijas del día para los 5 cortes de horario (09:00, 12:00, 15:00, 18:00, 21:00)
  /// utilizando el reloj nativo del sistema (AlarmManager)
  static Future<void> programarRecordatoriosDiarios() async {
    final now = DateTime.now();
    for (final hora in horasChequeo) {
      DateTime target = DateTime(now.year, now.month, now.day, hora, 0);
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }

      final id = 7000 + hora;
      String titulo = '🌿 Habitik';
      String cuerpo = 'Revisando hábitos y alertas del hogar...';
      dynamic tipo = HabitikNotificationType.general;

      if (hora == 9) {
        titulo = 'Eco-Tip de la Mañana';
        cuerpo = '¡Comienza el día con energía eficiente en casa!';
        tipo = HabitikNotificationType.tipOnboarding;
      } else if (hora == 12) {
        titulo = 'Meta del Mediodía';
        cuerpo = 'Recuerda revisar tus retos diarios de ahorro.';
        tipo = HabitikNotificationType.recordatorioHabito;
      } else if (hora == 15) {
        titulo = 'Eco-Curiosidad Habitik';
        cuerpo = '¿Sabías que apagar las luces que no usas reduce hasta un 15% de consumo?';
        tipo = HabitikNotificationType.ecoCuriosidad;
      } else if (hora == 18) {
        titulo = 'Retos Familiares';
        cuerpo = '¡Buen momento para registrar evidencias y sumar puntos!';
        tipo = HabitikNotificationType.retoCompletado;
      } else if (hora == 21) {
        titulo = 'Alerta de Racha Diaria';
        cuerpo = '¡No pierdas tu racha familiar antes de que termine el día!';
        tipo = HabitikNotificationType.alertaRacha;
      }

      await NotificationService.programarNotificacionLocal(
        id: id,
        titulo: titulo,
        cuerpo: cuerpo,
        fechaHora: target,
        tipo: tipo,
        payload: jsonEncode({
          'tipo': tipo.toString(),
          'titulo': titulo,
          'mensaje': cuerpo,
          'hora_programada': hora,
        }),
      );
    }
    debugPrint('⏰ [NotificationSyncService] Recordatorios programados para: ${horasChequeo.map((h) => '$h:00').join(', ')}');
  }

  /// Función de prueba acelerada para simular el comportamiento con la app apagada.
  /// Programa una notificación nativa para dentro de [segundos] segundos.
  /// Esto permite al desarrollador pulsar el botón, cerrar la app completamente y
  /// verificar que la notificación se dispara y abre la aplicación con el evento listo.
  static Future<DateTime> simularRevisionAppApagada({int segundos = 15}) async {
    final targetTime = DateTime.now().add(Duration(seconds: segundos));
    const testId = 9991;

    final eventoSimulado = {
      'id': 'sim_${DateTime.now().millisecondsSinceEpoch}',
      'titulo': '💡 ¿Sabías que? Eco-Dato Habitik',
      'mensaje':
          '💡 ¿Sabías que? Desconectar electrodomésticos en modo espera (standby) ahorra hasta un 10% en tu cuenta eléctrica.',
      'tipo': 'ECO_CURIOSIDAD',
      'usuario_nombre': 'Habitik AI',
      'creado_en': targetTime.toIso8601String(),
    };

    // Guardar en la caché local para que aparezca en la lista al abrir la app
    try {
      final prefs = await SharedPreferences.getInstance();
      final simuladosJson = prefs.getString(keyEventosSimulados) ?? '[]';
      final List simulados = jsonDecode(simuladosJson);
      simulados.insert(0, eventoSimulado);
      await prefs.setString(keyEventosSimulados, jsonEncode(simulados));
    } catch (_) {}

    // Programar la notificación nativa en el reloj de Android
    try {
      await NotificationService.programarNotificacionLocal(
        id: testId,
        titulo: '¿Sabías que? Eco-Dato Habitik',
        cuerpo:
            '💡 ¿Sabías que? Desconectar electrodomésticos en modo espera (standby) ahorra hasta un 10% en tu cuenta eléctrica.',
        fechaHora: targetTime,
        tipo: HabitikNotificationType.ecoCuriosidad,
        payload: jsonEncode(eventoSimulado),
      );
    } catch (e) {
      debugPrint('ℹ️ [NotificationSyncService] Programación local omitida (entorno de pruebas/sin plugin nativo): $e');
    }

    debugPrint(
      '🧪 [NotificationSyncService] Simulación programada para $targetTime ($segundos segundos). Cierra la app ahora para probar.',
    );

    return targetTime;
  }

  /// Recupera los eventos simulados guardados localmente para pruebas
  static Future<List<Map<String, dynamic>>> obtenerEventosSimulados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final simuladosJson = prefs.getString(keyEventosSimulados);
      if (simuladosJson != null && simuladosJson.isNotEmpty) {
        final List list = jsonDecode(simuladosJson);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
