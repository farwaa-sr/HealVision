import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../model/activity_meta.dart';
import '../providers/activities_providers.dart';

/// Add your own replacement activity to the library.
class AddCustomSheet extends ConsumerStatefulWidget {
  const AddCustomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddCustomSheet(),
    );
  }

  @override
  ConsumerState<AddCustomSheet> createState() => _AddCustomSheetState();
}

class _AddCustomSheetState extends ConsumerState<AddCustomSheet> {
  final _title = TextEditingController();
  final _reason = TextEditingController();
  ActivityCategory _category = ActivityCategory.selfCare;
  final Set<Need> _needs = {};

  @override
  void dispose() {
    _title.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    await ref.read(activitiesRepositoryProvider).addCustom(
          title: title,
          category: _category,
          reason: _reason.text.trim(),
          needs: _needs.toList(),
        );
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add your own', style: context.text.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(hintText: 'What would you like to do?'),
            ),
            const SizedBox(height: 16),
            Text('Category',
                style: context.text.labelLarge
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 8),
            DropdownButtonFormField<ActivityCategory>(
              initialValue: _category,
              items: [
                for (final c in ActivityCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 16),
            Text('What does it help with? (optional)',
                style: context.text.labelLarge
                    ?.copyWith(color: context.palette.muted),),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final n in Need.values)
                  AppChip(
                    label: n.name,
                    selected: _needs.contains(n),
                    onSelected: (_) => setState(() {
                      if (!_needs.add(n)) _needs.remove(n);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reason,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Why does this help you? (optional)',
              ),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Add to my library', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
