import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/sos_providers.dart';

/// "Reasons I'm doing this" — the user's own saved motivations, right when they
/// need reminding. Editable inline so it grows with them.
class ReasonsScreen extends ConsumerStatefulWidget {
  const ReasonsScreen({super.key});

  @override
  ConsumerState<ReasonsScreen> createState() => _ReasonsScreenState();
}

class _ReasonsScreenState extends ConsumerState<ReasonsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add(List<String> current) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref
        .read(cravingRepositoryProvider)
        .saveReasons([...current, text]);
    _controller.clear();
    ref.invalidate(reasonsProvider);
  }

  Future<void> _remove(List<String> current, int index) async {
    final updated = [...current]..removeAt(index);
    await ref.read(cravingRepositoryProvider).saveReasons(updated);
    ref.invalidate(reasonsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(reasonsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Reasons I'm doing this")),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => const Center(child: Text('Could not load.')),
        data: (reasons) => Column(
          children: [
            Expanded(
              child: reasons.isEmpty
                  ? const EmptyState(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Your reasons, in your words',
                      message:
                          'Add the reasons this matters to you. They\'ll be here '
                          'waiting whenever you need reminding.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      children: [
                        Text(
                          'Remember why you started:',
                          style: context.text.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < reasons.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              child: Row(
                                children: [
                                  Icon(Icons.favorite,
                                      color: context.palette.support, size: 20,),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(reasons[i],
                                        style: context.text.bodyLarge,),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        size: 18, color: context.palette.muted,),
                                    onPressed: () => _remove(reasons, i),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
                  top: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Add a reason…',
                        ),
                        onSubmitted: (_) => _add(reasons),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _add(reasons),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
