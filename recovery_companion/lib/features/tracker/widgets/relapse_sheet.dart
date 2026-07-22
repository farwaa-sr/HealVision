import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';

/// What the user optionally noted about a slip. Everything is nullable — the
/// whole reflection is skippable.
class RelapseDraft {
  const RelapseDraft({this.trigger, this.feeling, this.situation, this.learning});
  final String? trigger;
  final String? feeling;
  final String? situation;
  final String? learning;
}

/// Compassionate relapse logging. Framed with warmth — a slip is a data point
/// and a learning moment, never a failure. All reflection is optional.
class RelapseSheet extends StatefulWidget {
  const RelapseSheet({super.key, required this.substanceName});

  final String substanceName;

  /// Returns a [RelapseDraft] to log the slip, or null if the user backs out
  /// entirely (they can also log with no notes via "Skip the notes").
  static Future<RelapseDraft?> show(BuildContext context, String name) {
    return showModalBottomSheet<RelapseDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RelapseSheet(substanceName: name),
    );
  }

  @override
  State<RelapseSheet> createState() => _RelapseSheetState();
}

class _RelapseSheetState extends State<RelapseSheet> {
  static const _triggers = [
    'Stress',
    'Boredom',
    'Social',
    'Craving',
    'Conflict',
    'Tired',
    'Celebration',
    'Other',
  ];
  static const _feelings = ['Anxious', 'Sad', 'Angry', 'Lonely', 'Numb', 'Fine'];

  String? _trigger;
  String? _feeling;
  final _situation = TextEditingController();
  final _learning = TextEditingController();

  @override
  void dispose() {
    _situation.dispose();
    _learning.dispose();
    super.dispose();
  }

  RelapseDraft _draft() => RelapseDraft(
        trigger: _trigger,
        feeling: _feeling,
        situation: _situation.text.trim().isEmpty ? null : _situation.text.trim(),
        learning: _learning.text.trim().isEmpty ? null : _learning.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warm framing — never "you lost your streak".
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  context.palette.accent.withValues(alpha: 0.18),
                  context.palette.surfaceElevated,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Slips are part of many people's recovery. What matters is that "
                "you're here now. Let's learn from it together — gently.",
                style: context.text.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),
            Text('If you\'d like, what led up to it?',
                style: context.text.titleMedium,),
            const SizedBox(height: 4),
            Text('All optional — skip anything you want.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 12),

            _label(context, 'A trigger'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final t in _triggers)
                  AppChip(
                    label: t,
                    selected: _trigger == t,
                    onSelected: (_) =>
                        setState(() => _trigger = _trigger == t ? null : t),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _label(context, 'A feeling'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final f in _feelings)
                  AppChip(
                    label: f,
                    selected: _feeling == f,
                    onSelected: (_) =>
                        setState(() => _feeling = _feeling == f ? null : f),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _label(context, 'What was going on?'),
            TextField(
              controller: _situation,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'The situation, if you want to note it',
              ),
            ),
            const SizedBox(height: 16),

            _label(context, 'What might help next time?'),
            TextField(
              controller: _learning,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'A gentle note to your future self',
              ),
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Save & move forward',
              onPressed: () => Navigator.of(context).pop(_draft()),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Skip the notes',
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(const RelapseDraft()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: context.text.labelLarge
                ?.copyWith(color: context.palette.muted),),
      );
}
