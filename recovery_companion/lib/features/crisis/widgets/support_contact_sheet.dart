import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/crisis_providers.dart';

/// Add or edit a personal support contact (sponsor, friend, family).
class SupportContactSheet extends ConsumerStatefulWidget {
  const SupportContactSheet({super.key, this.existing});

  final SupportContactRow? existing;

  static Future<void> show(BuildContext context, {SupportContactRow? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SupportContactSheet(existing: existing),
    );
  }

  @override
  ConsumerState<SupportContactSheet> createState() => _SupportContactSheetState();
}

class _SupportContactSheetState extends ConsumerState<SupportContactSheet> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _relationship =
      TextEditingController(text: widget.existing?.relationship ?? '');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relationship.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    final rel = _relationship.text.trim().isEmpty
        ? null
        : _relationship.text.trim();
    final repo = ref.read(supportContactsRepositoryProvider);
    final existing = widget.existing;
    if (existing == null) {
      await repo.add(name: name, phone: phone, relationship: rel);
    } else {
      await repo.updateContact(
        id: existing.id,
        name: name,
        phone: phone,
        relationship: rel,
      );
    }
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
          Text(
            widget.existing == null ? 'Add a support person' : 'Edit contact',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Someone you trust — a sponsor, a friend, family. One tap to reach '
            'them when it helps.',
            style: context.text.bodySmall
                ?.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Phone number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _relationship,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Relationship (optional) — e.g. Sponsor',
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: widget.existing == null ? 'Save contact' : 'Save changes',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
