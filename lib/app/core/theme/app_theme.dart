import 'package:flutter/material.dart';

// --- FÄRGER OCH TEMA ---
// Centraliserad plats för appens färgpalett för enkel åtkomst och konsekvens.
class AppColors {
  static const Color background = Color(0xFFF7F8FA);
  static const Color text = Color(0xFF3C3C3C);
  static const Color primary = Color(0xFF1E40AF);
  static const Color accent = Color(0xFFFBBF24);
  static const Color positive = Color(0xFF22C55E);
  static const Color lightGrey = Color(0xFFE5E7EB);
}

// Appens övergripande tema.
final appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    surface: AppColors.background, // Byt ut 'background' mot 'surface'
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
    titleLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.text),
    titleTextStyle: TextStyle(
        color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: AppColors.background,
    selectedIconTheme: const IconThemeData(color: AppColors.primary),
    unselectedIconTheme: IconThemeData(color: AppColors.text.withAlpha(153)), // Använd withAlpha istället för withOpacity
    selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.background,
    indicatorColor: AppColors.primary.withAlpha(26), // Använd withAlpha istället för withOpacity
    labelTextStyle: WidgetStateProperty.all( // Byt ut MaterialStateProperty mot WidgetStateProperty
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  )
);
