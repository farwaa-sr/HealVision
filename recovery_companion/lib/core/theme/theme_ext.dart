import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Ergonomic theme access from any widget:
///   context.palette.support, context.colors.primary, context.text.titleLarge
extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  /// Semantic app roles (SOS, accent, success, elevated surface, …).
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light();
}
