import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/tracker_providers.dart';

/// Bottom sheet to start tracking a substance. Only a name is required; the
/// daily cost is optional and only used to estimate money saved.
class AddSubstanceSheet extends ConsumerStatefulWidget {
  const AddSubstanceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddSubstanceSheet(),
    );
  }

  @override
  ConsumerState<AddSubstanceSheet> createState() => _AddSubstanceSheetState();
}

class _AddSubstanceSheetState extends ConsumerState<AddSubstanceSheet> {
  final _name = TextEditingController();
  final _cost = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final cost = double.tryParse(_cost.text.trim()) ?? 0;
    await ref
        .read(soberTrackerRepositoryProvider)
        .addSubstance(name: name, dailyCost: cost);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you recovering from?',
              style: context.text.titleLarge,),
          const SizedBox(height: 4),
          Text(
            'You can track more than one thing. Use whatever name feels right.',
            style: context.text.bodyMedium?.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. Alcohol, Nicotine'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cost,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Daily cost (optional)',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: _saving ? 'Starting…' : 'Start tracking',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
