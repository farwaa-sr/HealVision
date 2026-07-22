import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, rounded-but-highly-legible type built on Plus Jakarta Sans.
///
/// Generous line height and spacing so the app feels like it can breathe.
abstract class AppTypography {
  static TextTheme build(ColorScheme scheme) {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    TextStyle s(
      TextStyle? from, {
      required double size,
      required FontWeight weight,
      required double height,
      double spacing = 0,
    }) {
      return (from ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: scheme.onSurface,
      );
    }

    return base
        .copyWith(
          // Display / headlines — confident but not shouty.
          displaySmall:
              s(base.displaySmall, size: 34, weight: FontWeight.w700, height: 1.2),
          headlineMedium:
              s(base.headlineMedium, size: 28, weight: FontWeight.w700, height: 1.25),
          headlineSmall:
              s(base.headlineSmall, size: 23, weight: FontWeight.w600, height: 1.3),
          titleLarge:
              s(base.titleLarge, size: 20, weight: FontWeight.w600, height: 1.35),
          titleMedium: s(base.titleMedium,
              size: 16, weight: FontWeight.w600, height: 1.4, spacing: 0.1,),
          // Body — roomy line height for easy reading.
          bodyLarge:
              s(base.bodyLarge, size: 16, weight: FontWeight.w400, height: 1.55),
          bodyMedium:
              s(base.bodyMedium, size: 14.5, weight: FontWeight.w400, height: 1.55),
          bodySmall: s(base.bodySmall,
              size: 12.5, weight: FontWeight.w400, height: 1.5, spacing: 0.1,),
          // Labels — buttons and chips.
          labelLarge: s(base.labelLarge,
              size: 15, weight: FontWeight.w600, height: 1.2, spacing: 0.2,),
          labelMedium: s(base.labelMedium,
              size: 13, weight: FontWeight.w600, height: 1.2, spacing: 0.3,),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}
