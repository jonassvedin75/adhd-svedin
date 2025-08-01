import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Research-Based Color Palette ---

class AppColors {
  // Base Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF1F2937);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color bordersAndIcons = Color(0xFFCBD5E1);

  // Accent Colors
  static const Color primary = Color(0xFF3B82F6);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  
  // Special Colors
  static const Color kaosBackground = Color(0xFF1E3A8A);
  static const Color focusPause = Color(0xFFFBBF24);
}


// --- Unified App Themes ---

class AppThemes {
  static final TextTheme _baseTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
      labelLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.success,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.cardSurface,
        onSurface: AppColors.darkText,
      ),
      textTheme: _baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        titleTextStyle: _baseTextTheme.titleLarge?.copyWith(fontSize: 22),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: _baseTextTheme.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.bordersAndIcons.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bordersAndIcons),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.darkText.withValues(alpha: 0.7)),
      ),
    );
  }
}
