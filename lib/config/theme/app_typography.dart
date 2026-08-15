import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Cosmyra Luxury Typography System
class AppTypography {
  // Heading font family: Playfair Display (Luxury Serif)
  // Body & UI font family: Plus Jakarta Sans / Inter (Clean Modern Sans)

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textDarkPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.textDarkPrimary,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textDarkPrimary,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textDarkPrimary,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textDarkPrimary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textDarkPrimary,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textDarkSecondary,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColors.textDarkPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: AppColors.textDarkSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.creamCard,
      letterSpacing: 0.5,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textLightPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.textLightPrimary,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textLightPrimary,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textLightPrimary,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textLightPrimary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textLightPrimary,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textLightSecondary,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColors.textLightPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: AppColors.textLightSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColors.textLightPrimary,
      letterSpacing: 0.5,
    ),
  );
}
