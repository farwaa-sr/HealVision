import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../data/local/database.dart';
import '../data/crisis_resources.dart';
import '../providers/crisis_providers.dart';
import 'support_contact_sheet.dart';

/// Always-available crisis resources, reachable from every screen via the
/// persistent help button. Region-aware where possible (US resources otherwise,
/// clearly labelled), plus the user's own saved support people — all one tap to
/// call or text.
class CrisisResourcesSheet extends ConsumerWidget {
  const CrisisResourcesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const CrisisResourcesSheet(),
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $uri')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final support = context.palette.support;
    final region = ref.watch(crisisRegionProvider);
    final contacts =
        ref.watch(supportContactsProvider).valueOrNull ?? const [];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: support),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "If you're in crisis, reach a person now",
                    style: context.text.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You deserve real support right now — more than an app can give. '
              "These are free, confidential, and open 24/7. You don't have to "
              'carry this alone.',
              style: context.text.bodyMedium
                  ?.copyWith(color: context.palette.muted),
            ),
            const SizedBox(height: 20),

            for (final r in region.resources) ...[
              _ResourceTile(
                accent: r.emphasized ? support : context.colors.primary,
                resource: r,
                onCall: r.call == null
                    ? null
                    : () => _launch(context, Uri(scheme: 'tel', path: r.call)),
                onText: r.text == null
                    ? null
                    : () => _launch(context, Uri(scheme: 'sms', path: r.text)),
              ),
              const SizedBox(height: 12),
            ],

            if (region.isFallback) ...[
              const SizedBox(height: 2),
              Text(
                'These are US resources. If you’re elsewhere, add your local '
                'crisis line as a support contact below, or search '
                '"suicide helpline" plus your country.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),
              ),
              const SizedBox(height: 16),
            ],

            // Personal support people.
            Row(
              children: [
                Expanded(
                  child: Text('Your people', style: context.text.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => SupportContactSheet.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (contacts.isEmpty)
              Text(
                'Add a sponsor, friend, or family member for one-tap reach when '
                'you need them.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),
              )
            else
              for (final c in contacts) ...[
                _ContactTile(
                  contact: c,
                  onCall: () =>
                      _launch(context, Uri(scheme: 'tel', path: c.phone)),
                  onText: () =>
                      _launch(context, Uri(scheme: 'sms', path: c.phone)),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.accent,
    required this.resource,
    required this.onCall,
    required this.onText,
  });

  final Color accent;
  final CrisisResource resource;
  final VoidCallback? onCall;
  final VoidCallback? onText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${resource.name}. ${resource.subtitle}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.palette.field,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.16),
              ),
              child: Icon(resource.icon, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.name, style: context.text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    resource.subtitle,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onCall != null)
              FilledButton(
                onPressed: onCall,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Call'),
              ),
            if (onText != null) ...[
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onText, child: const Text('Text')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({
    required this.contact,
    required this.onCall,
    required this.onText,
  });

  final SupportContactRow contact;
  final VoidCallback onCall;
  final VoidCallback onText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = contact.relationship?.trim().isNotEmpty ?? false
        ? contact.relationship!
        : contact.phone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.palette.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colors.primary.withValues(alpha: 0.14),
            child: Text(
              contact.name.characters.first.toUpperCase(),
              style: TextStyle(color: context.colors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: context.text.titleSmall),
                Text(
                  subtitle,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.palette.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Call ${contact.name}',
            onPressed: onCall,
            icon: Icon(Icons.call, color: context.colors.primary),
          ),
          IconButton(
            tooltip: 'Text ${contact.name}',
            onPressed: onText,
            icon: Icon(Icons.sms_outlined, color: context.palette.muted),
          ),
        ],
      ),
    );
  }
}
