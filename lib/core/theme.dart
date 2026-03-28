import 'package:flutter/material.dart';

class AppTheme {
  // AskBee Brand Colors - Disney/Pixar inspired warm palette
  static const Color primaryYellow = Color(0xFFFFD93D);     // Sunny yellow
  static const Color primaryOrange = Color(0xFFFF6B35);    // Warm orange
  static const Color primaryTeal = Color(0xFF4ECDC4);      // Friendly teal
  static const Color primaryPurple = Color(0xFF9B59B6);     // Playful purple
  static const Color backgroundLight = Color(0xFFFFF9E6);   // Warm cream
  static const Color backgroundCard = Color(0xFFFFFFFF);   // Pure white cards
  static const Color textDark = Color(0xFF2C3E50);         // Soft dark text
  static const Color textLight = Color(0xFF7F8C8D);        // Muted text

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        primary: primaryOrange,
        secondary: primaryTeal,
        tertiary: primaryPurple,
        surface: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textDark,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: textLight,
          fontSize: 16,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
