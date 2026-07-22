import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/theme_ext.dart';

/// Three softly pulsing dots shown while the companion is composing a reply.
/// Collapses to static dots when the OS "reduce motion" setting is on.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.palette.muted;
    if (AppMotion.reduced(context)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
            child: _Dot(color: color, opacity: 0.6),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value - i * 0.18) % 1.0;
            final wave = (t < 0.5) ? t * 2 : (1 - t) * 2; // 0→1→0
            return Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
              child: Transform.translate(
                offset: Offset(0, -2 * wave),
                child: _Dot(color: color, opacity: 0.4 + 0.5 * wave),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}
