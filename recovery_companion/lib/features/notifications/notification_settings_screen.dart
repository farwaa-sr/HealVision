import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_card.dart';
import 'logic/notification_copy.dart';
import 'model/notification_settings.dart';
import 'providers/notification_providers.dart';

/// A calm, granular control panel for supportive notifications. Every switch,
/// time, and quiet-hours change saves instantly and reschedules. Each category
/// shows a live preview of exactly how its messages read.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Could not load settings.')),
        data: (settings) => _Body(settings: settings),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.settings});

  final NotificationSettings settings;

  void _save(WidgetRef ref, NotificationSettings next) {
    ref.read(notificationSettingsControllerProvider.notifier).apply(next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permitted =
        ref.watch(notificationsPermittedProvider).valueOrNull ?? true;
    final on = settings.masterEnabled;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        // Warm framing.
        Text(
          'Gentle, well-timed, and always yours to shape. Nothing here is ever '
          'pushy — turn off anything, any time.',
          style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
        ),
        const SizedBox(height: 16),

        // Master switch.
        AppCard(
          child: Row(
            children: [
              Icon(Icons.notifications_none_rounded,
                  color: context.colors.primary,),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Allow notifications', style: context.text.titleMedium),
                    Text(
                      'The main switch for everything below.',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.palette.muted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: on,
                onChanged: (v) => _save(ref, settings.copyWith(masterEnabled: v)),
              ),
            ],
          ),
        ),

        if (on && !permitted) ...[
          const SizedBox(height: 12),
          _PermissionBanner(
            onAllow: () async {
              await ref
                  .read(notificationSettingsControllerProvider.notifier)
                  .requestPermissions();
              ref.invalidate(notificationsPermittedProvider);
            },
          ),
        ],

        if (on) ...[
          const SizedBox(height: 12),
          _PauseControl(
            settings: settings,
            onPauseUntil: (until) =>
                _save(ref, settings.copyWith(pausedUntil: until)),
            onResume: () => _save(ref, settings.copyWith(pausedUntil: null)),
          ),
          const SizedBox(height: 20),

          _CategoryCard(
            category: NotifCategory.checkIn,
            enabled: settings.checkInEnabled,
            onToggle: (v) => _save(ref, settings.copyWith(checkInEnabled: v)),
            settings: settings,
            extra: _TimeRow(
              label: 'Remind me at',
              time: settings.checkInTime,
              inQuiet: settings.isQuiet(
                  settings.checkInTime.hour * 60 + settings.checkInTime.minute,),
              onPick: (t) => _save(ref, settings.copyWith(checkInTime: t)),
            ),
          ),

          _CategoryCard(
            category: NotifCategory.activities,
            enabled: settings.activitiesEnabled,
            onToggle: (v) => _save(ref, settings.copyWith(activitiesEnabled: v)),
            settings: settings,
            extra: _LeadRow(
              minutes: settings.activityLeadMinutes,
              onPick: (m) =>
                  _save(ref, settings.copyWith(activityLeadMinutes: m)),
            ),
          ),

          _CategoryCard(
            category: NotifCategory.riskNudges,
            enabled: settings.riskNudgesEnabled,
            onToggle: (v) => _save(ref, settings.copyWith(riskNudgesEnabled: v)),
            settings: settings,
            note:
                'Timed from patterns in your own check-ins — only once there’s '
                'enough to go on. Until then, these stay quiet.',
          ),

          _CategoryCard(
            category: NotifCategory.milestones,
            enabled: settings.milestonesEnabled,
            onToggle: (v) => _save(ref, settings.copyWith(milestonesEnabled: v)),
            settings: settings,
          ),

          _CategoryCard(
            category: NotifCategory.motivation,
            enabled: settings.motivationEnabled,
            onToggle: (v) => _save(ref, settings.copyWith(motivationEnabled: v)),
            settings: settings,
            extra: _TimeRow(
              label: 'Send it at',
              time: settings.motivationTime,
              inQuiet: settings.isQuiet(settings.motivationTime.hour * 60 +
                  settings.motivationTime.minute,),
              onPick: (t) => _save(ref, settings.copyWith(motivationTime: t)),
            ),
          ),

          const SizedBox(height: 8),
          _QuietHoursCard(
            settings: settings,
            onToggle: (v) => _save(ref, settings.copyWith(quietHoursEnabled: v)),
            onStart: (t) => _save(ref, settings.copyWith(quietStart: t)),
            onEnd: (t) => _save(ref, settings.copyWith(quietEnd: t)),
          ),
        ],
      ],
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onAllow});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: Color.alphaBlend(
        context.palette.accent.withValues(alpha: 0.16),
        context.palette.surfaceElevated,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.palette.onAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifications are turned off at the system level, so nothing can '
              'come through yet.',
              style: context.text.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: onAllow, child: const Text('Allow')),
        ],
      ),
    );
  }
}

/// A gentle "snooze everything" without losing any settings. Pauses suppress
/// all categories until the chosen moment, then things resume on their own.
class _PauseControl extends StatelessWidget {
  const _PauseControl({
    required this.settings,
    required this.onPauseUntil,
    required this.onResume,
  });

