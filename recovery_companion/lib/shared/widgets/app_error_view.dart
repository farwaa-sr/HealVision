import 'package:flutter/material.dart';

/// Friendly, non-alarming fallback shown when a widget fails to build.
///
/// Recovery apps must never feel like they're breaking down on the user in a
/// vulnerable moment — so this stays calm and reassuring, and offers a way
/// forward instead of a red error screen.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.spa_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Let\'s take a breath',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Something didn\'t load quite right. That\'s okay — nothing '
                'you\'ve tracked is lost.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
