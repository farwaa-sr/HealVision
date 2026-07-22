import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../data/local/database.dart';
import '../../notifications/providers/notification_providers.dart';
import '../model/activity_meta.dart';
import '../providers/activities_providers.dart';

/// Pick a date + time and schedule [activity] into the week.
Future<void> scheduleActivity(
  BuildContext context,
  WidgetRef ref,
  Activity activity,
) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: now.add(const Duration(days: 60)),
    helpText: 'When would you like to do it?',
  );
  if (date == null || !context.mounted) return;

  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 18, minute: 0),
    helpText: 'What time?',
  );
  if (time == null || !context.mounted) return;

  final when =
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
  await ref.read(activitiesRepositoryProvider).schedule(activity.id, when);
  // Set up its gentle reminder right away.
  await ref.read(notificationSchedulerProvider).rescheduleAll();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scheduled "${activity.title}". Nice planning.')),
    );
  }
}

/// A picker to choose an activity to schedule (used by the empty schedule tab).
class ActivityPicker extends ConsumerWidget {
  const ActivityPicker({super.key});

  static Future<Activity?> show(BuildContext context) {
    return showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ActivityPicker(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities =
        ref.watch(activitiesListProvider).valueOrNull ?? const <Activity>[];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text('Choose an activity', style: context.text.titleLarge),
          const SizedBox(height: 12),
          for (final a in activities)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(ActivityCategory.fromName(a.category).icon,
                  color: context.colors.primary,),
              title: Text(a.title),
              onTap: () => Navigator.of(context).pop(a),
            ),
        ],
      ),
    );
  }
}
