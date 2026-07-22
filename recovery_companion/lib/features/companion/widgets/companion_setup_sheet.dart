import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/companion_providers.dart';

/// Where the user points the app at their own Claude proxy. The base URL is
/// stored locally; the access token goes into the device's secure keystore.
/// The app talks only to this endpoint — never to Anthropic directly.
class CompanionSetupSheet extends ConsumerStatefulWidget {
  const CompanionSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const CompanionSetupSheet(),
    );
  }

  @override
  ConsumerState<CompanionSetupSheet> createState() =>
      _CompanionSetupSheetState();
}

class _CompanionSetupSheetState extends ConsumerState<CompanionSetupSheet> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  bool _obscure = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final config = await ref.read(companionRepositoryProvider).loadConfig();
    if (!mounted) return;
    setState(() {
      _url.text = config.baseUrl;
      _token.text = config.token;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(companionRepositoryProvider).saveConfig(
          baseUrl: _url.text,
          token: _token.text,
        );
    await ref.read(chatProvider.notifier).reloadConfig();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect your companion', style: context.text.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'The app sends messages only to your own backend, which '
                    'holds the API key. Nothing goes to Anthropic directly.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),
                  ),
                  const SizedBox(height: 20),
                  Text('Backend URL',
                      style: context.text.labelLarge
                          ?.copyWith(color: context.palette.muted),),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _url,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'https://your-worker.workers.dev',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Access token',
                      style: context.text.labelLarge
                          ?.copyWith(color: context.palette.muted),),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _token,
                    obscureText: _obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: 'Bearer token for your endpoint',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 16, color: context.palette.muted,),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kept on this device only — the token lives in the '
                          'secure keystore, not the database.',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.palette.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: _saving ? 'Saving…' : 'Save',
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }
}
