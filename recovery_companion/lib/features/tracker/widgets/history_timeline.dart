import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme_ext.dart';
import '../model/tracker_models.dart';

/// A calm vertical history of the journey — fresh starts and slips, side by
/// side, with any reflections shown gently. Framed as continuity, not failure.
class HistoryTimeline extends StatelessWidget {
  const HistoryTimeline({super.key, required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text('Your journey will appear here as it unfolds.',
          style: context.text.bodyMedium?.copyWith(color: context.palette.muted),);
    }

    // The oldest "started" is the very beginning of tracking.
    DateTime? oldestStart;
    for (final e in entries) {
      if (e.kind == TimelineKind.started) {
        if (oldestStart == null || e.date.isBefore(oldestStart)) {
          oldestStart = e.date;
        }
      }
    }

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineTile(
            entry: entries[i],
            isFirst: i == 0,
            isLast: i == entries.length - 1,
            isBeginning: entries[i].kind == TimelineKind.started &&
                entries[i].date == oldestStart,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.isBeginning,
  });

  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final bool isBeginning;

  @override
  Widget build(BuildContext context) {
    final isSlip = entry.kind == TimelineKind.slip;
    final dotColor = isSlip ? context.palette.support : context.colors.primary;
    final lineColor = context.colors.outlineVariant;

    final title = isSlip
        ? 'A slip — and you kept going'
        : isBeginning
            ? 'Started tracking'
            : 'A fresh start';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 6,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(
                      color: context.theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy · h:mm a').format(entry.date),
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(title, style: context.text.titleMedium),
                  if (isSlip && entry.hasReflection) ...[
                    const SizedBox(height: 8),
                    _Reflection(entry: entry),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reflection extends StatelessWidget {
  const _Reflection({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    Widget line(String label, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: context.text.bodySmall,
            children: [
              TextSpan(
                text: '$label: ',
                style: TextStyle(
                  color: context.palette.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(color: context.colors.onSurface),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line('Trigger', entry.trigger),
          line('Feeling', entry.feeling),
          line('Situation', entry.situation),
          line('Next time', entry.learning),
        ],
      ),
    );
  }
}
