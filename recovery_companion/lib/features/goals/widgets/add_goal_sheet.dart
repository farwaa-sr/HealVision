import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../model/goal_meta.dart';
import '../providers/goals_providers.dart';

/// Add a goal with a friendly, SMART-ish structure. Nudges toward small,
/// achievable steps rather than one giant goal.
class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddGoalSheet(),
    );
  }

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _title = TextEditingController();
  final _why = TextEditingController();
  GoalCategory _category = GoalCategory.staySober;
  DateTime? _target;
  final List<TextEditingController> _steps = [TextEditingController()];

  @override
  void dispose() {
    _title.dispose();
    _why.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _target ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => _target = d);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final steps = _steps
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    await ref.read(goalsRepositoryProvider).addGoal(
          title: title,
          category: _category,
          why: _why.text.trim().isEmpty ? null : _why.text.trim(),
          targetDate: _target,
          steps: steps,
        );
    if (mounted) Navigator.of(context).pop();
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
            Text('A goal to work toward', style: context.text.titleLarge),
            const SizedBox(height: 4),
            Text('Small and achievable beats big and vague — momentum builds.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Walk 3 times this week',
              ),
            ),
            const SizedBox(height: 16),
            Text('Category',
                style: context.text.labelLarge
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 8),
            DropdownButtonFormField<GoalCategory>(
              initialValue: _category,
              items: [
                for (final c in GoalCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _why,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Why does this matter to you? (optional)',
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, color: context.palette.muted),
                    const SizedBox(width: 10),
                    Text(
                      _target == null
                          ? 'Add a target date (optional)'
                          : 'By ${DateFormat('MMM d, yyyy').format(_target!)}',
                      style: context.text.bodyMedium,
                    ),
                    if (_target != null) ...[
                      const Spacer(),
                      InkWell(
                        onTap: () => setState(() => _target = null),
                        child: Icon(Icons.close,
                            size: 18, color: context.palette.muted,),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Break it into small steps (optional)',
                style: context.text.labelLarge
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 8),
            for (var i = 0; i < _steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _steps[i],
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(hintText: 'Step ${i + 1}'),
                      ),
                    ),
                    if (_steps.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: context.palette.muted,),
                        onPressed: () => setState(() {
                          _steps.removeAt(i).dispose();
                        }),
                      ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _steps.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add a step'),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Create goal', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
