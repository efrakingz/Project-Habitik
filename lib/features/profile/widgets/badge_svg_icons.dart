import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Catálogo de diseños vectoriales SVG de alta definición para cada logro y medalla de Habitik.
/// Diseñados específicamente con la paleta esmeralda, cian y dorada oficial del proyecto.
class BadgeSvgIcons {
  const BadgeSvgIcons._();

  /// Trofeo minimalista en SVG para la tarjeta "Mis Medallas" del perfil
  static const String trophyMinimalist = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Base inferior -->
  <rect x="14" y="38" width="20" height="4" rx="2" fill="#D97706"/>
  <rect x="17" y="34" width="14" height="4" rx="1.5" fill="#F59E0B"/>
  <!-- Tallo / Pedestal -->
  <path d="M22 27H26V34H22V27Z" fill="#F59E0B"/>
  <path d="M20 27H28C27.5 31 26.5 33 26 34H22C21.5 33 20.5 31 20 27Z" fill="#FBBF24"/>
  <!-- Asas laterales elegantes -->
  <path d="M14 13C10.5 13 9 16 9 19.5C9 23.5 12 26 15 26.5L15.5 24C13 23.5 11.5 21.8 11.5 19.5C11.5 17.5 12.5 15.5 14.5 15.2L14 13Z" fill="#F59E0B"/>
  <path d="M34 13C37.5 13 39 16 39 19.5C39 23.5 36 26 33 26.5L32.5 24C35 23.5 36.5 21.8 36.5 19.5C36.5 17.5 35.5 15.5 33.5 15.2L34 13Z" fill="#F59E0B"/>
  <!-- Copa principal -->
  <path d="M14 11H34V20C34 25.5228 29.5228 30 24 30C18.4772 30 14 25.5228 14 20V11Z" fill="#FBBF24"/>
  <!-- Reflejo interior / volumen -->
  <path d="M17 13H24V28C20 27.5 17 24.2 17 20V13Z" fill="#FCD34D"/>
  <!-- Borde superior copa -->
  <rect x="13" y="9" width="22" height="3" rx="1.5" fill="#F59E0B"/>
  <!-- Estrella / Brillo minimalista central -->
  <path d="M24 16L25 19L28 20L25 21L24 24L23 21L20 20L23 19L24 16Z" fill="#FFFFFF" opacity="0.95"/>
</svg>
''';

  /// Helper para renderizar el trofeo minimalista SVG de Mis Medallas
  static Widget buildTrophySvg({double size = 28}) {
    return SvgPicture.string(
      trophyMinimalist,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  /// Candado redondeado con resplandor menta/esmeralda para medallas bloqueadas (según diseño oficial)
  static const String padlockLocked = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="8" y="18" width="32" height="24" rx="6" fill="#0C261B" stroke="#10B981" stroke-width="2.5"/>
  <path d="M16 18V13C16 8.58172 19.5817 5 24 5C28.4183 5 32 8.58172 32 13V18" stroke="#34D399" stroke-width="2.5" stroke-linecap="round"/>
  <circle cx="24" cy="28" r="3" fill="#10B981"/>
  <path d="M24 31V35" stroke="#10B981" stroke-width="2.5" stroke-linecap="round"/>
  <circle cx="13" cy="23" r="1.5" fill="#059669"/>
  <circle cx="35" cy="23" r="1.5" fill="#059669"/>
</svg>
''';

