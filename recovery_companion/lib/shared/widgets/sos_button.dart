import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/haptics.dart';

/// The "I'm craving" / SOS action: prominent and instantly findable, but calm
/// — grounded coral, soft edges, and a slow, barely-there pulse (never a
/// flashing alarm). The pulse is disabled under reduced-motion settings.
class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    required this.onPressed,
    this.label = "I'm craving",
  });

  final VoidCallback onPressed;
  final String label;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduced = AppMotion.reduced(context);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = reduced ? 0.0 : Curves.easeInOut.transform(_pulse.value);
        return Transform.scale(scale: 1 + t * 0.03, child: child);
      },
      child: Material(
        color: palette.support,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Haptics.success();
            widget.onPressed();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: palette.support.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: palette.onSupport, size: 24),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: context.text.titleMedium?.copyWith(
                    color: palette.onSupport,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
