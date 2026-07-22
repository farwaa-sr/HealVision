import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/mood_selector.dart';
import '../providers/activities_providers.dart';

/// The feedback loop: mood before → do the activity → mood after. One tap each.
/// This is what teaches the app which activities actually work for this person.
class DoActivitySheet extends ConsumerStatefulWidget {
  const DoActivitySheet({super.key, required this.activity});

  final Activity activity;

  static Future<void> show(BuildContext context, Activity activity) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DoActivitySheet(activity: activity),
    );
  }

  @override
  ConsumerState<DoActivitySheet> createState() => _DoActivitySheetState();
}

enum _Step { before, doing, after, done }

class _DoActivitySheetState extends ConsumerState<DoActivitySheet> {
  _Step _step = _Step.before;
  Mood? _before;
  Mood? _after;

  int _num(Mood m) => 5 - m.index; // great→5 … struggling→1

  Future<void> _save() async {
    await ref.read(activitiesRepositoryProvider).logActivity(
          activityId: widget.activity.id,
          moodBefore: _num(_before!),
          moodAfter: _num(_after!),
        );
    unawaited(Haptics.success());
    if (mounted) setState(() => _step = _Step.done);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: switch (_step) {
          _Step.before => _before_(context),
          _Step.doing => _doing(context),
          _Step.after => _after_(context),
          _Step.done => _done(context),
        },
      ),
    );
  }

  List<Widget> _before_(BuildContext context) => [
        Text(widget.activity.title, style: context.text.titleLarge),
        const SizedBox(height: 4),
        Text('First — how\'s your mood right now?',
            style: context.text.bodyMedium
                ?.copyWith(color: context.palette.muted),),
        const SizedBox(height: 16),
        MoodSelector(value: _before, onChanged: (m) => setState(() => _before = m)),
        const SizedBox(height: 24),
        AppButton(
          label: 'Start',
          onPressed:
              _before == null ? null : () => setState(() => _step = _Step.doing),
        ),
      ];

  List<Widget> _doing(BuildContext context) => [
        Center(
          child: Column(
            children: [
              Icon(Icons.spa_outlined, size: 48, color: context.colors.primary),
              const SizedBox(height: 16),
              Text('Enjoy it', style: context.text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                "Take your time with ${widget.activity.title.toLowerCase()}. "
                'Come back when you\'re done.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: "I'm done",
          onPressed: () => setState(() => _step = _Step.after),
        ),
      ];

  List<Widget> _after_(BuildContext context) => [
        Text('Nicely done', style: context.text.titleLarge),
        const SizedBox(height: 4),
        Text('How do you feel now?',
            style: context.text.bodyMedium
                ?.copyWith(color: context.palette.muted),),
        const SizedBox(height: 16),
        MoodSelector(value: _after, onChanged: (m) => setState(() => _after = m)),
        const SizedBox(height: 24),
        AppButton(
          label: 'Save',
          onPressed: _after == null ? null : _save,
        ),
      ];

  List<Widget> _done(BuildContext context) {
    final delta = _num(_after!) - _num(_before!);
    final message = delta > 0
        ? 'Your mood lifted. Noticing what helps is how you build a menu of '
            'things that actually work for you.'
        : delta == 0
            ? 'Thanks for showing up for yourself — that matters even when the '
                'needle doesn\'t move.'
            : 'Some things settle us even when they don\'t lift us. You still '
                'chose care over the urge.';
    return [
      Center(
        child: Column(
          children: [
            Icon(
              delta > 0 ? Icons.sentiment_very_satisfied : Icons.check_circle,
              size: 48,
              color: context.palette.success,
            ),
            const SizedBox(height: 16),
            Text(delta > 0 ? 'Mood +$delta' : 'Logged',
                style: context.text.headlineSmall,),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),),
          ],
        ),
      ),
      const SizedBox(height: 24),
      AppButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
    ];
  }
}
