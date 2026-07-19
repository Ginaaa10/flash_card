import 'package:flutter/material.dart';

class AppTheme {
  static const Color pinkLight = Color(0xFFFF6B9D);
  static const Color pinkDark = Color(0xFFFF85A2);
  static const Color purpleLight = Color(0xFF9B5DE5);
  static const Color purpleDark = Color(0xFFB57BFF);
  static const Color blueLight = Color(0xFF00BBF9);
  static const Color blueDark = Color(0xFF48CAE4);
  static const Color greenLight = Color(0xFF00F5D4);
  static const Color greenDark = Color(0xFF56E8C1);
  static const Color yellowLight = Color(0xFFFFD166);
  static const Color orangeLight = Color(0xFFFF9F1C);
  static const Color coralLight = Color(0xFFFF6B6B);

  static const Color surfaceLight = Color(0xFFFFF5F9);
  static const Color surfaceDark = Color(0xFF1A1025);
  static const Color backgroundLight = Color(0xFFFFF0F5);
  static const Color backgroundDark = Color(0xFF120A1E);

  static const List<Color> cardColors = [
    Color(0xFFFFE4EC),
    Color(0xFFE8DEF8),
    Color(0xFFD0E8FF),
    Color(0xFFD4F0ED),
    Color(0xFFFFF3D6),
    Color(0xFFFFE0CC),
    Color(0xFFF0E0FF),
    Color(0xFFE0F7FA),
  ];

  static Color getCardColor(int index) => cardColors[index % cardColors.length];

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: pinkLight,
          secondary: purpleLight,
          tertiary: blueLight,
          surface: surfaceLight,
          error: coralLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF2D1B4E),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2D1B4E),
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D1B4E),
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          shadowColor: pinkLight.withOpacity(0.15),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkLight,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: purpleLight,
            side: const BorderSide(color: purpleLight, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: pinkLight.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: pinkLight.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: pinkLight, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: pinkLight,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: pinkLight,
          unselectedLabelColor: Colors.grey,
          indicatorColor: pinkLight,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF2D1B4E),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: pinkDark,
          secondary: purpleDark,
          tertiary: blueDark,
          surface: surfaceDark,
          error: Color(0xFFFF85A2),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFF0E0FF),
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFF0E0FF),
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF0E0FF),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: surfaceDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkDark,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: purpleDark,
            side: const BorderSide(color: purpleDark, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: purpleDark.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: purpleDark.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: pinkDark, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: pinkDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFFF0E0FF),
          contentTextStyle: const TextStyle(color: Color(0xFF1A1025)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
