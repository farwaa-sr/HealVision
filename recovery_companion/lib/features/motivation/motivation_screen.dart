import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_card.dart';
import '../sos/providers/sos_providers.dart';
import 'model/quote.dart';
import 'model/quote_library.dart';
import 'providers/motivation_providers.dart';

/// Motivation — a grounded daily message, your own reasons and mantras (shared
/// with the SOS toolkit), saved favorites, and a browsable, themed library.
class MotivationScreen extends ConsumerStatefulWidget {
  const MotivationScreen({super.key});

  @override
  ConsumerState<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends ConsumerState<MotivationScreen> {
  int _offset = 0; // for "show another" on the daily card
  QuoteTheme? _themeFilter;
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _toggleFav(String id) async {
    await ref.read(motivationRepositoryProvider).toggleFavorite(id);
    ref.invalidate(favoriteQuoteIdsProvider);
  }

  Future<void> _addReason(List<String> current) async {
    final text = _reason.text.trim();
    if (text.isEmpty) return;
    await ref.read(cravingRepositoryProvider).saveReasons([...current, text]);
    _reason.clear();
    ref.invalidate(reasonsProvider);
  }

  Future<void> _removeReason(List<String> current, int i) async {
    final updated = [...current]..removeAt(i);
    await ref.read(cravingRepositoryProvider).saveReasons(updated);
    ref.invalidate(reasonsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final daily = ref.watch(dailyQuoteProvider);
    final favorites =
        ref.watch(favoriteQuoteIdsProvider).valueOrNull ?? const <String>{};
    final reasons = ref.watch(reasonsProvider).valueOrNull ?? const <String>[];

    final dailyIndex = kQuotes.indexWhere((q) => q.id == daily.id);
    final shown = kQuotes[(dailyIndex + _offset) % kQuotes.length];

    final browse = _themeFilter == null
        ? kQuotes
        : kQuotes.where((q) => q.theme == _themeFilter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Motivation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // Daily message
          _QuoteCard(
            quote: shown,
            isFavorite: favorites.contains(shown.id),
            onToggleFav: () => _toggleFav(shown.id),
            big: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _offset++),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Another'),
            ),
          ),
          const SizedBox(height: 16),

          // My reasons & mantras (shared with SOS)
          Text('My reasons & mantras', style: context.text.titleMedium),
          const SizedBox(height: 4),
          Text('In your own words. These also appear in the SOS toolkit.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.palette.muted),),
          const SizedBox(height: 12),
          for (var i = 0; i < reasons.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.favorite,
                        size: 18, color: context.palette.support,),
                    const SizedBox(width: 12),
                    Expanded(child: Text(reasons[i])),
                    InkWell(
                      onTap: () => _removeReason(reasons, i),
                      child: Icon(Icons.close,
                          size: 18, color: context.palette.muted,),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _reason,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(hintText: 'Add a reason or mantra…'),
                  onSubmitted: (_) => _addReason(reasons),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _addReason(reasons),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Favorites
          if (favorites.isNotEmpty) ...[
            Text('Your favorites', style: context.text.titleMedium),
            const SizedBox(height: 12),
            for (final q in kQuotes.where((q) => favorites.contains(q.id))) ...[
              _QuoteCard(
                quote: q,
                isFavorite: true,
                onToggleFav: () => _toggleFav(q.id),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
          ],

          // Browse by theme
          Text('Browse', style: context.text.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _themeFilter == null,
                showCheckmark: false,
                onSelected: (_) => setState(() => _themeFilter = null),
              ),
              for (final t in QuoteTheme.values)
                ChoiceChip(
                  label: Text(t.label),
                  selected: _themeFilter == t,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _themeFilter = t),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final q in browse) ...[
            _QuoteCard(
              quote: q,
              isFavorite: favorites.contains(q.id),
              onToggleFav: () => _toggleFav(q.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.isFavorite,
    required this.onToggleFav,
    this.big = false,
  });

  final Quote quote;
  final bool isFavorite;
  final VoidCallback onToggleFav;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: big
          ? Color.alphaBlend(
              context.palette.accent.withValues(alpha: 0.16),
              context.palette.surfaceElevated,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (big)
            Icon(Icons.format_quote_rounded, color: context.colors.primary),
          if (big) const SizedBox(height: 8),
          Text(
            quote.text,
            style:
                big ? context.text.titleMedium : context.text.bodyLarge,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.palette.field,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(quote.theme.label,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.muted),),
              ),
              const Spacer(),
              InkWell(
                onTap: onToggleFav,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? context.palette.support
                        : context.palette.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
