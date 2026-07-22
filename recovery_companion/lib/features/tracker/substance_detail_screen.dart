import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/progress_ring.dart';
import 'model/tracker_models.dart';
import 'providers/tracker_providers.dart';
import 'widgets/history_timeline.dart';
import 'widgets/milestone_grid.dart';
import 'widgets/relapse_sheet.dart';
import 'widgets/supportive_next_step_sheet.dart';

/// Full view of one substance: honored totals, milestone ladder, a warm slip
/// action, and the calm history timeline.
class SubstanceDetailScreen extends ConsumerWidget {
  const SubstanceDetailScreen({super.key, required this.substanceId});

  final int substanceId;

  Future<void> _logSlip(
      BuildContext context, WidgetRef ref, SubstanceProgress p,) async {
    final draft = await RelapseSheet.show(context, p.name);
    if (draft == null || !context.mounted) return;
    await ref.read(soberTrackerRepositoryProvider).logRelapse(
          substanceId: p.id,
          trigger: draft.trigger,
          feeling: draft.feeling,
          situation: draft.situation,
          learning: draft.learning,
        );
    if (context.mounted) await SupportiveNextStepSheet.show(context);
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, SubstanceProgress p,) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop tracking?'),
        content: Text(
          'This removes "${p.name}" and its history from your journey. This '
          "can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(soberTrackerRepositoryProvider).deleteSubstance(p.id);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(substanceProgressProvider);

    return progressAsync.when(
      loading: () =>
          const Scaffold(body: LoadingIndicator(message: 'Loading…')),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: AppErrorView(
          onRetry: () => ref.invalidate(substanceProgressProvider),
        ),
      ),
      data: (list) {
        SubstanceProgress? p;
        for (final item in list) {
          if (item.id == substanceId) p = item;
        }
        if (p == null) {
          // Removed while open — go back gracefully.
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This item is no longer here.')),
          );
        }
        return _DetailView(
          progress: p,
          onLogSlip: () => _logSlip(context, ref, p!),
          onDelete: () => _confirmDelete(context, ref, p!),
        );
      },
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.progress,
    required this.onLogSlip,
    required this.onDelete,
  });

  final SubstanceProgress progress;
  final VoidCallback onLogSlip;
  final VoidCallback onDelete;

  String _healthNote(int days) {
    if (days >= 90) return 'Deep, systemic healing is well underway by now.';
    if (days >= 30) return 'Energy, sleep, and mood often lift around this point.';
    if (days >= 7) return 'Sleep and hydration are rebalancing.';
    if (days >= 1) return 'Your body has already started to recover.';
    return 'Recovery begins the moment you stop.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = progress;
    final timeline = ref.watch(substanceTimelineProvider(p.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Stop tracking')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Current streak centerpiece.
          Center(
            child: ProgressRing(
              value: p.progressToNext,
              size: 176,
              strokeWidth: 13,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${p.currentDays}',
                      style: context.text.displaySmall?.copyWith(
                          fontSize: 48, height: 1, fontWeight: FontWeight.w800,),),
                  Text('days clean', style: context.text.titleMedium),
                  Text('${p.currentHours} hrs',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.palette.muted),),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Honored totals.
          AppCard(
            child: Column(
              children: [
                _row(context, 'Longest streak', '${p.longestDays} days'),
                _divider(context),
                _row(context, 'Total clean (all attempts)',
                    '${p.totalCleanDays} days',),
                _divider(context),
                _row(context, 'Attempts made', '${p.attemptsMade}'),
                _divider(context),
                _row(context, 'Slips logged', '${p.relapses}'),
                if (p.dailyCost > 0) ...[
                  _divider(context),
                  _row(
                    context,
                    'Money saved',
                    NumberFormat.simpleCurrency(decimalDigits: 0)
                        .format(p.moneySaved),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Gentle, non-clinical health note.
          AppCard(
            color: Color.alphaBlend(
              context.palette.success.withValues(alpha: 0.14),
              context.palette.surfaceElevated,
            ),
            child: Row(
              children: [
                Icon(Icons.favorite_outline, color: context.palette.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_healthNote(p.totalCleanDays),
                      style: context.text.bodyMedium,),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Milestones', style: context.text.titleMedium),
          const SizedBox(height: 12),
          MilestoneGrid(progress: p),
          const SizedBox(height: 24),

          AppButton(
            label: 'Log a slip',
            variant: AppButtonVariant.tonal,
            icon: Icons.spa_outlined,
            onPressed: onLogSlip,
          ),
          const SizedBox(height: 28),

          Text('Your journey', style: context.text.titleMedium),
          const SizedBox(height: 12),
          timeline.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingIndicator(),
            ),
            error: (_, __) => Text('Could not load history.',
                style: context.text.bodyMedium,),
            data: (entries) => HistoryTimeline(entries: entries),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.text.bodyMedium),
          Text(value,
              style:
                  context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 1, color: context.colors.outlineVariant);
}
