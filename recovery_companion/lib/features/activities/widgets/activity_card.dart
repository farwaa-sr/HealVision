import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../data/activities_repository.dart';
import '../model/activity_meta.dart';

/// One activity in the library / recommendations — its "why this helps", any
/// personalized mood-lift stat, and quick actions.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onDo,
    required this.onSchedule,
    this.stat,
    this.onArchive,
  });

  final Activity activity;
  final VoidCallback onDo;
  final VoidCallback onSchedule;
  final ActivityStat? stat;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final category = ActivityCategory.fromName(activity.category);
    final s = stat;
    final lifts = s != null && s.count > 0 && s.avgMoodDelta > 0.2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(category.label,
                  style: context.text.labelMedium
                      ?.copyWith(color: context.palette.muted),),
              const Spacer(),
              if (onArchive != null)
                InkWell(
                  onTap: onArchive,
                  child: Icon(Icons.close,
                      size: 18, color: context.palette.muted,),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(activity.title, style: context.text.titleMedium),
          if (activity.reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(activity.reason,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),),
          ],
          if (lifts) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.palette.success.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up,
                      size: 16, color: context.palette.success,),
                  const SizedBox(width: 6),
                  Text(
                    'Lifts your mood by +${s.avgMoodDelta.toStringAsFixed(1)} '
                    '(${s.count}×)',
                    style: context.text.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Do it now',
                  variant: AppButtonVariant.tonal,
                  onPressed: onDo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Schedule',
                  variant: AppButtonVariant.secondary,
                  onPressed: onSchedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
