import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/haptics.dart';

/// Rounded card with a soft, low shadow. Optionally tappable, with a subtle
/// press animation and a light haptic — never a hard bounce.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    final card = AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: AppMotion.duration(context, AppMotion.fast),
      curve: AppMotion.curve,
      child: Container(
        decoration: BoxDecoration(
          color: widget.color ?? context.palette.surfaceElevated,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        Haptics.tap();
        widget.onTap!();
      },
      child: card,
    );
  }
}