  /// Ducha Eficiente (Speedrun de la Ducha - Nivel I)
  static const String duchaEficiente = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#0A2A38" stroke="#0284C7" stroke-width="2"/>
  <!-- Ducha y flujo de agua -->
  <path d="M12 14C12 10.6863 14.6863 8 18 8H26C27.1046 8 28 8.89543 28 10V14" stroke="#38BDF8" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M18 14H38L35 22H21L18 14Z" fill="#0284C7" stroke="#38BDF8" stroke-width="2" stroke-linejoin="round"/>
  <!-- Gotas de agua y velocidad -->
  <path d="M24 25L23 31" stroke="#38BDF8" stroke-width="2" stroke-linecap="round"/>
  <path d="M29 25L28 32" stroke="#38BDF8" stroke-width="2" stroke-linecap="round"/>
  <path d="M34 25L33 30" stroke="#38BDF8" stroke-width="2" stroke-linecap="round"/>
  <!-- Gota eco con cronómetro -->
  <path d="M24 34C24 34 18 39 18 41.5C18 43.433 19.567 45 21.5 45C22.69 45 23.75 44.4 24 43.5C24.25 44.4 25.31 45 26.5 45C28.433 45 30 43.433 30 41.5C30 39 24 34 24 34Z" fill="#10B981"/>
  <path d="M12 26L16 28" stroke="#34D399" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// Experto del Reciclaje (Eco-Puzzle 0 errores)
  static const String expertoReciclaje = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#0B2E1D" stroke="#059669" stroke-width="2"/>
  <!-- Triángulo de reciclaje moderno -->
  <path d="M24 9L29 17H21L24 9Z" fill="#34D399"/>
  <path d="M20 17H28C31.3137 17 34 19.6863 34 23V25" stroke="#10B981" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M38 27L33 35L29 29L38 27Z" fill="#34D399"/>
  <path d="M31 31L26 38C24.3431 39.6569 21.6569 39.6569 20 38L16 34" stroke="#10B981" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M12 30L17 22L21 28L12 30Z" fill="#34D399"/>
  <path d="M18 26L14 20C12.3431 18.3431 12.3431 15.6569 14 14L18 12" stroke="#10B981" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Hoja central -->
  <path d="M24 20C21 22 20 26 24 28C28 26 27 22 24 20Z" fill="#FBBF24"/>
</svg>
''';

  /// Constancia Verde (Racha y Hábitos - 3 días consecutivos)
  static const String constanciaVerde = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#2E1B0A" stroke="#D97706" stroke-width="2"/>
  <!-- Llama exterior dorada/fuego -->
  <path d="M24 7C24 7 14 17 14 27C14 33.6274 19.3726 39 26 39C32.6274 39 36 33 36 27C36 19 30 14 30 14C30 14 30 20 27 21C24 22 24 16 24 7Z" fill="#F59E0B" opacity="0.9"/>
  <!-- Núcleo de llama esmeralda -->
  <path d="M25 18C25 18 19 24 19 29C19 33 22 36 26 36C30 36 32 33 32 29C32 24 28 22 28 22C28 22 28 25 26.5 25.5C25 26 25 22 25 18Z" fill="#10B981"/>
  <!-- Hoja de constancia brotando -->
  <path d="M23 37V31M23 33C21 32 19 33 18 35M23 32C25 31 27 32 28 34" stroke="#FEF08A" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// Ducha de Bronce (5 Speedruns ecológicos completados)
  static const String duchaBronce = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#2C1A10" stroke="#B45309" stroke-width="2"/>
  <!-- Medalla de Bronce con cinta -->
  <path d="M18 6L14 18H20L22 6H18Z" fill="#0284C7"/>
  <path d="M30 6L34 18H28L26 6H30Z" fill="#0284C7"/>
  <circle cx="24" cy="27" r="14" fill="#78350F" stroke="#D97706" stroke-width="2.5"/>
  <circle cx="24" cy="27" r="10.5" stroke="#FBBF24" stroke-width="1.2" stroke-dasharray="2 2"/>
  <!-- Gota de bronce central -->
  <path d="M24 20C24 20 19 25.5 19 28C19 30.7614 21.2386 33 24 33C26.7614 33 29 30.7614 29 28C29 25.5 24 20 24 20Z" fill="#FBBF24"/>
  <circle cx="22.5" cy="27.5" r="1" fill="#FFFFFF" opacity="0.8"/>
  <text x="24" y="38" font-size="8" font-weight="900" fill="#FBBF24" text-anchor="middle" font-family="sans-serif">III</text>
</svg>
''';

