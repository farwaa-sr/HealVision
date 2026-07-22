import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/haptics.dart';

/// The five-point mood scale used across check-ins. Neutral, non-judgmental
/// language — "Low" and "Struggling", never "bad" or "failing".
enum Mood {
  great('😄', 'Great'),
  good('🙂', 'Good'),
  okay('😐', 'Okay'),
  low('😔', 'Low'),
  struggling('😣', 'Struggling');

  const Mood(this.emoji, this.label);

  final String emoji;
  final String label;
}

/// A calm horizontal mood selector with a gentle scale on the chosen option.
class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key, required this.value, required this.onChanged});

  final Mood? value;
  final ValueChanged<Mood> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final mood in Mood.values)
          Expanded(
            child: _MoodOption(
              mood: mood,
              selected: mood == value,
              onTap: () {
                Haptics.selection();
                onChanged(mood);
              },
            ),
          ),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.12 : 1,
        duration: AppMotion.duration(context, AppMotion.medium),
        curve: AppMotion.curve,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppMotion.duration(context, AppMotion.medium),
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? context.colors.primaryContainer
                    : palette.field,
              ),
              child: Text(mood.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 6),
            Text(
              mood.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                color: selected ? context.colors.primary : palette.muted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
