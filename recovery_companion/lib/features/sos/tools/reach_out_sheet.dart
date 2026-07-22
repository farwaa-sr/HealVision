import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../crisis/providers/crisis_providers.dart';
import '../../crisis/widgets/crisis_resources_sheet.dart';
import '../../crisis/widgets/support_contact_sheet.dart';

/// Reach out — one tap to call or text a trusted person, plus quick access to
/// crisis lines. Contacts are stored locally, so this works fully offline.
class ReachOutSheet extends ConsumerWidget {
  const ReachOutSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ReachOutSheet(),
    );
  }

  Future<void> _dial(BuildContext context, String number,
      {bool sms = false,}) async {
    final uri = Uri(scheme: sms ? 'sms' : 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the dialer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(supportContactsProvider).valueOrNull ?? const [];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You don't have to do this alone",
                style: context.text.titleLarge,),
            const SizedBox(height: 4),
            Text('Reaching out is a strength, not a weakness.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 20),

            if (contacts.isEmpty)
              _EmptyContacts(
                onAdd: () => SupportContactSheet.show(context),
              )
            else ...[
              Text('Your people',
                  style: context.text.labelLarge
                      ?.copyWith(color: context.palette.muted),),
              const SizedBox(height: 8),
              for (final c in contacts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ContactRow(
                    name: c.name,
                    subtitle: c.relationship?.trim().isNotEmpty ?? false
                        ? c.relationship!
                        : c.phone,
                    onCall: () => _dial(context, c.phone),
                    onText: () => _dial(context, c.phone, sms: true),
                    onEdit: () =>
                        SupportContactSheet.show(context, existing: c),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => SupportContactSheet.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add another'),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Divider(color: context.colors.outlineVariant),
            const SizedBox(height: 12),
            AppButton(
              label: 'Crisis lines (988 & more)',
              icon: Icons.health_and_safety_outlined,
              variant: AppButtonVariant.tonal,
              onPressed: () => CrisisResourcesSheet.show(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add someone you trust — a sponsor, a friend, family — so they’re one '
          'tap away when it helps.',
          style:
              context.text.bodyMedium?.copyWith(color: context.palette.muted),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Add a support person',
          icon: Icons.person_add_alt,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.name,
    required this.subtitle,
    required this.onCall,
    required this.onText,
    required this.onEdit,
  });

  final String name;
  final String subtitle;
  final VoidCallback onCall;
  final VoidCallback onText;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.palette.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.text.titleSmall),
                Text(subtitle,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Call $name',
            onPressed: onCall,
            icon: Icon(Icons.call, color: context.colors.primary),
          ),
          IconButton(
            tooltip: 'Text $name',
            onPressed: onText,
            icon: Icon(Icons.sms_outlined, color: context.palette.muted),
          ),
          IconButton(
            tooltip: 'Edit $name',
            onPressed: onEdit,
            icon: Icon(Icons.more_vert, color: context.palette.muted),
          ),
        ],
      ),
    );
  }
}
