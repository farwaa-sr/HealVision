import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme_ext.dart';
import '../../data/local/database.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'model/goal_meta.dart';
import 'providers/goals_providers.dart';
import 'widgets/goal_celebration.dart';

/// A single goal: why it matters, its sub-steps, and warm completion.
class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final _step = TextEditingController();

  @override
  void dispose() {
    _step.dispose();
    super.dispose();
  }

  Future<void> _addStep() async {
    final text = _step.text.trim();
    if (text.isEmpty) return;
    await ref.read(goalsRepositoryProvider).addStep(widget.goalId, text);
    _step.clear();
  }

  Future<void> _complete(Goal goal) async {
    await ref.read(goalsRepositoryProvider).setCompleted(goal.id, true);
    if (mounted) await showGoalCelebration(context, goal.title);
  }

  Future<void> _confirmDelete(Goal goal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text('Remove "${goal.title}" and its steps?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep it'),),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(goalsRepositoryProvider).deleteGoal(goal.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalProvider(widget.goalId));
    final stepsAsync = ref.watch(goalStepsProvider(widget.goalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal'),
        actions: [
          goalAsync.maybeWhen(
            data: (g) => g == null
                ? const SizedBox.shrink()
                : PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'delete') _confirmDelete(g);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Delete goal')),
                    ],
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: goalAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => const Center(child: Text('Could not load goal.')),
        data: (goal) {
          if (goal == null) {
            return const Center(child: Text('This goal is no longer here.'));
          }
          final category = GoalCategory.fromName(goal.category);
          final complete = goal.completedAt != null;
          final steps = stepsAsync.valueOrNull ?? const <GoalStep>[];
          final doneCount = steps.where((s) => s.done).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Row(
                children: [
                  Icon(category.icon, size: 18, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text(category.label,
                      style: context.text.labelMedium
                          ?.copyWith(color: context.palette.muted),),
                ],
              ),
              const SizedBox(height: 8),
              Text(goal.title, style: context.text.headlineSmall),
              if (goal.targetDate != null) ...[
                const SizedBox(height: 6),
                Text('Target: ${DateFormat('MMMM d, yyyy').format(goal.targetDate!)}',
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.palette.muted),),
              ],
              if (goal.why != null && goal.why!.isNotEmpty) ...[
                const SizedBox(height: 16),
                AppCard(
                  color: Color.alphaBlend(
                    context.palette.accent.withValues(alpha: 0.14),
                    context.palette.surfaceElevated,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.favorite_outline,
                          color: context.colors.primary, size: 20,),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(goal.why!, style: context.text.bodyLarge),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Steps
              Row(
                children: [
                  Text('Steps', style: context.text.titleMedium),
                  const Spacer(),
                  if (steps.isNotEmpty)
                    Text('$doneCount / ${steps.length}',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.palette.muted),),
                ],
              ),
              const SizedBox(height: 8),
              if (steps.isEmpty)
                Text('No steps yet — add a few small ones below.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),)
              else
                for (final s in steps)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: s.done,
                    onChanged: (v) => ref
                        .read(goalsRepositoryProvider)
                        .toggleStep(s.id, v ?? false),
                    title: Text(
                      s.title,
                      style: TextStyle(
                        decoration:
                            s.done ? TextDecoration.lineThrough : null,
                        color: s.done ? context.palette.muted : null,
                      ),
                    ),
                    secondary: IconButton(
                      icon: Icon(Icons.close,
                          size: 18, color: context.palette.muted,),
                      onPressed: () =>
                          ref.read(goalsRepositoryProvider).deleteStep(s.id),
                    ),
                  ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _step,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:
                          const InputDecoration(hintText: 'Add a small step…'),
                      onSubmitted: (_) => _addStep(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                      onPressed: _addStep, icon: const Icon(Icons.add),),
                ],
              ),
              const SizedBox(height: 28),

              if (complete)
                AppButton(
                  label: 'Reopen this goal',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => ref
                      .read(goalsRepositoryProvider)
                      .setCompleted(goal.id, false),
                )
              else
                AppButton(
                  label: 'Mark goal complete',
                  icon: Icons.check,
                  onPressed: () => _complete(goal),
                ),
            ],
          );
        },
      ),
    );
  }
}
