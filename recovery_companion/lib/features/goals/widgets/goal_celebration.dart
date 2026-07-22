import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/app_button.dart';

/// A warm celebration when a goal is completed — apricot accent, gentle
/// scale-in, soft haptic. Small wins deserve real acknowledgment.
Future<void> showGoalCelebration(BuildContext context, String goalTitle) {
  Haptics.success();
  return showDialog<void>(
    context: context,
    builder: (_) => _GoalCelebrationDialog(goalTitle: goalTitle),
  );
}

class _GoalCelebrationDialog extends StatelessWidget {
  const _GoalCelebrationDialog({required this.goalTitle});

  final String goalTitle;

  @override
  Widget build(BuildContext context) {
    final accent = context.palette.accent;
    return Dialog(
      backgroundColor: Color.alphaBlend(
        accent.withValues(alpha: 0.16),
        context.palette.surfaceElevated,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: AppMotion.reduced(context) ? 1 : 0.85, end: 1),
        duration: AppMotion.duration(context, AppMotion.medium),
        curve: AppMotion.emphasized,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.25),
                ),
                child: Icon(Icons.emoji_events_outlined,
                    size: 34, color: context.palette.onAccent,),
              ),
              const SizedBox(height: 16),
              Text('Goal reached', style: context.text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '"$goalTitle" — done. Small wins like this are exactly how '
                'momentum is built. Well done.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Thank you',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
