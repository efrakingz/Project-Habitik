import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_service.dart';
import 'audio_service.dart';
import '../../shared/widgets/modals/level_up_modal.dart';

/// Servicio para calcular, auditar y desplegar la subida de niveles y recompensas acumuladas
class LevelService {
  static const int monedasPorNivel = 10;

  /// Obtiene el título o rango ecológico asignado a cada rango de nivel
  static String obtenerTituloRango(int nivel) {
    if (nivel <= 2) return 'Semilla Verde 🌱';
    if (nivel <= 5) return 'Brote Ecológico 🌿';
    if (nivel <= 9) return 'Guardián del Agua 💧';
    if (nivel <= 14) return 'Defensor Solar ☀️';
    if (nivel <= 19) return 'Protector del Bosque 🌲';
    if (nivel <= 29) return 'Eco Guerrero 🛡️';
    if (nivel <= 49) return 'Maestro Sustentable ⚡';
    if (nivel <= 74) return 'Héroe Planetario 🌍';
    return 'Leyenda de Gaia 👑';
  }

  /// Consulta el último nivel reclamado por el usuario en SharedPreferences
  static Future<int?> getUltimoNivelReclamado(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('ultimo_nivel_reclamado_$userId');
  }

  /// Guarda el nivel reclamado para no volver a premiarlo repetidamente
  static Future<void> setUltimoNivelReclamado(String userId, int nivel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ultimo_nivel_reclamado_$userId', nivel);
  }

  /// Calcula la recompensa acumulada de monedas según la cantidad de niveles subidos
  static int calcularRecompensaMonedas(int nivelesSubidos) {
    if (nivelesSubidos <= 0) return 0;
    return nivelesSubidos * monedasPorNivel;
  }

  /// Evalúa si el usuario actual tiene niveles pendientes por reclamar y muestra el modal
  static Future<bool> checkAndShowLevelUp(
    BuildContext context, {
    int? nivelForzado,
  }) async {
    final session = SessionService();
    final user = session.currentUser;
    if (user == null) return false;

    final nivelActual = nivelForzado ?? user.nivel;
    final ultimoReclamadoRaw = await getUltimoNivelReclamado(user.id);

    // Si es la primera vez que se consulta:
    // Si ya está en nivel > 1 y nunca reclamó, reclamará desde el nivel 1
    // Si está en nivel 1, se inicializa en 1 y no muestra modal inicial
    int ultimoReclamado;
    if (ultimoReclamadoRaw == null) {
      if (nivelActual > 1) {
        ultimoReclamado = 1;
      } else {
        await setUltimoNivelReclamado(user.id, 1);
        return false;
      }
    } else {
      ultimoReclamado = ultimoReclamadoRaw;
    }

    if (nivelActual > ultimoReclamado) {
      final nivelesSubidos = nivelActual - ultimoReclamado;
      final monedasTotales = calcularRecompensaMonedas(nivelesSubidos);
      final titulo = obtenerTituloRango(nivelActual);

      if (!context.mounted) return false;

      // Reproducir sonido de celebración
      AudioService.playSFX('click.mp3');

      final reclamado = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withAlpha(180),
        builder: (ctx) => LevelUpModal(
          nivelAnterior: ultimoReclamado,
          nivelNuevo: nivelActual,
          nivelesSubidos: nivelesSubidos,
          monedasAcumuladas: monedasTotales,
          tituloRango: titulo,
        ),
      );

      if (reclamado == true) {
        // Persistir el nuevo nivel reclamado
        await setUltimoNivelReclamado(user.id, nivelActual);

        // Acreditar las monedas acumuladas al perfil en sesión
        final saldoActual = session.currentUser?.monedas ?? user.monedas;
        await session.updateRewardsAndXp(
          monedas: saldoActual + monedasTotales,
          nivel: nivelActual,
        );
        return true;
      }
    }

    return false;
  }
}
