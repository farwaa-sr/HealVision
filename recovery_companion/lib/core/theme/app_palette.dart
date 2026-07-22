import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic, brightness-aware color roles the app reads from the theme.
///
/// Accessed via `Theme.of(context).extension<AppPalette>()` (or the
/// `context.palette` helper in `theme_ext.dart`), so components never hardcode
/// hex values and both light and dark stay in sync.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.support,
    required this.onSupport,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.onSuccess,
    required this.surfaceElevated,
    required this.field,
    required this.muted,
    required this.ringTrack,
  });

  /// SOS / "I'm craving" action.
  final Color support;
  final Color onSupport;

  /// Warm apricot accent — highlights and celebrations (used sparingly).
  final Color accent;
  final Color onAccent;

  /// Progress / success (sage).
  final Color success;
  final Color onSuccess;

  /// Elevated card/sheet surface above the scaffold background.
  final Color surfaceElevated;

  /// Subtle field/chip background.
  final Color field;

  /// Muted secondary text.
  final Color muted;

  /// Track (unfilled) color for progress rings and bars.
  final Color ringTrack;

  factory AppPalette.light() => const AppPalette(
        support: AppColors.coral,
        onSupport: AppColors.onCoral,
        accent: AppColors.apricot,
        onAccent: AppColors.onApricot,
        success: AppColors.sage,
        onSuccess: AppColors.onSage,
        surfaceElevated: AppColors.lightSurfaceElevated,
        field: AppColors.lightField,
        muted: AppColors.onLightMuted,
        ringTrack: Color(0xFFE6DFD7),
      );

  factory AppPalette.dark() => const AppPalette(
        support: AppColors.coral,
        onSupport: AppColors.onCoral,
        accent: AppColors.apricot,
        onAccent: AppColors.onApricot,
        success: AppColors.sage,
        onSuccess: AppColors.onSage,
        surfaceElevated: AppColors.darkSurfaceElevated,
        field: AppColors.darkField,
        muted: AppColors.onDarkMuted,
        ringTrack: Color(0xFF313846),
      );

  @override
  AppPalette copyWith({
    Color? support,
    Color? onSupport,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? onSuccess,
    Color? surfaceElevated,
    Color? field,
    Color? muted,
    Color? ringTrack,
  }) {
    return AppPalette(
      support: support ?? this.support,
      onSupport: onSupport ?? this.onSupport,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      field: field ?? this.field,
      muted: muted ?? this.muted,
      ringTrack: ringTrack ?? this.ringTrack,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      support: Color.lerp(support, other.support, t)!,
      onSupport: Color.lerp(onSupport, other.onSupport, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      field: Color.lerp(field, other.field, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
    );
  }
}
