import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/haptics.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/mood_selector.dart';
import 'providers/checkin_providers.dart';
import 'widgets/quick_trigger_sheet.dart';
import 'widgets/scale_picker.dart';

/// A fast daily check-in — under a minute. Mood, energy, sleep, and today's
/// craving are quick taps; everything else is optional context. This powers the
/// app's pattern awareness.
class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  Mood? _mood;
  int? _energy;
  int? _sleep;
  double _craving = 0;

  bool _showContext = false;
  final _note = TextEditingController();
  String? _company;
  String? _place;
  double _stress = 3;

  bool _saved = false;

  static const _companies = ['Alone', 'Friends', 'Family', 'Partner', 'Coworkers'];
  static const _places = ['Home', 'Work', 'Out', 'Party', 'Travelling'];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _canSave => _mood != null && _energy != null && _sleep != null;

  Future<void> _save() async {
    // Mood enum: great(0)…struggling(4) → numeric 5…1.
    final moodValue = 5 - _mood!.index;
    await ref.read(checkInRepositoryProvider).saveCheckIn(
          mood: moodValue,
          energy: _energy!,
          sleepQuality: _sleep!,
          cravingLevel: _craving.round(),
          stressLevel: _showContext ? _stress.round() : null,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          company: _company,
          place: _place,
        );
    unawaited(Haptics.success());
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily check-in'),
        actions: [
          IconButton(
            tooltip: 'Your patterns',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.pushNamed(AppRoute.insights.routeName),
          ),
        ],
      ),
      body: _saved ? _success(context) : _form(context),
    );
  }

  Widget _success(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.palette.success.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.check_rounded,
                  size: 36, color: context.palette.success,),
            ),
            const SizedBox(height: 16),
            Text('Thanks for checking in', style: context.text.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Little by little, this builds a picture of what helps you — your '
              'mirror, not a scoreboard.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.palette.muted),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'See your patterns',
              onPressed: () => context.pushReplacementNamed(
                  AppRoute.insights.routeName,),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Done',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final already = ref.watch(checkedInTodayProvider).valueOrNull ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        if (already)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "You've already checked in today — but you're welcome to add "
              'another any time.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.palette.muted),
            ),
          ),

        // Quick craving/trigger log — available any time.
        OutlinedButton.icon(
          onPressed: () => QuickTriggerSheet.show(context),
          icon: const Icon(Icons.bolt_outlined),
          label: const Text('Log a craving or trigger'),
        ),
        const SizedBox(height: 20),

        Text('How\'s your mood?', style: context.text.titleMedium),
        const SizedBox(height: 12),
        MoodSelector(value: _mood, onChanged: (m) => setState(() => _mood = m)),
        const SizedBox(height: 24),

        Text('Energy', style: context.text.titleMedium),
        const SizedBox(height: 10),
        ScalePicker(
          value: _energy,
          onChanged: (v) => setState(() => _energy = v),
          lowLabel: 'Drained',
          highLabel: 'Energised',
        ),
        const SizedBox(height: 24),

        Text('How did you sleep?', style: context.text.titleMedium),
        const SizedBox(height: 10),
        ScalePicker(
          value: _sleep,
          onChanged: (v) => setState(() => _sleep = v),
          lowLabel: 'Poorly',
          highLabel: 'Great',
        ),
        const SizedBox(height: 24),

        Text('Craving level today', style: context.text.titleMedium),
        Slider(
          value: _craving,
          min: 0,
          max: 10,
          divisions: 10,
          label: _craving.round().toString(),
          onChanged: (v) => setState(() => _craving = v),
        ),
        const SizedBox(height: 8),

        // Optional context (kept collapsed so the core stays fast).
        _ContextSection(
          expanded: _showContext,
          onToggle: () => setState(() => _showContext = !_showContext),
          note: _note,
          company: _company,
          place: _place,
          stress: _stress,
          companies: _companies,
          places: _places,
          onCompany: (c) => setState(() => _company = _company == c ? null : c),
          onPlace: (p) => setState(() => _place = _place == p ? null : p),
          onStress: (v) => setState(() => _stress = v),
        ),
        const SizedBox(height: 24),

        AppButton(
          label: 'Save check-in',
          onPressed: _canSave ? _save : null,
        ),
        if (!_canSave) ...[
          const SizedBox(height: 8),
          Center(
            child: Text('Mood, energy, and sleep to finish',
                style: context.text.bodySmall
                    ?.copyWith(color: context.palette.muted),),
          ),
        ],
      ],
    );
  }
}

class _ContextSection extends StatelessWidget {
  const _ContextSection({
    required this.expanded,
    required this.onToggle,
    required this.note,
    required this.company,
    required this.place,
    required this.stress,
    required this.companies,
    required this.places,
    required this.onCompany,
    required this.onPlace,
    required this.onStress,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final TextEditingController note;
  final String? company;
  final String? place;
  final double stress;
  final List<String> companies;
  final List<String> places;
  final ValueChanged<String> onCompany;
  final ValueChanged<String> onPlace;
  final ValueChanged<double> onStress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text('Add a little context (optional)',
                    style: context.text.titleMedium,),
                const Spacer(),
                Icon(expanded ? Icons.expand_less : Icons.expand_more,
                    color: context.palette.muted,),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          Text('Who were you with?',
              style: context.text.labelLarge
                  ?.copyWith(color: context.palette.muted),),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final c in companies)
                AppChip(
                  label: c,
                  selected: company == c,
                  onSelected: (_) => onCompany(c),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Where were you?',
              style: context.text.labelLarge
                  ?.copyWith(color: context.palette.muted),),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in places)
                AppChip(
                  label: p,
                  selected: place == p,
                  onSelected: (_) => onPlace(p),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Stress level',
              style: context.text.labelLarge
                  ?.copyWith(color: context.palette.muted),),
          Slider(
            value: stress,
            min: 0,
            max: 10,
            divisions: 10,
            label: stress.round().toString(),
            onChanged: onStress,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: note,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: "Anything on your mind? (optional)",
            ),
          ),
        ],
      ],
    );
  }
}
