import 'package:flutter/material.dart';

/// Paleta de Mood (tomada del prototipo de diseño).
class MoodColors {
  static const green = Color(0xFF2D6C5D);
  static const deep = Color(0xFF214E43);
  static const text = Color(0xFF24362F);
  static const muted = Color(0xFF73867E);
  static const line = Color(0xFFDCE6E1);
  static const background = Color(0xFFF6FAF8);
  static const orange = Color(0xFFF6AC69);
  static const blue = Color(0xFF4C8198);
  static const purple = Color(0xFF9080B0);
  static const mint = Color(0xFFDFF2E9);
  static const peach = Color(0xFFFFF0E0);
  static const peachText = Color(0xFFAB6B24);
  static const lavender = Color(0xFFEEE9F5);
  static const soft = Color(0xFFEDF5F1);
  static const blueSoft = Color(0xFFE3F0F5);
  static const dangerBg = Color(0xFFFBE8E7);
  static const danger = Color(0xFFC54849);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MoodColors.green,
      primary: MoodColors.green,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: MoodColors.background,
  );
  final text = base.textTheme.apply(
    bodyColor: MoodColors.text,
    displayColor: MoodColors.text,
  );
  return base.copyWith(
    textTheme: text,
    appBarTheme: const AppBarTheme(
      backgroundColor: MoodColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MoodColors.deep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MoodColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MoodColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MoodColors.green, width: 1.6),
      ),
    ),
  );
}
