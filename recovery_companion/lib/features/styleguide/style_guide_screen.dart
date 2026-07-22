import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/mood_selector.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/sos_button.dart';

/// Internal style guide — showcases every component under both themes so the
/// look can be reviewed at a glance. Toggle Light / Dark at the top.
class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  Brightness _brightness = Brightness.light;
  Mood? _mood = Mood.good;
  int _selectedChip = 0;

  @override
  Widget build(BuildContext context) {
    final previewTheme =
        _brightness == Brightness.light ? AppTheme.light : AppTheme.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Style Guide')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<Brightness>(
              segments: const [
                ButtonSegment(
                  value: Brightness.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: Brightness.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {_brightness},
              onSelectionChanged: (s) =>
                  setState(() => _brightness = s.first),
            ),
          ),
          Expanded(
            child: Theme(
              data: previewTheme,
              child: Builder(
                builder: (context) => ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                    children: [
                      _colors(context),
                      _typography(context),
                      _buttons(context),
                      _sos(context),
                      _chips(context),
                      _moodSection(context),
                      _rings(context),
                      _cards(context),
                      _emptyState(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _swatch(BuildContext context, String name, Color bg, Color fg) {
    return Container(
      width: 104,
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      alignment: Alignment.bottomLeft,
      child: Text(
        name,
        style: context.text.bodySmall?.copyWith(color: fg),
      ),
    );
  }

  Widget _colors(BuildContext context) {
    final p = context.palette;
    final c = context.colors;
    return _section(
      context,
      'Colors',
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _swatch(context, 'Primary', c.primary, c.onPrimary),
          _swatch(context, 'Accent', p.accent, p.onAccent),
          _swatch(context, 'Success', p.success, p.onSuccess),
          _swatch(context, 'SOS', p.support, p.onSupport),
          _swatch(context, 'Surface', p.surfaceElevated, c.onSurface),
          _swatch(context, 'Field', p.field, c.onSurface),
        ],
      ),
    );
  }

  Widget _typography(BuildContext context) {
    final t = context.text;
    return _section(
      context,
      'Typography',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display Small', style: t.displaySmall),
          Text('Headline Medium', style: t.headlineMedium),
          Text('Headline Small', style: t.headlineSmall),
          Text('Title Large', style: t.titleLarge),
          Text('Title Medium', style: t.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Body Large — the app should feel like it can breathe, with '
            'generous line height and warmth.',
            style: t.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Body Medium — calm, legible, unhurried.',
            style: t.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return _section(
      context,
      'Buttons',
      Column(
        children: [
          AppButton(label: 'Primary action', onPressed: () {}),
          const SizedBox(height: 10),
          AppButton(
            label: 'Tonal action',
            variant: AppButtonVariant.tonal,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Secondary action',
            variant: AppButtonVariant.secondary,
            icon: Icons.check_circle_outline,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          const AppButton(label: 'Disabled', onPressed: null),
        ],
      ),
    );
  }

  Widget _sos(BuildContext context) {
    return _section(
      context,
      'SOS / “I’m craving”',
      SosButton(onPressed: () {}),
    );
  }

  Widget _chips(BuildContext context) {
    const labels = ['Mood', 'Stress', 'Boredom', 'Social'];
    return _section(
      context,
      'Chips',
      Wrap(
        spacing: 8,
        children: [
          for (var i = 0; i < labels.length; i++)
            AppChip(
              label: labels[i],
              selected: _selectedChip == i,
              onSelected: (_) => setState(() => _selectedChip = i),
            ),
        ],
      ),
    );
  }

  Widget _moodSection(BuildContext context) {
    return _section(
      context,
      'Mood selector',
      MoodSelector(
        value: _mood,
        onChanged: (m) => setState(() => _mood = m),
      ),
    );
  }

  Widget _rings(BuildContext context) {
    return _section(
      context,
      'Progress rings',
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProgressRing(
            value: 0.72,
            size: 96,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('12', style: context.text.headlineSmall),
                Text('days', style: context.text.bodySmall),
              ],
            ),
          ),
          ProgressRing(
            value: 0.4,
            size: 96,
            color: context.palette.success,
            center: Text('40%', style: context.text.titleMedium),
          ),
        ],
      ),
    );
  }

  Widget _cards(BuildContext context) {
    return _section(
      context,
      'Cards',
      AppCard(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tappable card', style: context.text.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Soft shadow, rounded corners, a gentle press animation.',
              style: context.text.bodyMedium
                  ?.copyWith(color: context.palette.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return _section(
      context,
      'Empty state',
      SizedBox(
        height: 260,
        child: EmptyState(
          icon: Icons.spa_outlined,
          title: 'Nothing here yet',
          message: 'When you log your first check-in, it\'ll show up here.',
          actionLabel: 'Add a check-in',
          onAction: () {},
        ),
      ),
    );
  }
}
