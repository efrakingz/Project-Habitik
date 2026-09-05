import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio de audio global para gestionar la música y efectos de sonido.
/// Modificado temporalmente para reproducir clics nativos y omitir canciones/efectos de error.
class AudioService {
  static bool muted = false;
  static double bgmVolume = 0.8;
  static double sfxVolume = 0.8;

  /// Reproduce música de fondo en bucle (BGM) - Deshabilitado por limpieza de audios
  static Future<void> playBGM(String filename) async {
    // Deshabilitado por limpieza de audios
  }

  /// Detiene la música de fondo - Deshabilitado por limpieza de audios
  static Future<void> stopBGM() async {
    // Deshabilitado por limpieza de audios
  }

  /// Establece el volumen de la música de fondo en tiempo real
  static Future<void> setBGMVolume(double volume) async {
    bgmVolume = volume.clamp(0.0, 1.0);
  }

  /// Establece el volumen de los efectos de sonido
  static void setSFXVolume(double volume) {
    sfxVolume = volume.clamp(0.0, 1.0);
  }

  /// Reproduce un efecto de sonido corto (SFX). Solo reproduce clics del sistema nativo.
  static Future<void> playSFX(String filename) async {
    if (muted) return;
    if (filename == 'click.mp3') {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (e) {
        debugPrint("AudioService [SystemSound Error]: $e");
      }
      return;
    }
    // Deshabilitado para otros sonidos
  }
}