  final NotificationSettings settings;
  final ValueChanged<DateTime> onPauseUntil;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    if (settings.isPausedAt(now)) {
      return AppCard(
        color: Color.alphaBlend(
          context.colors.primary.withValues(alpha: 0.08),
          context.palette.surfaceElevated,
        ),
        child: Row(
          children: [
            Icon(Icons.snooze_outlined, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Snoozed', style: context.text.titleMedium),
                  Text(
                    'Resuming ${DateFormat('EEE d MMM, h:mm a').format(settings.pausedUntil!)}',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onResume, child: const Text('Resume now')),
          ],
        ),
      );
    }

    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    return Row(
      children: [
        Icon(Icons.snooze_outlined, size: 18, color: context.palette.muted),
        const SizedBox(width: 8),
        Text('Need a break?',
            style: context.text.bodyMedium
                ?.copyWith(color: context.palette.muted),),
        const Spacer(),
        TextButton(
          onPressed: () => onPauseUntil(tomorrow),
          child: const Text('Pause today'),
        ),
        TextButton(
          onPressed: () => onPauseUntil(now.add(const Duration(days: 7))),
          child: const Text('For a week'),
        ),
      ],
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({
    required this.category,
    required this.enabled,
    required this.onToggle,
    required this.settings,
    this.extra,
    this.note,
  });

  final NotifCategory category;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final NotificationSettings settings;
  final Widget? extra;
  final String? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sample = NotificationCopy.sampleFor(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.label, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        category.blurb,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.palette.muted),
                      ),
                    ],
                  ),
                ),
                Switch(value: enabled, onChanged: onToggle),
              ],
            ),
            if (enabled) ...[
              if (note != null) ...[
                const SizedBox(height: 10),
                Text(
                  note!,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.palette.muted),
                ),
              ],
              if (extra != null) ...[
                const SizedBox(height: 12),
                extra!,
              ],
              const SizedBox(height: 14),
              _NotificationPreview(content: sample),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => ref
                      .read(notificationSettingsControllerProvider.notifier)
                      .sendTest(category),
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: const Text('Send a test'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A little mock of an OS notification so the user sees the tone before opting in.
class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview({required this.content});

  final NotifContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: context.colors.primary.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.spa_outlined,
                size: 20, color: context.colors.primary,),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        content.title,
                        style: context.text.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      'now',
                      style: context.text.labelSmall
                          ?.copyWith(color: context.palette.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(content.body, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onPick,
    this.inQuiet = false,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPick;
  final bool inQuiet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                final picked =
                    await showTimePicker(context: context, initialTime: time);
                if (picked != null) onPick(picked);
              },
              icon: const Icon(Icons.schedule, size: 18),
              label: Text(time.format(context)),
            ),
          ],
        ),
        if (inQuiet) ...[
          const SizedBox(height: 6),
          Text(
            'This falls inside your quiet hours, so it won’t be sent. Pick a '
            'time outside them, or adjust quiet hours below.',
            style:
                context.text.bodySmall?.copyWith(color: context.palette.support),
          ),
        ],
      ],
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.minutes, required this.onPick});

  final int minutes;
  final ValueChanged<int> onPick;

  static const _options = [10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Remind me',
            style: context.text.bodyMedium
                ?.copyWith(color: context.palette.muted),),
        const Spacer(),
        DropdownButton<int>(
          value: _options.contains(minutes) ? minutes : 30,
          underline: const SizedBox.shrink(),
          items: [
            for (final m in _options)
              DropdownMenuItem(
                value: m,
                child: Text('$m min before'),
              ),
          ],
          onChanged: (m) => onPick(m ?? minutes),
        ),
      ],
    );
  }
}

class _QuietHoursCard extends StatelessWidget {
  const _QuietHoursCard({
    required this.settings,
    required this.onToggle,
    required this.onStart,
    required this.onEnd,
  });

  final NotificationSettings settings;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onStart;
  final ValueChanged<TimeOfDay> onEnd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dark_mode_outlined, color: context.colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quiet hours', style: context.text.titleMedium),
                    Text(
                      'Nothing will ever arrive during this window.',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.palette.muted),
                    ),
                  ],
                ),
              ),
              Switch(value: settings.quietHoursEnabled, onChanged: onToggle),
            ],
          ),
          if (settings.quietHoursEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniTime(
                    label: 'From',
                    time: settings.quietStart,
                    onPick: onStart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniTime(
                    label: 'Until',
                    time: settings.quietEnd,
                    onPick: onEnd,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniTime extends StatelessWidget {
  const _MiniTime({
    required this.label,
    required this.time,
    required this.onPick,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.text.labelSmall
                ?.copyWith(color: context.palette.muted),),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: () async {
            final picked =
                await showTimePicker(context: context, initialTime: time);
            if (picked != null) onPick(picked);
          },
          child: Text(time.format(context)),
        ),
      ],
    );
  }
}
