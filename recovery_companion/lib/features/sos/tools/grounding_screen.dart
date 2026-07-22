import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';

class _Step {
  const _Step(this.count, this.sense, this.prompt);
  final int count;
  final String sense;
  final String prompt;
}

/// The 5-4-3-2-1 grounding exercise, one calm step at a time. Bringing
/// attention to the senses pulls you out of the craving and into right now.
class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  static const _steps = [
    _Step(5, 'see', 'Look around and name five things you can see.'),
    _Step(4, 'feel', 'Notice four things you can feel — your feet, a texture, the air.'),
    _Step(3, 'hear', 'Listen for three sounds, near or far.'),
    _Step(2, 'smell', 'Notice two things you can smell.'),
    _Step(1, 'taste', 'Notice one thing you can taste.'),
  ];

  int _index = 0;
  late final List<TextEditingController> _controllers =
      List.generate(_steps.length, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_index < _steps.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _back() {
    if (_index > 0) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Grounding')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _steps.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: context.palette.field,
            ),
            const Spacer(),
            Text('${step.count}',
                style: context.text.displaySmall?.copyWith(
                  fontSize: 84,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: context.colors.primary,
                ),),
            const SizedBox(height: 8),
            Text('things you can ${step.sense}',
                style: context.text.titleLarge, textAlign: TextAlign.center,),
            const SizedBox(height: 12),
            Text(step.prompt,
                textAlign: TextAlign.center,
                style: context.text.bodyLarge
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 20),
            TextField(
              controller: _controllers[_index],
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Name them, if you like (optional)',
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (_index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _back,
                      child: const Text('Back'),
                    ),
                  ),
                if (_index > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(isLast ? "I'm here now" : 'Next'),
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
