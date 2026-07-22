import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'model/tracker_models.dart';
import 'providers/tracker_providers.dart';
import 'widgets/add_substance_sheet.dart';
import 'widgets/milestone_celebration.dart';
import 'widgets/relapse_sheet.dart';
import 'widgets/substance_card.dart';
import 'widgets/supportive_next_step_sheet.dart';

/// Progress — the sober journey. Lists each tracked substance with honored
/// totals, quietly celebrates milestones, and handles slips with warmth.
class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  bool _celebrating = false;

  Future<void> _maybeCelebrate(List<SubstanceProgress> list) async {
    if (_celebrating) return;
    for (final p in list) {
      if (p.currentReachedIndex > p.celebratedMilestoneIndex) {
        _celebrating = true;
        // Persist first so the re-emitted stream doesn't celebrate twice.
        await ref
            .read(soberTrackerRepositoryProvider)
            .setCelebratedIndex(p.id, p.currentReachedIndex);
        if (mounted) {
          await showMilestoneCelebration(
              context, kMilestones[p.currentReachedIndex],);
        }
        _celebrating = false;
        break;
      }
    }
  }

  Future<void> _logSlip(SubstanceProgress p) async {
    final draft = await RelapseSheet.show(context, p.name);
    if (draft == null) return; // backed out entirely
    await ref.read(soberTrackerRepositoryProvider).logRelapse(
          substanceId: p.id,
          trigger: draft.trigger,
          feeling: draft.feeling,
          situation: draft.situation,
          learning: draft.learning,
        );
    if (mounted) await SupportiveNextStepSheet.show(context);
  }

  void _openDetail(SubstanceProgress p) {
    context.pushNamed(
      AppRoute.substanceDetail.routeName,
      pathParameters: {'id': p.id.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(substanceProgressProvider, (_, next) {
      next.whenData(_maybeCelebrate);
    });

    final async = ref.watch(substanceProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your journey'),
        actions: [
          IconButton(
            tooltip: 'Your patterns',
            onPressed: () => context.pushNamed(AppRoute.insights.routeName),
            icon: const Icon(Icons.insights_outlined),
          ),
          IconButton(
            tooltip: 'Track something',
            onPressed: () => AddSubstanceSheet.show(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => AppErrorView(
          onRetry: () => ref.invalidate(substanceProgressProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.eco_outlined,
              title: 'Begin your journey',
              message:
                  'Track your clean time from whatever you\'re recovering from. '
                  'Every day counts, and nothing you build is ever erased.',
              actionLabel: 'Start tracking',
              onAction: () => AddSubstanceSheet.show(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              for (final p in list) ...[
                SubstanceCard(
                  progress: p,
                  onTap: () => _openDetail(p),
                  onLogSlip: () => _logSlip(p),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              AppButton(
                label: 'Track something else',
                variant: AppButtonVariant.secondary,
                icon: Icons.add,
                onPressed: () => AddSubstanceSheet.show(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
