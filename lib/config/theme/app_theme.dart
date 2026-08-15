import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Cosmyra Luxury Light and Dark Theme Configurations
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.creamBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestSage,
        onPrimary: AppColors.creamCard,
        secondary: AppColors.goldAccent,
        onSecondary: AppColors.forestSageDark,
        surface: AppColors.creamCard,
        onSurface: AppColors.textDarkPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: AppTypography.lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creamBackground,
        foregroundColor: AppColors.forestSageDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge?.copyWith(
          color: AppColors.forestSageDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.creamCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.creamBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestSage,
          foregroundColor: AppColors.creamCard,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestSage,
          side: const BorderSide(color: AppColors.forestSage, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
            color: AppColors.forestSage,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.forestSage, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.creamCard,
        selectedItemColor: AppColors.forestSage,
        unselectedItemColor: AppColors.textDarkSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.charcoalBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldAccent,
        onPrimary: AppColors.forestSageDark,
        secondary: AppColors.sageMuted,
        onSecondary: AppColors.creamCard,
        surface: AppColors.charcoalCard,
        onSurface: AppColors.textLightPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: AppTypography.darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.charcoalBackground,
        foregroundColor: AppColors.textLightPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.darkTextTheme.titleLarge?.copyWith(
          color: AppColors.textLightPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoalCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.charcoalBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldAccent,
          foregroundColor: AppColors.forestSageDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.darkTextTheme.labelLarge?.copyWith(
            color: AppColors.forestSageDark,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldAccent,
          side: const BorderSide(color: AppColors.goldAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.darkTextTheme.labelLarge?.copyWith(
            color: AppColors.goldAccent,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.charcoalCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.charcoalBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.charcoalBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.goldAccent, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.charcoalCard,
        selectedItemColor: AppColors.goldAccent,
        unselectedItemColor: AppColors.textLightSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
