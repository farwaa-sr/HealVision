import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/theme_ext.dart';

enum _Mode { box, fourSevenEight }

class _Phase {
  const _Phase(this.label, this.seconds, this.target);
  final String label;
  final int seconds;
  final double target; // breath fullness 0..1
}

/// A simple animated breathing pacer — box breathing (4-4-4-4) or 4-7-8. The
/// circle expands on the inhale and settles on the exhale; a per-phase count
/// keeps the pace. Fully offline, calm, reduced-motion aware.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, value: 0);
  Timer? _timer;
  _Mode _mode = _Mode.box;
  int _absIndex = 0;
  int _remaining = 0;
  bool _running = false;

  List<_Phase> get _phases => _mode == _Mode.box
      ? const [
          _Phase('Breathe in', 4, 1),
          _Phase('Hold', 4, 1),
          _Phase('Breathe out', 4, 0),
          _Phase('Hold', 4, 0),
        ]
      : const [
          _Phase('Breathe in', 4, 1),
          _Phase('Hold', 7, 1),
          _Phase('Breathe out', 8, 0),
        ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _start() {
    _running = true;
    _runPhase(0);
  }

  void _runPhase(int i) {
    if (!mounted) return;
    final phases = _phases;
    final p = phases[i % phases.length];
    setState(() {
      _absIndex = i;
      _remaining = p.seconds;
    });
    _c.animateTo(
      p.target,
      duration: AppMotion.reduced(context)
          ? Duration.zero
          : Duration(seconds: p.seconds),
      curve: Curves.easeInOut,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_running) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        if (_running) _runPhase(i + 1);
      }
    });
  }

  void _toggleRun() {
    if (_running) {
      setState(() => _running = false);
      _timer?.cancel();
      _c.stop();
    } else {
      _start();
    }
  }

  void _setMode(_Mode m) {
    setState(() => _mode = m);
    _timer?.cancel();
    _c.value = 0;
    if (_running) {
      _runPhase(0);
    } else {
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _phases[_absIndex % _phases.length].label;
    return Scaffold(
      appBar: AppBar(title: const Text('Breathe')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<_Mode>(
              segments: const [
                ButtonSegment(value: _Mode.box, label: Text('Box 4·4·4·4')),
                ButtonSegment(
                    value: _Mode.fourSevenEight, label: Text('4·7·8'),),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _setMode(s.first),
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final size = 150 + _c.value * 130;
                  return Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          context.colors.primary.withValues(alpha: 0.35),
                          context.colors.primary.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label, style: context.text.titleLarge),
                        const SizedBox(height: 4),
                        Text('$_remaining',
                            style: context.text.displaySmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w700,),),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                Text(
                  'Follow the circle. There\'s no wrong way to do this.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.palette.muted),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _toggleRun,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? 'Pause' : 'Resume'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
