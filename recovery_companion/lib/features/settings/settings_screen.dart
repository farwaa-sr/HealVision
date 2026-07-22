import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/theme_ext.dart';
import '../companion/widgets/companion_setup_sheet.dart';
import '../crisis/widgets/crisis_resources_sheet.dart';

/// Me — profile, privacy, support people, and app preferences. (Fleshed out in
/// a later step; for now it hosts the developer Style Guide entry.)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading:
                Icon(Icons.shield_outlined, color: context.colors.primary),
            title: const Text('Privacy & security'),
            subtitle:
                const Text('On-device & encrypted · app lock, export, delete'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoute.privacy.routeName),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.people_alt_outlined,
                color: context.colors.primary,),
            title: const Text('Support people & crisis help'),
            subtitle:
                const Text('Your contacts and 24/7 crisis lines, one tap away'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => CrisisResourcesSheet.show(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.notifications_none_rounded,
                color: context.colors.primary,),
            title: const Text('Notifications'),
            subtitle: const Text('Gentle reminders, nudges & quiet hours'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoute.notifications.routeName),
          ),
          const Divider(),
          ListTile(
            leading:
                Icon(Icons.smart_toy_outlined, color: context.colors.primary),
            title: const Text('AI Companion'),
            subtitle: const Text('Connect your backend (URL & access token)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => CompanionSetupSheet.show(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.palette_outlined, color: context.colors.primary),
            title: const Text('Style Guide'),
            subtitle: const Text('Preview the design system (dev)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoute.styleGuide.routeName),
          ),
        ],
      ),
    );
  }
}
