import 'package:flutter/material.dart';

/// Consistent, calm placeholder used by feature screens until each is built
/// out in its own step. Keeps the whole app feeling cohesive and unhurried.
class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.showAppBar = true,
  });

  final String title;
  final IconData icon;
  final String description;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
