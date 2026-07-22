import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../model/tracker_models.dart';

/// One substance on the tracker list — current streak, honored totals, next
/// milestone, and a gentle "log a slip" action.
class SubstanceCard extends StatelessWidget {
  const SubstanceCard({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onLogSlip,
  });

  final SubstanceProgress progress;
  final VoidCallback onTap;
  final VoidCallback onLogSlip;

  @override
  Widget build(BuildContext context) {
    final next = progress.nextMilestone;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(progress.name, style: context.text.titleLarge),
              ),
              Icon(Icons.chevron_right, color: context.palette.muted),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ProgressRing(
                value: progress.progressToNext,
                size: 92,
                strokeWidth: 9,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${progress.currentDays}',
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),),
                    Text('days',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.palette.muted),),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stat(context, 'Total clean',
                        '${progress.totalCleanDays} days',),
                    _stat(context, 'Longest', '${progress.longestDays} days'),
                    _stat(context, 'Attempts', '${progress.attemptsMade}'),
                    if (progress.dailyCost > 0)
                      _stat(
                        context,
                        'Saved',
                        NumberFormat.simpleCurrency(decimalDigits: 0)
                            .format(progress.moneySaved),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 12),
            Text('Next milestone: ${next.label}',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),),
          ],
          const SizedBox(height: 14),
          AppButton(
            label: 'Log a slip',
            variant: AppButtonVariant.tonal,
            icon: Icons.spa_outlined,
            onPressed: onLogSlip,
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: context.text.bodySmall
                  ?.copyWith(color: context.palette.muted),),
          Text(value,
              style: context.text.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),),
        ],
      ),
    );
  }
}
