import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import 'model/companion_message.dart';
import 'providers/companion_providers.dart';
import '../crisis/widgets/crisis_resources_sheet.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/companion_intro.dart';
import 'widgets/companion_setup_sheet.dart';

/// Companion — a warm, private chat backed by Claude through the user's own
/// proxy. Streams replies, persists history (encrypted), and keeps crisis
/// resources one tap away at all times.
class CompanionScreen extends ConsumerStatefulWidget {
  const CompanionScreen({super.key});

  @override
  ConsumerState<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends ConsumerState<CompanionScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _crisisAutoShown = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    final target = _scroll.position.maxScrollExtent;
    if (AppMotion.reduced(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  void _fillComposer(String text) {
    _input.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    ref.read(chatProvider.notifier).send(text);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear this conversation?'),
        content: const Text(
          'This permanently deletes the chat history on this device. Your '
          'check-ins, streaks, and everything else stay untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(chatProvider.notifier).clearConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to new content: keep the view pinned to the latest message, and
    // surface crisis resources automatically the first time they're flagged.
    ref.listen<AsyncValue<ChatState>>(chatProvider, (prev, next) {
      final state = next.valueOrNull;
      if (state == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      if (state.showCrisis && !_crisisAutoShown) {
        _crisisAutoShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) CrisisResourcesSheet.show(context);
        });
      } else if (!state.showCrisis) {
        _crisisAutoShown = false;
      }
    });

    final async = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion'),
        actions: [
          IconButton(
            tooltip: 'Crisis resources',
            icon: Icon(Icons.favorite, color: context.palette.support),
            onPressed: () => CrisisResourcesSheet.show(context),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'settings') {
                CompanionSetupSheet.show(context);
              } else if (v == 'clear') {
                _confirmClear();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Companion settings')),
              PopupMenuItem(value: 'clear', child: Text('Clear conversation')),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _SetupCard(),
        data: (state) {
          if (!state.config.isConfigured) return const _SetupCard();
          return Column(
            children: [
              if (state.showCrisis) const _CrisisBanner(),
              Expanded(child: _buildList(state)),
              _Composer(
                controller: _input,
                sending: state.sending,
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(ChatState state) {
    final msgs = state.messages;
    final children = <Widget>[];

    if (msgs.isEmpty) {
      children.add(CompanionIntro(onSuggestion: _fillComposer));
    } else {
      for (final m in msgs) {
        children.add(ChatBubble(message: m));
      }
      final last = msgs.last;
      if (last.role == ChatRole.assistant && last.failed && !state.sending) {
        children.add(
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ref.read(chatProvider.notifier).retryLast(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
          ),
        );
      }
    }

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: children,
    );
  }
}

/// Shown until the user points the app at their backend proxy.
class _SetupCard extends StatelessWidget {
  const _SetupCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: context.colors.primary),
                  const SizedBox(width: 10),
                  Text('Meet your companion', style: context.text.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'A supportive space to talk things through, any time — '
                'non-judgmental, and always in your corner.',
                style: context.text.bodyMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 12),
              Text(
                'To keep your API key safe, the app talks only to your own '
                'backend, which holds the key and adds the companion’s '
                'instructions. Add your backend URL and access token to begin.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted, height: 1.45),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Connect backend',
                icon: Icons.link,
                onPressed: () => CompanionSetupSheet.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A prominent, calm banner surfaced when a crisis is flagged. Never the only
/// signal — the resources also open automatically — but always reachable.
class _CrisisBanner extends ConsumerWidget {
  const _CrisisBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final support = context.palette.support;
    return Material(
      color: Color.alphaBlend(
        support.withValues(alpha: 0.14),
        context.colors.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.favorite, color: support),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'It sounds really hard right now',
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'You deserve real support. Reaching a person can help.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => CrisisResourcesSheet.show(context),
              style: FilledButton.styleFrom(
                backgroundColor: support,
                foregroundColor: context.palette.onSupport,
              ),
              child: const Text('Get help'),
            ),
            IconButton(
              tooltip: 'Dismiss',
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(chatProvider.notifier).dismissCrisis(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The message composer — a rounded field plus a send button that stays out of
/// the way until there's something to say.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.palette.field,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Say what’s on your mind…',
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = !sending && value.text.trim().isNotEmpty;
                return _SendButton(enabled: canSend, sending: sending, onTap: onSend);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.onTap,
  });

  final bool enabled;
  final bool sending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send message',
      child: SizedBox(
        width: 48,
        height: 48,
        child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const Icon(Icons.arrow_upward, size: 22),
        ),
      ),
    );
  }
}
