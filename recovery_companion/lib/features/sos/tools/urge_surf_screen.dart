import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/theme_ext.dart';

/// Urge surfing — a craving is a wave: it rises, peaks, and falls, usually
/// within about 20 minutes. Ride it out with the animated wave and a visible
/// countdown. Nothing is forced; the user can leave any time.
class UrgeSurfScreen extends StatefulWidget {
  const UrgeSurfScreen({super.key});

  @override
  State<UrgeSurfScreen> createState() => _UrgeSurfScreenState();
}

class _UrgeSurfScreenState extends State<UrgeSurfScreen>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(minutes: 20);

  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  Timer? _timer;
  int _secondsLeft = _total.inSeconds;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wave.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_running) return;
      if (_secondsLeft <= 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      if (!AppMotion.reduced(context)) _wave.repeat();
      _startTimer();
    } else {
      _wave.stop();
    }
  }

  String get _clock {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _elapsedFraction =>
      1 - (_secondsLeft / _total.inSeconds).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final done = _secondsLeft <= 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Ride the wave')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            Text(
              done
                  ? 'The wave has passed. Notice how your body feels now.'
                  : 'A craving is a wave. It rises, peaks, and falls — usually '
                      'within about 20 minutes. You don\'t have to fight it. '
                      'Just ride it out.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge,
            ),
            const Spacer(),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _wave,
                builder: (context, _) => CustomPaint(
                  painter: _WavePainter(
                    phase: AppMotion.reduced(context) ? 0.25 : _wave.value,
                    peak: _elapsedFraction,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(_clock,
                style: context.text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700, color: context.colors.primary,),),
            Text(done ? 'You rode it out' : 'remaining',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),),
            const Spacer(),
            if (done)
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('I got through it'),
              )
            else ...[
              OutlinedButton.icon(
                onPressed: _toggle,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Resume'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('The urge has passed'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.phase, required this.peak, required this.color});

  final double phase; // 0..1 horizontal movement
  final double peak; // 0..1 how far through the ride (amplitude envelope)
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Amplitude rises then falls across the ride (a bell around the midpoint).
    final envelope = math.sin(peak * math.pi); // 0 → 1 → 0
    final amp = 12 + envelope * (size.height * 0.28);
    final mid = size.height * 0.55;

    Path buildPath(double ampScale, double yShift) {
      final path = Path()..moveTo(0, mid);
      for (double x = 0; x <= size.width; x += 4) {
        final t = x / size.width;
        final y = mid +
            yShift +
            amp *
                ampScale *
                math.sin((t * 2 * math.pi * 1.5) + phase * 2 * math.pi);
        path.lineTo(x, y);
      }
      return path;
    }

    canvas.drawPath(
      buildPath(0.6, 14),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withValues(alpha: 0.3),
    );
    canvas.drawPath(
      buildPath(1, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.phase != phase || old.peak != peak || old.color != color;
}
