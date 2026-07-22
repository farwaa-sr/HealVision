import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../core/theme/theme_ext.dart';

/// A clean, readable line chart for a single series over time. Soft area fill,
/// a couple of guide lines, minimal labels — no clutter.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.values,
    required this.dates,
    required this.min,
    required this.max,
    this.color,
    this.height = 150,
  });

  final List<double> values;
  final List<DateTime> dates;
  final double min;
  final double max;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'A little more data and this will come to life.',
            style:
                context.text.bodySmall?.copyWith(color: context.palette.muted),
          ),
        ),
      );
    }
    final c = color ?? context.colors.primary;
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(
          values: values,
          min: min,
          max: max,
          line: c,
          grid: context.colors.outlineVariant,
          label: context.palette.muted,
          startLabel: DateFormat('MMM d').format(dates.first),
          endLabel: DateFormat('MMM d').format(dates.last),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.min,
    required this.max,
    required this.line,
    required this.grid,
    required this.label,
    required this.startLabel,
    required this.endLabel,
  });

  final List<double> values;
  final double min;
  final double max;
  final Color line;
  final Color grid;
  final Color label;
  final String startLabel;
  final String endLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 8.0;
    const bottomPad = 20.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    double xFor(int i) => leftPad + (i / (values.length - 1)) * chartW;
    double yFor(double v) {
      final t = ((v - min) / (max - min)).clamp(0.0, 1.0);
      return chartH - t * (chartH - 8) - 4;
    }

    // Guide lines (min / mid / max).
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final f in [0.0, 0.5, 1.0]) {
      final y = chartH - f * (chartH - 8) - 4;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // Line + area.
    final linePath = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(xFor(i), yFor(values[i]));
      if (i == 0) {
        linePath.moveTo(p.dx, p.dy);
      } else {
        linePath.lineTo(p.dx, p.dy);
      }
    }
    final areaPath = Path.from(linePath)
      ..lineTo(xFor(values.length - 1), chartH)
      ..lineTo(xFor(0), chartH)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.22), line.withValues(alpha: 0.02)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = line,
    );
    // Last point.
    canvas.drawCircle(
      Offset(xFor(values.length - 1), yFor(values.last)),
      3.5,
      Paint()..color = line,
    );

    // Date labels.
    _text(canvas, startLabel, Offset(leftPad, chartH + 4), label);
    final endTp = _measure(endLabel, label);
    _text(canvas, endLabel, Offset(size.width - endTp.width, chartH + 4), label);
  }

  TextPainter _measure(String s, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: s, style: TextStyle(color: color, fontSize: 11),),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  void _text(Canvas canvas, String s, Offset at, Color color) {
    _measure(s, color).paint(canvas, at);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.min != min || old.max != max;
}
