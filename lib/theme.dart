import 'package:flutter/material.dart';

const moodGreen = Color(0xff2d6c5d);
ThemeData moodTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: moodGreen,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark
        ? const Color(0xff121e1a)
        : const Color(0xfff6faf8),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -.5,
        color: dark ? const Color(0xffe4eee9) : const Color(0xff24362f),
      ),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyMedium: const TextStyle(fontSize: 13, height: 1.5),
      bodySmall: TextStyle(
        fontSize: 11,
        height: 1.45,
        color: dark ? const Color(0xffa4b8ac) : const Color(0xff73867e),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xff1c2d25) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: dark ? const Color(0xff8ed3b9) : moodGreen,
        foregroundColor: dark ? const Color(0xff143d2d) : Colors.white,
        minimumSize: const Size(double.infinity, 48),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 46),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      side: BorderSide.none,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xff182820) : Colors.white,
      indicatorColor: dark ? const Color(0xff2b5140) : const Color(0xffdceee6),
      height: 75,
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 10)),
    ),
    dividerColor: scheme.outlineVariant.withValues(alpha: .5),
  );
}

IconData habitIcon(String name) => switch (name) {
  'water' => Icons.water_drop_outlined,
  'book' => Icons.menu_book_outlined,
  'sleep' => Icons.bedtime_outlined,
  'heart' => Icons.favorite_border,
  _ => Icons.directions_walk_outlined,
};
