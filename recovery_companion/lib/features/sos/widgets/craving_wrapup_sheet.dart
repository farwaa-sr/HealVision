import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/mood_selector.dart';
import '../providers/sos_providers.dart';

/// After a craving passes: a gentle 1-tap mood check, an optional note of what
/// helped, then a warm celebration. Everything is skippable.
class CravingWrapupSheet extends ConsumerStatefulWidget {
  const CravingWrapupSheet({super.key, required this.startedAt});

  final DateTime startedAt;

  static Future<void> show(BuildContext context, DateTime startedAt) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CravingWrapupSheet(startedAt: startedAt),
    );
  }

  @override
  ConsumerState<CravingWrapupSheet> createState() => _CravingWrapupSheetState();
}

class _CravingWrapupSheetState extends ConsumerState<CravingWrapupSheet> {
  static const _tools = [
    'Urge surfing',
    'Grounding',
    'Breathing',
    'Playing the tape',
    'Distraction',
    'Reaching out',
    'My reasons',
  ];

  Mood? _mood;
  double _intensity = 5;
  final Set<String> _helped = {};
  bool _celebrated = false;

  Future<void> _log() async {
    await ref.read(cravingRepositoryProvider).logCraving(
          startedAt: widget.startedAt,
          resolvedAt: DateTime.now(),
          intensity: _intensity.round(),
          moodAfter: _mood?.label,
          helped: _helped.toList(),
        );
    unawaited(Haptics.success());
    if (mounted) setState(() => _celebrated = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: _celebrated ? _celebration(context) : _form(context),
    );
  }

  Widget _celebration(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.palette.success.withValues(alpha: 0.2),
          ),
          child: Icon(Icons.check_rounded,
              size: 34, color: context.palette.success,),
        ),
        const SizedBox(height: 16),
        Text('You rode it out', style: context.text.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'You felt the urge and didn\'t act on it. Every time you get through '
          'one, it loosens its grip a little more. That\'s real progress.',
          textAlign: TextAlign.center,
          style:
              context.text.bodyMedium?.copyWith(color: context.palette.muted),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you feeling now?', style: context.text.titleLarge),
          const SizedBox(height: 4),
          Text('A quick check-in — no pressure to fill anything in.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.palette.muted),),
          const SizedBox(height: 16),
          MoodSelector(
            value: _mood,
            onChanged: (m) => setState(() => _mood = m),
          ),
          const SizedBox(height: 20),
          Text('How strong was the urge? (optional)',
              style: context.text.labelLarge
                  ?.copyWith(color: context.palette.muted),),
          Slider(
            value: _intensity,
            min: 0,
            max: 10,
            divisions: 10,
            label: _intensity.round().toString(),
            onChanged: (v) => setState(() => _intensity = v),
          ),
          const SizedBox(height: 8),
          Text('What helped? (optional)',
              style: context.text.labelLarge
                  ?.copyWith(color: context.palette.muted),),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final t in _tools)
                AppChip(
                  label: t,
                  selected: _helped.contains(t),
                  onSelected: (_) => setState(() {
                    if (!_helped.add(t)) _helped.remove(t);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Log it & finish', onPressed: _log),
          const SizedBox(height: 8),
          AppButton(
            label: 'Skip',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
