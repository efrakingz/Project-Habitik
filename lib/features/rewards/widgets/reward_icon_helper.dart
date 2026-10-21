import 'package:flutter/material.dart';

/// Mapea de manera limpia títulos, categorías y emojis a iconos minimalistas Outline
/// respetando la identidad sustentable de Habitik y evitando el aspecto genérico de IA.
IconData getRewardCategoryIcon(String emoji, String title) {
  final t = title.toLowerCase();
  final e = emoji.trim();

  if (t.contains('botánico') ||
      t.contains('jardín') ||
      t.contains('jardin') ||
      t.contains('planta') ||
      t.contains('huerto') ||
      t.contains('árbol') ||
      t.contains('arbol') ||
      e == '🌿' ||
      e == '🌱' ||
      e == '🪴' ||
      e == '🌸') {
    return Icons.local_florist_outlined;
  }

  if (t.contains('cine') ||
      t.contains('película') ||
      t.contains('pelicula') ||
      t.contains('función') ||
      t.contains('funcion') ||
      t.contains('documental') ||
      t.contains('pantalla') ||
      e == '🎬' ||
      e == '🎥' ||
      e == '🍿' ||
      e == '📺') {
    return Icons.smart_display_outlined;
  }

  if (t.contains('pizza') ||
      t.contains('comida') ||
      t.contains('almuerzo') ||
      t.contains('cena') ||
      t.contains('desayuno') ||
      t.contains('receta') ||
      t.contains('orgánico') ||
      t.contains('organico') ||
      t.contains('artesanal') ||
      e == '🍕' ||
      e == '🍔' ||
      e == '🍜' ||
      e == '🥗' ||
      e == '🍦' ||
      e == '🧁') {
    return Icons.restaurant_outlined;
  }

  if (t.contains('bici') ||
      t.contains('bicicleta') ||
      t.contains('ciclo') ||
      t.contains('paseo') ||
      e == '🚴' ||
      e == '🚲') {
    return Icons.directions_bike_outlined;
  }

  if (t.contains('libro') ||
      t.contains('cuento') ||
      t.contains('lectura') ||
      t.contains('taller') ||
      e == '📚' ||
      e == '📖') {
    return Icons.menu_book_outlined;
  }

  if (t.contains('parque') ||
      t.contains('excursión') ||
      t.contains('camping') ||
      t.contains('naturaleza') ||
      e == '🏕️' ||
      e == '🌳' ||
      e == '🏖️') {
    return Icons.park_outlined;
  }

  if (t.contains('juego') ||
      t.contains('mesa') ||
      t.contains('consola') ||
      e == '🎮' ||
      e == '🎲') {
    return Icons.sports_esports_outlined;
  }

  if (t.contains('arte') ||
      t.contains('dibujo') ||
      t.contains('pintura') ||
      e == '🎨') {
    return Icons.palette_outlined;
  }

  if (t.contains('música') ||
      t.contains('musica') ||
      t.contains('canción') ||
      t.contains('concierto') ||
      e == '🎵' ||
      e == '🎶' ||
      e == '🎤') {
    return Icons.music_note_outlined;
  }

  if (t.contains('mascota') ||
      t.contains('perro') ||
      t.contains('gato') ||
      e == '🐶' ||
      e == '🐱') {
    return Icons.pets_outlined;
  }

  if (t.contains('reciclaje') ||
      t.contains('limpieza') ||
      t.contains('eco') ||
      e == '♻️') {
    return Icons.recycling_outlined;
  }

  if (t.contains('regalo') ||
      t.contains('sorpresa') ||
      e == '🎁') {
    return Icons.card_giftcard_outlined;
  }

  return Icons.eco_outlined;
}
