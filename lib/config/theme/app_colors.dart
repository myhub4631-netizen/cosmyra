import 'package:flutter/material.dart';

/// Cosmyra & Vaidyam Luxury Design Color Tokens
class AppColors {
  // Primary Palette (Deep Botanical Sage & Forest)
  static const Color forestSageDark = Color(0xFF142C23);
  static const Color forestSage = Color(0xFF1E3A2F);
  static const Color sageMuted = Color(0xFF3F6354);
  static const Color sageLight = Color(0xFFE8EFEA);

  // Accent Palette (Warm Muted Luxury Gold & Bronze)
  static const Color goldAccent = Color(0xFFC5A059);
  static const Color goldAccentLight = Color(0xFFDFCA9B);
  static const Color bronzeAccent = Color(0xFFA67C37);

  // Background & Surface (Light Mode - Warm Cream / Ivory)
  static const Color creamBackground = Color(0xFFFAF7F2);
  static const Color creamCard = Color(0xFFFFFFFF);
  static const Color creamBorder = Color(0xFFEFE8DC);

  // Background & Surface (Dark Mode - Rich Deep Charcoal)
  static const Color charcoalBackground = Color(0xFF0F1512);
  static const Color charcoalCard = Color(0xFF18221D);
  static const Color charcoalBorder = Color(0xFF28362F);
  static const Color charcoalDark = Color(0xFF0B100D);
  static const Color softWhite = Color(0xFFFAF8F5);

  // Text Colors
  static const Color textDarkPrimary = Color(0xFF1E2621);
  static const Color textDarkSecondary = Color(0xFF5A6660);
  static const Color textLightPrimary = Color(0xFFF7F5F0);
  static const Color textLightSecondary = Color(0xFFA0ABA4);

  // Feedback & Status Badges
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Gradients
  static const LinearGradient luxurySageGradient = LinearGradient(
    colors: [forestSageDark, forestSage],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldShimmerGradient = LinearGradient(
    colors: [goldAccent, goldAccentLight, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
