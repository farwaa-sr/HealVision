import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme_ext.dart';

/// Shown immediately after a slip is logged. Never dwells on the slip — offers
/// a warm, concrete next step so the user isn't left alone in a hard moment.
class SupportiveNextStepSheet extends StatelessWidget {
  const SupportiveNextStepSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SupportiveNextStepSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You showed up and logged it — that takes honesty.',
              style: context.text.titleLarge,),
          const SizedBox(height: 6),
          Text(
            "Your clean time starts fresh from now, and every day you've put in "
            'still counts. What would help right now?',
            style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 20),
          _Option(
            icon: Icons.favorite,
            iconColor: context.palette.support,
            title: 'Open the SOS toolkit',
            subtitle: 'Grounding and ways to ride out the urge',
            onTap: () {
              Navigator.of(context).pop();
              context.pushNamed(AppRoute.sos.routeName);
            },
          ),
          _Option(
            icon: Icons.spa_outlined,
            iconColor: context.colors.primary,
            title: 'Try a replacement activity',
            subtitle: 'Something rewarding to do instead',
            onTap: () {
              Navigator.of(context).pop();
              context.goNamed(AppRoute.activities.routeName);
            },
          ),
          _Option(
            icon: Icons.people_outline,
            iconColor: context.colors.primary,
            title: 'Reach a support person',
            subtitle: "You don't have to do this alone",
            onTap: () {
              Navigator.of(context).pop();
              context.goNamed(AppRoute.me.routeName);
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("I'm okay for now"),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.palette.field,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleMedium),
                      Text(subtitle,
                          style: context.text.bodySmall
                              ?.copyWith(color: context.palette.muted),),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.palette.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
