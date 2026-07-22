import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/haptics.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/sos_button.dart';
import '../goals/model/goal_meta.dart';
import '../goals/providers/goals_providers.dart';
import '../motivation/providers/motivation_providers.dart';
import 'model/dashboard_data.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/dashboard_skeleton.dart';
import 'widgets/mood_sparkline.dart';

/// Home — a calm, at-a-glance view: greeting, sober-time centerpiece, quick
/// stats, an always-reachable SOS card, today's plan, a daily lift, and a
/// gentle check-in nudge.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardControllerProvider);
    Future<void> refresh() =>
        ref.read(dashboardControllerProvider.notifier).refresh();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: async.when(
            loading: () => const DashboardSkeleton(),
            error: (_, __) => ListView(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  child: AppErrorView(onRetry: refresh),
                ),
              ],
            ),
            data: (data) => _DashboardBody(
              data: data,
              onToggle: (id) => ref
                  .read(dashboardControllerProvider.notifier)
                  .toggleTodayItem(id),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.onToggle});

  final DashboardData data;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        _Greeting(name: data.userName),
        const SizedBox(height: 24),
        _SoberCenterpiece(data: data),
        const SizedBox(height: 24),
        const _SosCard(),
        const SizedBox(height: 24),
        _QuickStats(data: data),
        const SizedBox(height: 28),
        _TodaySection(items: data.today, onToggle: onToggle),
        const SizedBox(height: 24),
        const _GoalsThisWeek(),
        const SizedBox(height: 24),
        const _MotivationCard(),
        if (!data.checkinDoneToday) ...[
          const SizedBox(height: 24),
          const _CheckinPrompt(),
        ],
      ],
    );
  }
}

// 1. Greeting — adapts to time of day, no hype.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  String get _timeOfDay {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$_timeOfDay, $name', style: context.text.headlineMedium),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
        ),
      ],
    );
  }
}

// 2. Sober-time centerpiece — the focal point; tap to open the full tracker.
class _SoberCenterpiece extends StatelessWidget {
  const _SoberCenterpiece({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Haptics.tap();
          context.goNamed(AppRoute.progress.routeName);
        },
        child: ProgressRing(
          value: data.milestoneProgress,
          size: 190,
          strokeWidth: 14,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${data.soberDays}',
                style: context.text.displaySmall
                    ?.copyWith(fontSize: 52, height: 1, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text('days clean', style: context.text.titleMedium),
              const SizedBox(height: 6),
              Text(
                '${data.soberHours} hrs · tap for details',
                style:
                    context.text.bodySmall?.copyWith(color: context.palette.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. Quick stats — money saved, wellbeing, 7-day mood trend.
class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final money =
        NumberFormat.simpleCurrency(decimalDigits: 0).format(data.moneySaved);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StatCard(
            label: 'saved',
            child: Text(money,
                style: context.text.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'wellbeing',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${data.wellbeing}',
                    style: context.text.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),),
                Text(' /100',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'mood · 7d',
            child: MoodSparkline(values: data.moodTrend),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.child, required this.label});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28, child: Align(alignment: Alignment.centerLeft, child: child)),
          const SizedBox(height: 8),
          Text(label,
              style:
                  context.text.bodySmall?.copyWith(color: context.palette.muted),),
        ],
      ),
    );
  }
}

// 4. SOS card — large, near the top, never more than a glance away.
class _SosCard extends StatelessWidget {
  const _SosCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: context.palette.support, size: 20),
              const SizedBox(width: 8),
              Text('Craving hitting?', style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "You don't have to ride it out alone. It will pass.",
            style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: SosButton(
              label: "I'm craving — help me now",
              onPressed: () => context.pushNamed(AppRoute.sos.routeName),
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Today — scheduled activities and goals due today, with quick check-off.
class _TodaySection extends StatelessWidget {
  const _TodaySection({required this.items, required this.onToggle});

  final List<TodayItem> items;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today', style: context.text.titleMedium),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Nothing scheduled — and that's okay. Add something when "
                    'you feel ready.',
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.palette.muted),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 52,
                          color: context.colors.outlineVariant,
                        ),
                      _TodayRow(item: items[i], onToggle: onToggle),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.item, required this.onToggle});

  final TodayItem item;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final done = item.done;
    final typeIcon = item.type == TodayItemType.goal
        ? Icons.flag_outlined
        : Icons.spa_outlined;

    return InkWell(
      onTap: () {
        Haptics.selection();
        onToggle(item.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.duration(context, AppMotion.fast),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? context.colors.primary : Colors.transparent,
                border: Border.all(
                  color: done
                      ? context.colors.primary
                      : context.colors.outlineVariant,
                  width: 2,
                ),
              ),
              child: done
                  ? Icon(Icons.check, size: 16, color: context.colors.onPrimary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.text.bodyLarge?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? context.palette.muted : null,
                    ),
                  ),
                  if (item.time != null)
                    Text(item.time!,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.palette.muted),),
                ],
              ),
            ),
            Icon(typeIcon, size: 18, color: context.palette.muted),
          ],
        ),
      ),
    );
  }
}

// 6. Daily motivation — a grounded, mood-matched message from the library.
class _MotivationCard extends ConsumerWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(dailyQuoteProvider);
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoute.motivation.routeName),
      child: AppCard(
        color: Color.alphaBlend(
          context.palette.accent.withValues(alpha: 0.16),
          context.palette.surfaceElevated,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(quote.text, style: context.text.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

// This week's goals — surfaced from real goal data.
class _GoalsThisWeek extends ConsumerWidget {
  const _GoalsThisWeek();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeGoalsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('This week', style: context.text.titleMedium),
            const Spacer(),
            TextButton(
              onPressed: () => context.goNamed(AppRoute.goals.routeName),
              child: const Text('All goals'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (active.isEmpty)
          AppCard(
            onTap: () => context.pushNamed(AppRoute.goals.routeName),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: context.colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Set a small goal to work toward this week.',
                      style: context.text.bodyMedium,),
                ),
                Icon(Icons.chevron_right, color: context.palette.muted),
              ],
            ),
          )
        else
          for (final g in active.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => context.pushNamed(
                  AppRoute.goalDetail.routeName,
                  pathParameters: {'id': g.goal.id.toString()},
                ),
                child: Row(
                  children: [
                    Icon(GoalCategory.fromName(g.goal.category).icon,
                        size: 20, color: context.colors.primary,),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.goal.title, style: context.text.titleMedium),
                          if (g.totalSteps > 0) ...[
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: g.progress,
                                minHeight: 6,
                                backgroundColor: context.palette.field,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

// 7. Gentle check-in nudge (only when not yet done today).
class _CheckinPrompt extends StatelessWidget {
  const _CheckinPrompt();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.pushNamed(AppRoute.checkin.routeName),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primaryContainer,
            ),
            child: Icon(Icons.wb_sunny_outlined, color: context.colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Take a moment to check in',
                    style: context.text.titleMedium,),
                const SizedBox(height: 2),
                Text("A quick note on how today's going.",
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.palette.muted),
        ],
      ),
    );
  }
}
