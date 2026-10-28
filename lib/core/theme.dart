import 'package:flutter/material.dart';

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
}

class AppTheme {
  static const primarySeed = Color(0xFF6750A4);
  static const habitColor = Color(0xFF4CAF50);
  static const reminderColor = Color(0xFF3F51B5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      color: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
