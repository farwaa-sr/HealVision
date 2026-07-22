import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme_ext.dart';
import '../../data/local/database.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../checkin/providers/checkin_providers.dart';
import '../insights/model/insight.dart';
import 'data/activities_repository.dart';
import 'model/activity_meta.dart';
import 'providers/activities_providers.dart';
import 'widgets/activity_card.dart';
import 'widgets/activity_onboarding.dart';
import 'widgets/add_custom_sheet.dart';
import 'widgets/do_activity_sheet.dart';
import 'widgets/schedule_activity.dart';

/// Activities — behavioral activation. Personalized "For You" suggestions, a
/// full library to browse and extend, and a weekly schedule with proactive
/// heads-ups at higher-risk times.
class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seeded = ref.watch(ensureSeededProvider);
    final needsAsync = ref.watch(savedNeedsProvider);

    if (seeded.isLoading || needsAsync.isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    final needs = needsAsync.valueOrNull ?? const <Need>[];
    if (needs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activities')),
        body: const ActivityOnboarding(),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Library'),
              Tab(text: 'Schedule'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ForYouTab(),
            _LibraryTab(),
            _ScheduleTab(),
          ],
        ),
      ),
    );
  }
}

Future<void> _doNow(BuildContext context, Activity a) =>
    DoActivitySheet.show(context, a);

// --- For You ---
class _ForYouTab extends ConsumerWidget {
  const _ForYouTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = ref.watch(recommendedActivitiesProvider);
    final stats =
        ref.watch(activityStatsProvider).valueOrNull ?? const <int, ActivityStat>{};

    if (recommended.isEmpty) {
      return const LoadingIndicator();
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text(
          'Matched to what you told us — and re-ranked over time by what '
          'actually lifts your mood.',
          style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
        ),
        const SizedBox(height: 16),
        for (final a in recommended) ...[
          ActivityCard(
            activity: a,
            stat: stats[a.id],
            onDo: () => _doNow(context, a),
            onSchedule: () => scheduleActivity(context, ref, a),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// --- Library ---
class _LibraryTab extends ConsumerWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities =
        ref.watch(activitiesListProvider).valueOrNull ?? const <Activity>[];
    final stats =
        ref.watch(activityStatsProvider).valueOrNull ?? const <int, ActivityStat>{};

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        AppButton(
          label: 'Add your own',
          variant: AppButtonVariant.secondary,
          icon: Icons.add,
          onPressed: () => AddCustomSheet.show(context),
        ),
        const SizedBox(height: 16),
        for (final category in ActivityCategory.values) ...[
          Builder(
            builder: (context) {
              final inCat =
                  activities.where((a) => a.category == category.name).toList();
              if (inCat.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(category.icon,
                          size: 18, color: context.palette.muted,),
                      const SizedBox(width: 8),
                      Text(category.label, style: context.text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final a in inCat) ...[
                    ActivityCard(
                      activity: a,
                      stat: stats[a.id],
                      onDo: () => _doNow(context, a),
                      onSchedule: () => scheduleActivity(context, ref, a),
                      onArchive: a.isCustom
                          ? () => ref
                              .read(activitiesRepositoryProvider)
                              .archiveActivity(a.id)
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

// --- Schedule ---
class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab();

  Insight? _riskInsight(List<Insight> insights) {
    for (final i in insights) {
      if (i.action == InsightAction.planActivity) return i;
    }
    return null;
  }

  Future<void> _scheduleSomething(BuildContext context, WidgetRef ref) async {
    final activity = await ActivityPicker.show(context);
    if (activity == null || !context.mounted) return;
    await scheduleActivity(context, ref, activity);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming =
        ref.watch(upcomingScheduleProvider).valueOrNull ?? const <ScheduledEntry>[];
    final risk = _riskInsight(ref.watch(insightsProvider));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        if (risk != null) ...[
          AppCard(
            color: Color.alphaBlend(
              context.palette.accent.withValues(alpha: 0.16),
              context.palette.surfaceElevated,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined,
                        color: context.colors.primary,),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('A gentle heads-up',
                          style: context.text.titleMedium,),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(risk.body, style: context.text.bodyMedium),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Plan something for then',
                  variant: AppButtonVariant.tonal,
                  onPressed: () => _scheduleSomething(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        AppButton(
          label: 'Schedule an activity',
          icon: Icons.add,
          onPressed: () => _scheduleSomething(context, ref),
        ),
        const SizedBox(height: 20),
        if (upcoming.isEmpty)
          const SizedBox(
            height: 220,
            child: EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Nothing scheduled yet',
              message:
                  'Planning something rewarding ahead of a tough time is one of '
                  'the most effective things you can do.',
            ),
          )
        else
          for (final entry in upcoming) ...[
            _ScheduledCard(entry: entry),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ScheduledCard extends ConsumerWidget {
  const _ScheduledCard({required this.entry});

  final ScheduledEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final when = entry.scheduled.scheduledFor;
    final label = DateFormat('EEE, MMM d · h:mm a').format(when);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entry.activity.title,
                    style: context.text.titleMedium,),
              ),
              InkWell(
                onTap: () => ref
                    .read(activitiesRepositoryProvider)
                    .deleteScheduled(entry.scheduled.id),
                child:
                    Icon(Icons.close, size: 18, color: context.palette.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style:
                  context.text.bodySmall?.copyWith(color: context.palette.muted),),
          const SizedBox(height: 12),
          AppButton(
            label: 'Do it now',
            variant: AppButtonVariant.tonal,
            onPressed: () async {
              await ref
                  .read(activitiesRepositoryProvider)
                  .markScheduledDone(entry.scheduled.id);
              if (context.mounted) {
                await DoActivitySheet.show(context, entry.activity);
              }
            },
          ),
        ],
      ),
    );
  }
}
