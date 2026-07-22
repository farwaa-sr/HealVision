import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../checkin/providers/checkin_providers.dart';
import 'model/insight.dart';
import 'widgets/trend_chart.dart';

/// The insights view — the user's own patterns, surfaced gently. Their mirror,
/// never a scoreboard. All detection happens on-device.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(recentCheckInsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your patterns')),
      body: checkInsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) =>
            const Center(child: Text('Could not load your patterns.')),
        data: (checkIns) {
          if (checkIns.length < 3) {
            return const EmptyState(
              icon: Icons.insights_outlined,
              title: 'Your patterns will appear here',
              message:
                  'Check in for a few days and gentle patterns will start to '
                  'show — what lifts you, and when things get harder. This is '
                  'just for you.',
            );
          }

          final dates = checkIns.map((c) => c.createdAt).toList();
          final mood = checkIns.map((c) => c.mood.toDouble()).toList();
          final craving =
              checkIns.map((c) => c.cravingLevel.toDouble()).toList();
          final insights = ref.watch(insightsProvider);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Text(
                'This is your mirror, not a scoreboard — a gentle way to notice '
                'what helps you.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),
              ),
              const SizedBox(height: 20),

              _ChartCard(
                title: 'Mood',
                subtitle: 'Higher is brighter',
                child: TrendChart(
                  values: mood,
                  dates: dates,
                  min: 1,
                  max: 5,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Craving level',
                subtitle: 'Lower is calmer',
                child: TrendChart(
                  values: craving,
                  dates: dates,
                  min: 0,
                  max: 10,
                  color: context.palette.support,
                ),
              ),
              const SizedBox(height: 24),

              Text('Gentle heads-ups', style: context.text.titleMedium),
              const SizedBox(height: 12),
              if (insights.isEmpty)
                AppCard(
                  child: Text(
                    "No clear patterns yet — and that's completely fine. Keep "
                    'checking in, and anything useful will surface here gently.',
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.palette.muted),
                  ),
                )
              else
                for (final insight in insights) ...[
                  _InsightCard(insight: insight),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(title, style: context.text.titleMedium),
              const SizedBox(width: 8),
              Text(subtitle,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.palette.muted),),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(insight.icon, color: context.colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.title, style: context.text.titleMedium),
                    const SizedBox(height: 4),
                    Text(insight.body,
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.palette.muted),),
                  ],
                ),
              ),
            ],
          ),
          if (insight.action != InsightAction.none) ...[
            const SizedBox(height: 12),
            AppButton(
              label: insight.action == InsightAction.setReminder
                  ? 'Plan ahead for these times'
                  : 'Plan a replacement activity',
              variant: AppButtonVariant.tonal,
              icon: Icons.event_available_outlined,
              onPressed: () => context.goNamed(AppRoute.activities.routeName),
            ),
          ],
        ],
      ),
    );
  }
}
