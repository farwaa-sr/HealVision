import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../providers/checkin_providers.dart';

/// Log a craving or trigger the moment it shows up — any time, not only during
/// a check-in. Quick and low-friction; it quietly feeds pattern awareness.
class QuickTriggerSheet extends ConsumerStatefulWidget {
  const QuickTriggerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const QuickTriggerSheet(),
    );
  }

  @override
  ConsumerState<QuickTriggerSheet> createState() => _QuickTriggerSheetState();
}

class _QuickTriggerSheetState extends ConsumerState<QuickTriggerSheet> {
  static const _triggers = [
    'Stress',
    'Boredom',
    'Social',
    'Conflict',
    'Tired',
    'Celebration',
    'Seeing it',
    'Other',
  ];

  double _intensity = 5;
  String? _trigger;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(checkInRepositoryProvider).logTrigger(
          intensity: _intensity.round(),
          trigger: _trigger,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    unawaited(Haptics.selection());
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged. Thanks for noticing it.')),
      );
    }
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Noticing a craving?', style: context.text.titleLarge),
            const SizedBox(height: 4),
            Text('Just noting it helps — no judgment, no pressure to act.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 16),
            Text('How strong is it?',
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
            Text('What set it off? (optional)',
                style: context.text.labelLarge
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 8),
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
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'A note, if you like (optional)',
              ),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Log it', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