  /// Cerebro Verde (10 trivias ecológicas perfectas)
  static const String cerebroVerde = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#1E1430" stroke="#7C3AED" stroke-width="2"/>
  <!-- Cerebro estilizado con hojas -->
  <path d="M24 12C20 12 16 14 16 18C14 19 13 22 14 25C13 28 15 31 17 32C18 34 20 36 24 36M24 12C28 12 32 14 32 18C34 19 35 22 34 25C35 28 33 31 31 32C30 34 28 36 24 36" stroke="#A78BFA" stroke-width="2.5" stroke-linecap="round"/>
  <path d="M24 14V34" stroke="#A78BFA" stroke-width="2" stroke-linecap="round"/>
  <!-- Circuitos de hojas ecológicas -->
  <circle cx="20" cy="21" r="2" fill="#34D399"/>
  <circle cx="28" cy="21" r="2" fill="#34D399"/>
  <circle cx="19" cy="28" r="2" fill="#FBBF24"/>
  <circle cx="29" cy="28" r="2" fill="#FBBF24"/>
  <path d="M24 8L25 11L28 12L25 13L24 16L23 13L20 12L23 11L24 8Z" fill="#FBBF24"/>
</svg>
''';

  /// Guardián de Boletas (3 boletas registradas con ahorro energético)
  static const String guardianBoletas = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#0C2626" stroke="#0D9488" stroke-width="2"/>
  <!-- Recibo con gráfico descendente -->
  <path d="M15 10H33V38L30 35L27 38L24 35L21 38L18 35L15 38V10Z" fill="#134E4A" stroke="#2DD4BF" stroke-width="2"/>
  <line x1="19" y1="16" x2="29" y2="16" stroke="#5EEAD4" stroke-width="2" stroke-linecap="round"/>
  <line x1="19" y1="21" x2="26" y2="21" stroke="#5EEAD4" stroke-width="2" stroke-linecap="round"/>
  <!-- Flecha verde de reducción de consumo -->
  <path d="M19 27L24 32L29 27" stroke="#34D399" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M24 24V32" stroke="#34D399" stroke-width="2.5" stroke-linecap="round"/>
  <circle cx="33" cy="14" r="4" fill="#F59E0B"/>
  <path d="M32 13L34 15L36 12" stroke="#1E293B" stroke-width="1.2" stroke-linecap="round"/>
</svg>
''';

  /// Ducha de Plata (10 Speedruns completados)
  static const String duchaPlata = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#1E293B" stroke="#64748B" stroke-width="2"/>
  <path d="M18 6L14 18H20L22 6H18Z" fill="#0284C7"/>
  <path d="M30 6L34 18H28L26 6H30Z" fill="#0284C7"/>
  <circle cx="24" cy="27" r="14" fill="#334155" stroke="#CBD5E1" stroke-width="2.5"/>
  <circle cx="24" cy="27" r="10.5" stroke="#E2E8F0" stroke-width="1.2" stroke-dasharray="2 2"/>
  <!-- Gota de plata -->
  <path d="M24 20C24 20 19 25.5 19 28C19 30.7614 21.2386 33 24 33C26.7614 33 29 30.7614 29 28C29 25.5 24 20 24 20Z" fill="#E2E8F0"/>
  <circle cx="22.5" cy="27.5" r="1" fill="#FFFFFF"/>
  <text x="24" y="38" font-size="8" font-weight="900" fill="#E2E8F0" text-anchor="middle" font-family="sans-serif">II</text>
</svg>
''';

  /// Ducha de Oro (20 Speedruns de ducha sustentable)
  static const String duchaOro = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#2E2305" stroke="#EAB308" stroke-width="2"/>
  <path d="M18 6L14 18H20L22 6H18Z" fill="#10B981"/>
  <path d="M30 6L34 18H28L26 6H30Z" fill="#10B981"/>
  <circle cx="24" cy="27" r="14" fill="#78350F" stroke="#FACC15" stroke-width="2.5"/>
  <circle cx="24" cy="27" r="10.5" stroke="#FEF08A" stroke-width="1.2" stroke-dasharray="2 2"/>
  <!-- Corona y Gota de Oro -->
  <path d="M21 21L24 18L27 21L26 23H22L21 21Z" fill="#FACC15"/>
  <path d="M24 23C24 23 20 27 20 29C20 31.2 21.8 33 24 33C26.2 33 28 31.2 28 29C28 27 24 23 24 23Z" fill="#FACC15"/>
  <circle cx="23" cy="28.5" r="1" fill="#FFFFFF"/>
  <text x="24" y="38" font-size="8" font-weight="900" fill="#FEF08A" text-anchor="middle" font-family="sans-serif">I</text>
</svg>
''';

