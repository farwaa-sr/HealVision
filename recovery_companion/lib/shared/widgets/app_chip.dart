import 'package:flutter/material.dart';

import '../../core/theme/theme_ext.dart';
import '../../core/utils/haptics.dart';

/// A calm selectable chip. Selection gives a light selection haptic.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 18,
              color: selected
                  ? context.colors.onPrimaryContainer
                  : context.palette.muted,
            ),
      showCheckmark: false,
      onSelected: onSelected == null
          ? null
          : (value) {
              Haptics.selection();
              onSelected!(value);
            },
    );
  }
}
