import 'package:flutter/material.dart';

import '../../core/theme/theme_ext.dart';
import 'app_button.dart';

/// A gentle, encouraging empty state — invites a first action rather than
/// pointing out that something is missing.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primaryContainer,
              ),
              child: Icon(icon, size: 34, color: context.colors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.tonal,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