  /// Racha Legendaria (14 días consecutivos de hábitos sustentables)
  static const String rachaLegendaria = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#2E120A" stroke="#EA580C" stroke-width="2"/>
  <!-- Doble fuego brillante con estrella -->
  <path d="M24 6C24 6 12 16 12 28C12 35.732 17.3726 42 24 42C30.6274 42 36 35.732 36 28C36 18 29 13 29 13C29 13 29 18 26 19C23 20 24 14 24 6Z" fill="#F97316"/>
  <path d="M24 16C24 16 17 23 17 29C17 33.4 20.1 37 24 37C27.9 37 31 33.4 31 29C31 23 27 20 27 20C27 20 27 23 25.5 23.5C24 24 24 20 24 16Z" fill="#FDE047"/>
  <!-- Estrella de maestría -->
  <path d="M24 26L25.5 29H29L26 31L27.5 34L24 32L20.5 34L22 31L19 29H22.5L24 26Z" fill="#10B981"/>
</svg>
''';

  /// Palabra Ecológica (Eco-Wordle completado)
  static const String palabraEcologica = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#0E281E" stroke="#10B981" stroke-width="2"/>
  <!-- Cuadrículas de letras Wordle verdes y doradas -->
  <rect x="12" y="14" width="10" height="10" rx="3" fill="#10B981" stroke="#34D399" stroke-width="1.5"/>
  <rect x="26" y="14" width="10" height="10" rx="3" fill="#F59E0B" stroke="#FBBF24" stroke-width="1.5"/>
  <rect x="12" y="27" width="10" height="10" rx="3" fill="#1E3A2F" stroke="#34D399" stroke-width="1.5"/>
  <rect x="26" y="27" width="10" height="10" rx="3" fill="#10B981" stroke="#34D399" stroke-width="1.5"/>
  <text x="17" y="22" font-size="8" font-weight="900" fill="#FFFFFF" text-anchor="middle" font-family="sans-serif">E</text>
  <text x="31" y="22" font-size="8" font-weight="900" fill="#FFFFFF" text-anchor="middle" font-family="sans-serif">C</text>
  <text x="17" y="35" font-size="8" font-weight="900" fill="#A7F3D0" text-anchor="middle" font-family="sans-serif">O</text>
  <text x="31" y="35" font-size="8" font-weight="900" fill="#FFFFFF" text-anchor="middle" font-family="sans-serif">!</text>
</svg>
''';

  /// Hogar Sustentable (Misión Familiar y colectas colaborativas)
  static const String hogarSustentable = '''
<svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="24" cy="24" r="22" fill="#0C2530" stroke="#0284C7" stroke-width="2"/>
  <!-- Casa con techo de hoja verde -->
  <path d="M24 10L12 21H16V36H32V21H36L24 10Z" fill="#075985" stroke="#38BDF8" stroke-width="2" stroke-linejoin="round"/>
  <!-- Hoja sustentable en el techo -->
  <path d="M24 12C21 15 21 19 24 21C27 19 27 15 24 12Z" fill="#10B981"/>
  <!-- Silueta familiar/corazón -->
  <circle cx="21" cy="27" r="2" fill="#FBBF24"/>
  <circle cx="27" cy="27" r="2" fill="#FBBF24"/>
  <path d="M19 33C19 31 20 29.5 21 29.5C22 29.5 23 31 23 33" stroke="#FBBF24" stroke-width="1.5"/>
  <path d="M25 33C25 31 26 29.5 27 29.5C28 29.5 29 31 29 33" stroke="#FBBF24" stroke-width="1.5"/>
</svg>
''';

