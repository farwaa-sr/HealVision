import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/app_button.dart';
import '../model/tracker_models.dart';

/// A quiet celebration when a milestone is reached — apricot accent, a soft
/// scale-in, and a gentle haptic. Encouraging, never gamified or loud.
Future<void> showMilestoneCelebration(
  BuildContext context,
  Milestone milestone,
) {
  Haptics.success();
  return showDialog<void>(
    context: context,
    builder: (_) => _CelebrationDialog(milestone: milestone),
  );
}

class _CelebrationDialog extends StatelessWidget {
  const _CelebrationDialog({required this.milestone});

  final Milestone milestone;

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
                child: Icon(Icons.star_rounded,
                    size: 34, color: context.palette.onAccent,),
              ),
              const SizedBox(height: 16),
              Text('${milestone.label} clean',
                  style: context.text.headlineSmall, textAlign: TextAlign.center,),
              const SizedBox(height: 8),
              Text(
                'A real milestone. However you got here, it counts — and you '
                'earned it one moment at a time.',
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
