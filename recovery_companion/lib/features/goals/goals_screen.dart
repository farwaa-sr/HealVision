import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'model/goal_meta.dart';
import 'providers/goals_providers.dart';
import 'widgets/add_goal_sheet.dart';

/// Goals — recovery-oriented, small-and-achievable, tracked with warmth.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            tooltip: 'Add a goal',
            icon: const Icon(Icons.add),
            onPressed: () => AddGoalSheet.show(context),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) =>
            AppErrorView(onRetry: () => ref.invalidate(goalsProvider)),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: 'Set a small goal',
              message:
                  'Goals give recovery direction — and they go beyond staying '
                  'sober. Health, relationships, sleep, money… start small.',
              actionLabel: 'Add a goal',
              onAction: () => AddGoalSheet.show(context),
            );
          }
          final active = goals.where((g) => !g.isComplete).toList();
          final done = goals.where((g) => g.isComplete).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              for (final g in active) ...[
                _GoalTile(progress: g),
                const SizedBox(height: 12),
              ],
              if (done.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Completed', style: context.text.titleMedium),
                const SizedBox(height: 12),
                for (final g in done) ...[
                  _GoalTile(progress: g),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 8),
              AppButton(
                label: 'Add another goal',
                variant: AppButtonVariant.secondary,
                icon: Icons.add,
                onPressed: () => AddGoalSheet.show(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.progress});

  final GoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final g = progress.goal;
    final category = GoalCategory.fromName(g.category);
    final complete = progress.isComplete;

    return AppCard(
      onTap: () => context.pushNamed(
        AppRoute.goalDetail.routeName,
        pathParameters: {'id': g.id.toString()},
      ),
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
              if (complete)
                Icon(Icons.check_circle, color: context.palette.success)
              else
                Icon(Icons.chevron_right, color: context.palette.muted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            g.title,
            style: context.text.titleMedium?.copyWith(
              decoration: complete ? TextDecoration.lineThrough : null,
              color: complete ? context.palette.muted : null,
            ),
          ),
          if (g.targetDate != null && !complete) ...[
            const SizedBox(height: 4),
            Text('By ${DateFormat('MMM d').format(g.targetDate!)}',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),),
          ],
          if (progress.totalSteps > 0 && !complete) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.progress,
                minHeight: 8,
                backgroundColor: context.palette.field,
              ),
            ),
            const SizedBox(height: 6),
            Text('${progress.doneSteps} of ${progress.totalSteps} steps',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),),
          ],
        ],
      ),
    );
  }
}
