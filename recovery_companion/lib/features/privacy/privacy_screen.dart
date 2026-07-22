import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_card.dart';
import '../notifications/providers/notification_providers.dart';
import '../security/lock_setup_sheet.dart';
import '../security/providers/security_providers.dart';
import 'providers/privacy_providers.dart';

/// Plain-language privacy & security home: what's stored and where, plus the
/// controls that matter — app lock, export everything, delete everything.
class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await ref.read(dataExportServiceProvider).buildJson();
      final bytes = Uint8List.fromList(utf8.encode(json));
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: 'onward_export.json',
            mimeType: 'application/json',
          ),
        ],
        subject: 'Onward — my data',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the export.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteEverything() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteConfirmDialog(),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    await ref.read(dataExportServiceProvider).deleteEverything();
    ref.invalidate(appLockConfigProvider);
    await ref.read(notificationSchedulerProvider).rescheduleAll();
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Everything has been deleted from this device.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockConfigProvider).valueOrNull;
    final lockOn = lock?.enabled ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & security')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Text(
              'This app is built to be a safe, private place. Here’s exactly '
              'how your information is handled — in plain language.',
              style: context.text.bodyMedium
                  ?.copyWith(color: context.palette.muted),
            ),
            const SizedBox(height: 20),

            const _PointCard(
              icon: Icons.phone_iphone,
              title: 'It stays on your device',
              body:
                  'Your check-ins, journal, streaks, and chats live only on '
                  'this phone. There are no accounts, and nothing is uploaded '
                  'to us — because there is no “us” server holding your data.',
            ),
            const _PointCard(
              icon: Icons.lock_outline,
              title: 'Encrypted at rest',
              body:
                  'The database is encrypted on disk, and your companion chats '
                  'get a second layer of encryption. The keys live in your '
                  'device’s secure keystore — not in the database or any backup.',
            ),
            const _PointCard(
              icon: Icons.block_flipped,
              title: 'Nothing sold, nothing tracked',
              body:
                  'No advertising, no selling or sharing your data, and no '
                  'analytics or tracking. The app collects the minimum it needs '
                  'to work, and only because you typed it in.',
            ),
            const _PointCard(
              icon: Icons.volunteer_activism_outlined,
              title: 'The AI companion',
              body:
                  'When you chat, only that conversation is sent to your own '
                  'backend to reach the AI — never your check-ins or journal. '
                  'It’s treated as private and sensitive.',
            ),

            const SizedBox(height: 12),
            Text('Your controls', style: context.text.titleMedium),
            const SizedBox(height: 12),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.pattern, color: context.colors.primary),
                    title: const Text('App lock'),
                    subtitle: Text(lockOn
                        ? 'On — PIN${lock?.biometrics ?? false ? ' + biometrics' : ''}'
                        : 'Off — add a PIN or biometrics',),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => LockSetupSheet.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.download_outlined, color: context.colors.primary),
                    title: const Text('Export my data'),
                    subtitle: const Text('A full, readable copy to save or move'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _busy ? null : _export,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.delete_outline, color: context.palette.support),
                    title: Text('Delete everything',
                        style: TextStyle(color: context.palette.support),),
                    subtitle:
                        const Text('Permanently erase all data from this device'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _busy ? null : _deleteEverything,
                  ),
                ],
              ),
            ),

            if (_busy) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: context.text.bodySmall?.copyWith(
                      color: context.palette.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog();

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _controller = TextEditingController();
  bool _ok = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete everything?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently erases all your data on this device — check-ins, '
            'streaks, activities, goals, chats, and contacts. It can’t be '
            'undone. Consider exporting first.\n\nType DELETE to confirm.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'DELETE'),
            onChanged: (v) =>
                setState(() => _ok = v.trim().toUpperCase() == 'DELETE'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep my data'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.palette.support,
          ),
          onPressed: _ok ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
