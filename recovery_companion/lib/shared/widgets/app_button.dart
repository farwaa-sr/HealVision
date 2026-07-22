import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';

enum AppButtonVariant { primary, secondary, tonal }

/// Themed button with primary / secondary / tonal variants and a light haptic
/// on press. Defaults to full width — the app favors calm, tappable targets.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;

  VoidCallback? get _handler => onPressed == null
      ? null
      : () {
          Haptics.tap();
          onPressed!();
        };

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary =>
        FilledButton(onPressed: _handler, child: child),
      AppButtonVariant.tonal =>
        FilledButton.tonal(onPressed: _handler, child: child),
      AppButtonVariant.secondary =>
        OutlinedButton(onPressed: _handler, child: child),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
