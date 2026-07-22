import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';

/// A tiny 7-day mood sparkline — a soft line, no axes or clutter.
/// [values] are 1 (struggling) … 5 (great).
class MoodSparkline extends StatelessWidget {
  const MoodSparkline({
    super.key,
    required this.values,
    this.height = 28,
    this.color,
  });

  final List<int> values;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          values: values,
          color: color ?? context.colors.primary,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    const minV = 1.0;
    const maxV = 5.0;
    final dx = size.width / (values.length - 1);

    double yFor(int v) {
      final norm = (v.clamp(1, 5) - minV) / (maxV - minV); // 0..1
      // Invert so higher mood is higher on screen, with a little padding.
      return size.height - norm * (size.height - 4) - 2;
    }

    final path = Path()..moveTo(0, yFor(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(dx * i, yFor(values[i]));
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    canvas.drawPath(path, linePaint);

    // Highlight the most recent point.
    final last = Offset(size.width, yFor(values.last));
    canvas.drawCircle(last, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}
