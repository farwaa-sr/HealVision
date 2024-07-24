import 'package:flutter/material.dart';

class WColors {
  // App Theme Colors
  static const Color primary = Color(0xFFEB6658);
  static const Color secondary = Color(0xfff7f7f7);

  // TextColor
  static const Color textpri = Color(0xFF926247);
  static const Color textcolor = Color(0xFF003F5F);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Status Color
  static const confirm = Color(0xFF008200); // Green for confirmed
  static const completed = Color(0xFF8502fd); // Red for cancelled
  static const pending = Color(0xFFFFC107); // Amber for pending
  static const cancelled = Color(0xFFF44336); // Red for cancelled

  // Background colors
  static const Color customcontainer = Color(0xFFE8DDD9);
  static const Color light = Color(0xFFE8EFFD);
  static const Color dark = Color(0xFF2b2b2b);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = WColors.white.withOpacity(0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF191919);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}
