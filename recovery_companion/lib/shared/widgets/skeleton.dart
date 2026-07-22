import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';

/// A calm loading placeholder that gently pulses (a soft fade, not a flashy
/// shimmer). Static under reduced-motion settings.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
      Tween(begin: 0.35, end: 0.7).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.palette.field,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle
            ? (widget.borderRadius ?? BorderRadius.circular(10))
            : null,
      ),
    );

    if (AppMotion.reduced(context)) {
      return Opacity(opacity: 0.6, child: box);
    }
    return FadeTransition(opacity: _opacity, child: box);
  }
}
