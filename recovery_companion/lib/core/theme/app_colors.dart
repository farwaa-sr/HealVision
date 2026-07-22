import 'package:flutter/material.dart';

/// Raw palette constants. Emotional target: calm, grounded, hopeful, private.
///
/// Rationale: teal-green lowers arousal and reads as growth/stability; the
/// apricot accent adds warmth and hope (used sparingly for highlights and
/// celebrations); large fields of aggressive red raise anxiety, so red is
/// confined to the single SOS action as a *grounded* coral — findable, not
/// panic-inducing. Neutrals are warm, never cold blue-greys.
///
/// Semantic, brightness-aware roles live in [AppPalette] (a ThemeExtension).
abstract class AppColors {
  // --- Brand ---
  static const Color seed = Color(0xFF2FA6A0); // teal-green (primary)
  static const Color apricot = Color(0xFFF4A261); // hope / celebration accent
  static const Color sage = Color(0xFF6BAF92); // progress / success
  static const Color coral = Color(0xFFE76F51); // SOS / urgent (grounded)

  // --- Light surfaces (warm) ---
  static const Color lightBackground = Color(0xFFFAF8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFDFB);
  static const Color lightField = Color(0xFFF1ECE6); // chips / inputs
  static const Color onLight = Color(0xFF2A2622); // warm near-black text
  static const Color onLightMuted = Color(0xFF6E655C); // warm grey text

  // --- Dark surfaces (deep desaturated navy-charcoal) ---
  static const Color darkBackground = Color(0xFF14171E);
  static const Color darkSurface = Color(0xFF1C202A);
  static const Color darkSurfaceElevated = Color(0xFF232836);
  static const Color darkField = Color(0xFF262B37);
  static const Color onDark = Color(0xFFECE7E1); // warm off-white text
  static const Color onDarkMuted = Color(0xFF9AA1AD);

  // --- On-accent foregrounds (chosen for WCAG AA) ---
  static const Color onCoral = Color(0xFFFFFFFF); // white on coral
  static const Color onApricot = Color(0xFF2A2622); // dark on light apricot
  static const Color onSage = Color(0xFF10241B); // dark on sage
  static const Color onSeed = Color(0xFFFFFFFF); // white on teal
}
