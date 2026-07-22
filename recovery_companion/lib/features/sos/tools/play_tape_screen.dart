import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';

class _Prompt {
  const _Prompt(this.title, this.body, {this.field = false});
  final String title;
  final String body;
  final bool field;
}

/// "Play the tape forward" — walk through what using would actually lead to,
/// then the other tape: how tomorrow-you feels if you don't. Not to shame —
/// just to see the whole picture before deciding.
class PlayTapeScreen extends StatefulWidget {
  const PlayTapeScreen({super.key});

  @override
  State<PlayTapeScreen> createState() => _PlayTapeScreenState();
}

class _PlayTapeScreenState extends State<PlayTapeScreen> {
  static const _prompts = [
    _Prompt(
      'Let\'s play the tape forward',
      'Not to scare you — just to see the whole picture before deciding. Take '
          'it slowly.',
    ),
    _Prompt(
      'If you use right now…',
      'What actually happens in the next hour? Play it honestly.',
      field: true,
    ),
    _Prompt(
      '…and later tonight?',
      'How does the rest of the night usually go from there?',
      field: true,
    ),
    _Prompt(
      '…and tomorrow morning?',
      'How would you feel waking up — in your body, and about yourself?',
      field: true,
    ),
    _Prompt(
      'Now the other tape',
      'If you don\'t use tonight, how will tomorrow-you feel waking up clear '
          'and proud of getting through this?',
      field: true,
    ),
    _Prompt(
      'You\'ve seen both tapes',
      'Which future do you want to give yourself? You get to choose the next '
          'few minutes.',
    ),
  ];

  int _index = 0;
  late final List<TextEditingController> _controllers =
      List.generate(_prompts.length, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_index < _prompts.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _prompts[_index];
    final isLast = _index == _prompts.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Play the tape forward')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _prompts.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: context.palette.field,
            ),
            const Spacer(),
            Text(p.title, style: context.text.headlineSmall),
            const SizedBox(height: 12),
            Text(p.body,
                style: context.text.bodyLarge
                    ?.copyWith(color: context.palette.muted),),
            if (p.field) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _controllers[_index],
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Write it out, if it helps (optional)',
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                if (_index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _index--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_index > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(isLast ? 'I\'ve decided' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
