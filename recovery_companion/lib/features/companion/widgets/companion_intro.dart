import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_card.dart';

/// The warm welcome shown when the conversation is empty. Sets a gentle tone,
/// states plainly what the companion is and isn't, and offers a few low-stakes
/// ways to start.
class CompanionIntro extends StatelessWidget {
  const CompanionIntro({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  static const _starters = [
    "I'm having a hard moment",
    'I want to talk through a craving',
    'Something good happened today',
    'I slipped and feel bad about it',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          color: Color.alphaBlend(
            context.colors.primary.withValues(alpha: 0.08),
            context.palette.surfaceElevated,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.waving_hand_outlined,
                      color: context.colors.primary,),
                  const SizedBox(width: 10),
                  Text('Hey, I’m here with you', style: context.text.titleLarge),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'This is a calm, private space to think out loud — about a '
                'craving, a rough day, a small win, whatever’s on your mind. '
                'No judgment, ever.',
                style: context.text.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.palette.field,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: context.palette.muted,),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I’m a companion, not a therapist, doctor, or crisis '
                        'service. If things feel heavy or unsafe, tap the ♥ at '
                        'the top for real, human help right away.',
                        style: context.text.bodySmall?.copyWith(
                          color: context.palette.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Not sure where to start?',
            style: context.text.labelLarge
                ?.copyWith(color: context.palette.muted),),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _starters)
              ActionChip(
                label: Text(s),
                onPressed: () => onSuggestion(s),
                backgroundColor: context.palette.surfaceElevated,
                side: BorderSide(color: context.colors.outlineVariant),
              ),
          ],
        ),
      ],
    );
  }
}
