import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';

/// A soft circular progress ring with a rounded cap and an animated fill.
/// Used for streaks, goals, and daily rings. Animation respects reduced motion.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 120,
    this.strokeWidth = 12,
    this.color,
    this.trackColor,
    this.center,
  });

  /// 0.0 – 1.0
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? context.colors.primary;
    final track = trackColor ?? context.palette.ringTrack;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: AppMotion.duration(context, AppMotion.slow),
      curve: AppMotion.emphasized,
      builder: (context, animated, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: animated,
              color: ringColor,
              trackColor: track,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: center),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, trackPaint);

    const start = -math.pi / 2;
    final sweep = value * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(rect, start, sweep, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