  /// Retorna el SVG temático correspondiente a la clave o nombre del logro
  static String getSvgForBadge(String key, {bool isLocked = false}) {
    if (isLocked) {
      return padlockLocked;
    }

    final k = key.toUpperCase();
    if (k.contains('PRIMERA_DUCHA') ||
        k.contains('DUCHA_EFICIENTE') ||
        (k.contains('DUCHA') && k.contains('I')) ||
        k.contains('🚿')) {
      return duchaEficiente;
    }
    if (k.contains('RECICLADOR') ||
        k.contains('MAESTRO_ECO') ||
        k.contains('EXPERTO') ||
        k.contains('RECICL') ||
        k.contains('PUZZLE') ||
        k.contains('♻️')) {
      return expertoReciclaje;
    }
    if (k.contains('CONSTANCIA') ||
        (k.contains('RACHA') && (k.contains('3') || k.contains('VERDE') || k.contains('7'))) ||
        k.contains('🔥')) {
      return constanciaVerde;
    }
    if (k.contains('BRONCE') || (k.contains('DUCHA') && k.contains('5')) || k.contains('🥉')) {
      return duchaBronce;
    }
    if (k.contains('PLATA') || (k.contains('DUCHA') && k.contains('10')) || k.contains('🥈')) {
      return duchaPlata;
    }
    if (k.contains('ORO') || (k.contains('DUCHA') && k.contains('20')) || k.contains('🥇')) {
      return duchaOro;
    }
    if (k.contains('CEREBRO') || k.contains('TRIVIA') || k.contains('🧠')) {
      return cerebroVerde;
    }
    if (k.contains('BOLETA') || k.contains('GUARDIAN') || k.contains('ENERGIA') || k.contains('🧾')) {
      return guardianBoletas;
    }
    if (k.contains('WORDLE') || k.contains('MENTE') || k.contains('PALABRA') || k.contains('📝')) {
      return palabraEcologica;
    }
    if (k.contains('RACHA_LEGENDARIA') || (k.contains('RACHA') && k.contains('14'))) {
      return rachaLegendaria;
    }
    if (k.contains('FAMILIAR') || k.contains('HOGAR') || k.contains('EQUIPO') || k.contains('👨‍👩‍👧‍👦')) {
      return hogarSustentable;
    }

    // Default: si contiene racha llama a constancia, si contiene agua a ducha, etc.
    if (k.contains('AGUA') || k.contains('DUCHA')) return duchaEficiente;
    if (k.contains('RACHA')) return constanciaVerde;
    return expertoReciclaje;
  }

