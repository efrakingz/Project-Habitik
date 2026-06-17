import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

/// Sistema de colores y tema de Habitik – estilo casual game colorido
class HabitikColors {
  // ── Primarios (Verde Eco) ─────────────────────────────────────────────────
  static const green900 = Color(0xFF1B5E20);
  static const green800 = Color(0xFF2E7D32);
  static const green700 = Color(0xFF388E3C);
  static const green600 = Color(0xFF43A047);
  static const green500 = Color(0xFF4CAF50);
  static const green400 = Color(0xFF66BB6A);
  static const green300 = Color(0xFF81C784);
  static const green200 = Color(0xFFA5D6A7);
  static const green100 = Color(0xFFC8E6C9);
  static const green50  = Color(0xFFE8F5E9);

  // ── Acento 1: Amarillo/Ámbar (XP, coins) ─────────────────────────────────
  static const amber500 = Color(0xFFFFD600);
  static const amber400 = Color(0xFFFFCA28);
  static const amber300 = Color(0xFFFFD54F);
  static const amber200 = Color(0xFFFFE082);
  static const amber100 = Color(0xFFFFF9C4);

  // ── Acento 2: Naranja (fuego, racha) ─────────────────────────────────────
  static const orange500 = Color(0xFFFF5722);
  static const orange400 = Color(0xFFFF7043);
  static const orange300 = Color(0xFFFF8A65);

  // ── Acento 3: Púrpura (retos especiales, trivia) ─────────────────────────
  static const purple500 = Color(0xFF9C27B0);
  static const purple400 = Color(0xFFAB47BC);
  static const purple300 = Color(0xFFCE93D8);
  static const purple100 = Color(0xFFF3E5F5);

  // ── Acento 4: Azul (agua, energía) ───────────────────────────────────────
  static const blue500  = Color(0xFF2196F3);
  static const blue400  = Color(0xFF42A5F5);
  static const blue300  = Color(0xFF90CAF9);
  static const blue100  = Color(0xFFE3F2FD);

  // ── Acento 5: Rosa (logros, jefa) ────────────────────────────────────────
  static const pink500  = Color(0xFFE91E63);
  static const pink300  = Color(0xFFF48FB1);
  static const pink100  = Color(0xFFFCE4EC);

  // ── Neutros ───────────────────────────────────────────────────────────────
  static const bgLight   = Color(0xFFF5F5F5);
  static const bgWhite   = Color(0xFFFFFFFF);
  static const surface   = Color(0xFFFAFAFA);
  static const textDark  = Color(0xFF1A2E1A);
  static const textMid   = Color(0xFF4E6B4E);
  static const textLight = Color(0xFF8AAF8A);
  static const textHint  = Color(0xFFBDBDBD);
  static const divider   = Color(0xFFE0E0E0);

  // ── Overlay / Glass ───────────────────────────────────────────────────────
  static const blackOverlay12 = Color(0x1F000000);
  static const blackOverlay20 = Color(0x33000000);
  static const whiteOverlay20 = Color(0x33FFFFFF);
  static const whiteOverlay10 = Color(0x1AFFFFFF);

  // ── Gradientes reutilizables ──────────────────────────────────────────────
  static const Gradient heroGreen = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient xpGold = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient fireStreak = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient coolBlue = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient purpleMagic = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Theme Specific Colors & Sub-surfaces ─────────────────────────────
  static const darkBgAlert = Color(0xFF16251B);
  static const darkInputFill = Color(0xFF1C2C21);
  static const darkCardBg = Color(0xFF1E2E22);
  static const darkCardClaimedBg = Color(0xFF161E1A);
  static const darkSubSurface = Color(0xFF141F17);
  static const darkSelectedIcon = Color(0xFF2E3D32);
  static const lightCardBg = Color(0xFFEBF7EC);

  // ── Eco-Puzzle & Game Colors ──────────────────────────────────────────────
  static const gameBlueBg = Color(0xFF0A1628);
  static const gameGridLines = Color(0xFF192A43);
  static const gamePanelDark = Color(0xFF112244);
  static const gameTimerCyan = Color(0xFF00E5FF);
  static const gameSuccessGreen = Color(0xFF00C853);
  
  // ── Conveyor Belt Industrial Colors ───────────────────────────────────────
  static const beltDark = Color(0xFF212121);
  static const beltMetalBorder = Color(0xFF90A4AE);
  static const beltBody = Color(0xFF1E272C);
  static const beltYellowStripe = Color(0xFFFFD54F);
  static const beltGearMetal = Color(0xFF78909C);
  static const beltGearDarkHub = Color(0xFF263238);
}

/// Radios y espaciados estándar
class HabitikRadius {
  static const xs  = 6.0;
  static const sm  = 10.0;
  static const md  = 14.0;
  static const lg  = 20.0;
  static const xl  = 28.0;
  static const xxl = 40.0;
  static const full = 999.0;

  static BorderRadius xs_  = BorderRadius.circular(xs);
  static BorderRadius sm_  = BorderRadius.circular(sm);
  static BorderRadius md_  = BorderRadius.circular(md);
  static BorderRadius lg_  = BorderRadius.circular(lg);
  static BorderRadius xl_  = BorderRadius.circular(xl);
  static BorderRadius xxl_ = BorderRadius.circular(xxl);
}

/// Sombras estilizadas
class HabitikShadows {
  static List<BoxShadow> card = [
    BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> floating = [
    BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> colored(Color color) => [
    BoxShadow(color: color.withAlpha(80), blurRadius: 14, offset: const Offset(0, 6)),
  ];
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(color: color.withAlpha(80), blurRadius: 14, offset: const Offset(0, 4)),
  ];
}

/// Tema principal de la app
class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.nunitoTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: HabitikColors.green700,
      primary: HabitikColors.green700,
      secondary: HabitikColors.amber400,
      surface: HabitikColors.bgLight,
    ),
    scaffoldBackgroundColor: HabitikColors.bgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: HabitikColors.green700,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: HabitikColors.green700,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HabitikColors.green700,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: HabitikRadius.md_, borderSide: const BorderSide(color: HabitikColors.green200)),
      enabledBorder: OutlineInputBorder(borderRadius: HabitikRadius.md_, borderSide: const BorderSide(color: HabitikColors.green200)),
      focusedBorder: OutlineInputBorder(borderRadius: HabitikRadius.md_, borderSide: const BorderSide(color: HabitikColors.green500, width: 2)),
      labelStyle: const TextStyle(color: HabitikColors.textLight, fontFamily: 'Nunito'),
      hintStyle: const TextStyle(color: HabitikColors.textHint, fontFamily: 'Nunito'),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: HabitikColors.green700,
      brightness: Brightness.dark,
      primary: HabitikColors.green500,
      secondary: HabitikColors.amber400,
      surface: const Color(0xFF111D15),
    ),
    scaffoldBackgroundColor: const Color(0xFF111D15),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A3322),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: HabitikColors.green600,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HabitikColors.green400,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E2E22),
      border: OutlineInputBorder(borderRadius: HabitikRadius.md_, borderSide: const BorderSide(color: HabitikColors.green600)),
      enabledBorder: OutlineInputBorder(borderRadius: HabitikRadius.md_, borderSide: const BorderSide(color: HabitikColors.green600)),
      focusedBorder: OutlineInputBorder(borderRadius: HabitikRadius.md_, borderSide: const BorderSide(color: HabitikColors.green400, width: 2)),
      labelStyle: const TextStyle(color: HabitikColors.green200, fontFamily: 'Nunito'),
      hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Nunito'),
    ),
  );
}
