import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_card.dart';

/// A large, simple, tappable tool entry on the SOS toolkit. Big touch target,
/// calm styling — easy to reach for in a hard moment.
class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.colors.primary;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.palette.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.palette.muted),
        ],
      ),
    );
  }
}
