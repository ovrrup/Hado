import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTab { habits, reminders }

class HadoPalettes {
  // Habits Palette
  static const habitTerracotta = Color(0xFFB98258);
  static const habitSage = Color(0xFF8FB9B2);
  static const habitCream = Color(0xFFE7DFD0);

  // Reminders Palette
  static const reminderApricot = Color(0xFFE9B17F);
  static const reminderCoral = Color(0xFFDB7870);
  static const reminderCeladon = Color(0xFFD7E1D4);

  // Glass and neutral tokens
  static const glassBorderLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x66FFFFFF),
      Color(0x1AFFFFFF),
    ],
  );

  static const glassBorderDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x0DFFFFFF),
    ],
  );
}

class AppTheme {
  static TextTheme _getTextTheme(Brightness brightness) {
    try {
      final base = brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme;
      return GoogleFonts.outfitTextTheme(base);
    } catch (_) {
      return const TextTheme();
    }
  }

  static ThemeData getTheme(bool isHabitsMode, {bool isDark = false}) {
    final primary = isHabitsMode
        ? HadoPalettes.habitTerracotta
        : HadoPalettes.reminderCoral;

    final secondary = isHabitsMode
        ? HadoPalettes.habitSage
        : HadoPalettes.reminderApricot;

    final brightness = isDark ? Brightness.dark : Brightness.light;
    final textTheme = _getTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Lets shader background shine through
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? Colors.black.withOpacity(0.25)
            : Colors.white.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  // Backwards compatibility defaults
  static ThemeData lightTheme = getTheme(true, isDark: false);
  static ThemeData darkTheme = getTheme(true, isDark: true);
}