  /// Widget helper que renderiza el SVG temático escalado
  static Widget buildSvg(
    String key, {
    bool isLocked = false,
    double size = 28,
  }) {
    final rawSvg = getSvgForBadge(key, isLocked: isLocked);
    return SvgPicture.string(
      rawSvg,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  /// Retorna un título corto, legible y fiel al nombre original para cualquier código o clave de medalla
  static String getBadgeTitle(String? key) {
    if (key == null || key.trim().isEmpty) return 'Insignia';
    final k = key.toUpperCase().trim();

    // Mapeos exactos de los nombres oficiales de Habitik
    if (k == 'RECICLADOR_PERFECTO' || k.contains('RECICLADOR_PERFECTO')) return 'Reciclador Perfecto';
    if (k == 'RECICLADOR_IMPECABLE' || k.contains('RECICLADOR_IMPECABLE')) return 'Reciclador Impecable';
    if (k == 'MAESTRO_ECO' || k.contains('MAESTRO_DEL_RECICLAJE')) return 'Maestro del Reciclaje';
    if (k.contains('EXPERTO_RECICLAJE') || k.contains('EXPERTO_DEL_RECICLAJE') || k == 'EXPERTO') return 'Experto del Reciclaje';
    if (k == 'PRIMERA_DUCHA' || k.contains('DUCHA_EFICIENTE')) return 'Ducha Eficiente';
    if (k.contains('DUCHA_NINJA') || k.contains('DUCHA_TEST')) return 'Ducha Ninja';
    if (k.contains('DUCHA_BRONCE')) return 'Ducha de Bronce';
    if (k.contains('DUCHA_PLATA')) return 'Ducha de Plata';
    if (k.contains('DUCHA_ORO')) return 'Ducha de Oro';
    if (k.contains('DUCHA_RELAMPAGO')) return 'Ducha Relámpago';
    if (k.contains('CONSTANCIA') || k.contains('RACHA_7')) return 'Constancia Verde';
    if (k.contains('RACHA_14') || k.contains('RACHA_LEGENDARIA')) return 'Racha Legendaria';
    if (k.contains('HABITO_ORO')) return 'Hábito de Oro';
    if (k.contains('CEREBRO_VERDE') || k.contains('TRIVIA')) return 'Cerebro Verde';
    if (k.contains('GUARDIAN_BOLETAS') || (k.contains('GUARDIAN') && k.contains('BOLETA'))) return 'Guardián de Boletas';
    if (k.contains('MENTE_VERDE') || k.contains('PALABRA_ECOLOGICA')) return 'Palabra Ecológica';
    if (k.contains('HOGAR_SUSTENTABLE') || k.contains('ESPIRITU_FAMILIAR')) return 'Hogar Sustentable';
    if (k.contains('ESPIRITU_EQUIPO') || k.contains('ESPIRITU_DE_EQUIPO')) return 'Espíritu de Equipo';
    if (k.contains('CANJE') || k.contains('FRUTOS') || k.contains('PRIMEROS_FRUTOS')) return 'Primeros Frutos';
    if (k.contains('EXPLORADOR')) return 'Explorador Sustentable';

    // Mapeo defensivo si viene un emoji directo como insignia destacada
    if (k.contains('🚿')) return 'Ducha Eficiente';
    if (k.contains('♻️')) return 'Reciclador Perfecto';
    if (k.contains('🧠')) return 'Cerebro Verde';
    if (k.contains('🔥')) return 'Constancia Verde';
    if (k.contains('🧾')) return 'Guardián de Boletas';
    if (k.contains('📝')) return 'Palabra Ecológica';
    if (k.contains('👨‍👩‍👧‍👦')) return 'Hogar Sustentable';
    if (k.contains('🥇')) return 'Ducha de Oro';
    if (k.contains('🥈')) return 'Ducha de Plata';
    if (k.contains('🥉')) return 'Ducha de Bronce';

    // Fallback universal: Si el texto viene en SNAKE_CASE con guiones bajos o todo en MAYÚSCULAS,
    // se transforma elegantemente a Title Case para nunca mostrar "VARIABLE_NAME" en la interfaz.
    if (key.contains('_') || key == key.toUpperCase()) {
      final words = key.replaceAll(RegExp(r'[_-]+'), ' ').trim().toLowerCase().split(RegExp(r'\s+'));
      return words.asMap().entries.map((entry) {
        final w = entry.value;
        if (w.isEmpty) return '';
        // Preposiciones y artículos en minúscula salvo al inicio
        if (entry.key > 0 && ['de', 'del', 'la', 'el', 'los', 'las', 'en', 'y', 'con', 'por'].contains(w)) {
          return w;
        }
        return '${w[0].toUpperCase()}${w.substring(1)}';
      }).join(' ');
    }

    return key;
  }
}
