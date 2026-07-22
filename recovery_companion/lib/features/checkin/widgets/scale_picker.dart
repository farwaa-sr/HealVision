import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../core/utils/haptics.dart';

/// A quick 1–N tap scale (energy, sleep quality…). Big, fast targets with
/// optional low/high captions — no typing, no fuss.
class ScalePicker extends StatelessWidget {
  const ScalePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.lowLabel,
    this.highLabel,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final int count;
  final String? lowLabel;
  final String? highLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 1; i <= count; i++) ...[
              if (i > 1) const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                  label: '$i',
                  selected: value == i,
                  onTap: () {
                    Haptics.selection();
                    onChanged(i);
                  },
                ),
              ),
            ],
          ],
        ),
        if (lowLabel != null || highLabel != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lowLabel ?? '',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.palette.muted),),
              Text(highLabel ?? '',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.palette.muted),),
            ],
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.colors.primary : context.palette.field,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: context.text.titleMedium?.copyWith(
            color: selected ? context.colors.onPrimary : context.colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
