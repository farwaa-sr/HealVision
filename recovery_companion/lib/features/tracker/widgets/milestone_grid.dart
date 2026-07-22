import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../model/tracker_models.dart';

/// The milestone ladder. Reached milestones glow with the apricot accent;
/// upcoming ones are quietly present, never nagging.
class MilestoneGrid extends StatelessWidget {
  const MilestoneGrid({super.key, required this.progress});

  final SubstanceProgress progress;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < kMilestones.length; i++)
          _MilestoneTile(
            milestone: kMilestones[i],
            reached: progress.longestStreak >= kMilestones[i].threshold,
          ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone, required this.reached});

  final Milestone milestone;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final accent = context.palette.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: reached
            ? Color.alphaBlend(
                accent.withValues(alpha: 0.22),
                context.palette.surfaceElevated,
              )
            : context.palette.field,
        borderRadius: BorderRadius.circular(14),
        border: reached
            ? Border.all(color: accent.withValues(alpha: 0.6))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reached ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: reached ? context.palette.onAccent : context.palette.muted,
          ),
          const SizedBox(width: 6),
          Text(
            milestone.label,
            style: context.text.labelMedium?.copyWith(
              color: reached ? context.colors.onSurface : context.palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}
