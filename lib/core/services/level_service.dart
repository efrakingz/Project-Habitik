import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para calcular y auditar rangos de nivel.
/// Recompensas acumuladas de nivel desactivadas por requerimiento de producto.
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

  /// Modal y entrega de monedas desactivados temporalmente por solicitud de producto.
  static Future<bool> checkAndShowLevelUp(
    BuildContext context, {
    int? nivelForzado,
  }) async {
    return false;
  }
}
