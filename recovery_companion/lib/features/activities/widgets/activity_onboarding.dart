import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../model/activity_meta.dart';
import '../providers/activities_providers.dart';

/// First-run personalization: what did the substance do *for* you? We use this
/// to suggest activities that fill the same need — the core of behavioral
/// activation.
class ActivityOnboarding extends ConsumerStatefulWidget {
  const ActivityOnboarding({super.key});

  @override
  ConsumerState<ActivityOnboarding> createState() => _ActivityOnboardingState();
}

class _ActivityOnboardingState extends ConsumerState<ActivityOnboarding> {
  final Set<Need> _selected = {};

  Future<void> _continue() async {
    await ref
        .read(activitiesRepositoryProvider)
        .saveNeeds(_selected.toList());
    ref.invalidate(savedNeedsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text('What did it do for you?', style: context.text.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Recovery goes better when we fill the space with something that '
          'meets the same need. Pick whatever fits — you can change this later.',
          style:
              context.text.bodyMedium?.copyWith(color: context.palette.muted),
        ),
        const SizedBox(height: 20),
        for (final need in Need.values) ...[
          _NeedTile(
            need: need,
            selected: _selected.contains(need),
            onTap: () => setState(() {
              if (!_selected.add(need)) _selected.remove(need);
            }),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        AppButton(
          label: 'Show me activities',
          onPressed: _selected.isEmpty ? null : _continue,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _continue,
            child: const Text('Skip for now'),
          ),
        ),
      ],
    );
  }
}

class _NeedTile extends StatelessWidget {
  const _NeedTile({
    required this.need,
    required this.selected,
    required this.onTap,
  });

  final Need need;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.colors.primaryContainer
          : context.palette.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(need.icon,
                  color: selected
                      ? context.colors.onPrimaryContainer
                      : context.colors.primary,),
              const SizedBox(width: 14),
              Expanded(
                child: Text(need.question, style: context.text.titleMedium),
              ),
              if (selected)
                Icon(Icons.check_circle, color: context.colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
