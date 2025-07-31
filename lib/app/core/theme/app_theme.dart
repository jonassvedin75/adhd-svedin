import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

// --- FÄRGER OCH TEMA ---
// Centraliserad plats för appens färgpalett för enkel åtkomst och konsekvens.
class AppColors {
  static const Color background = Color(0xFFF7F8FA);
  static const Color text = Color(0xFF3C3C3C);
  static const Color primary = Color(0xFF1E40AF);
  static const Color accent = Color(0xFFFBBF24);
  static const Color positive = Color(0xFF22C55E);
  static const Color lightGrey = Color(0xFFE5E7EB);
  
  // iOS-specifika färger
  static const Color iOSBackground = Color(0xFFF2F2F7);
  static const Color iOSSecondaryBackground = Color(0xFFFFFFFF);
}

// Appens övergripande tema - Mobile-First Design
final appTheme = ThemeData(
  scaffoldBackgroundColor: (!kIsWeb && Platform.isIOS) ? AppColors.iOSBackground : AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    surface: (!kIsWeb && Platform.isIOS) ? AppColors.iOSBackground : AppColors.background,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.text, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.text, fontSize: 14),
    titleLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 22),
    titleMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 18),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: (!kIsWeb && Platform.isIOS) ? AppColors.iOSSecondaryBackground : AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: const IconThemeData(color: AppColors.text),
    titleTextStyle: const TextStyle(
      color: AppColors.text,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    systemOverlayStyle: (!kIsWeb && Platform.isIOS) 
      ? SystemUiOverlayStyle.dark
      : SystemUiOverlayStyle.dark,
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
    unselectedIconTheme: IconThemeData(color: AppColors.text.withAlpha(153)),
    selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.background,
    indicatorColor: AppColors.primary.withAlpha(26),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ),
);
