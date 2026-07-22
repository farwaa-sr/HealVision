import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import 'tools/breathing_screen.dart';
import 'tools/grounding_screen.dart';
import 'tools/play_tape_screen.dart';
import 'tools/reach_out_sheet.dart';
import 'tools/reasons_screen.dart';
import 'tools/urge_surf_screen.dart';
import 'widgets/craving_wrapup_sheet.dart';
import 'widgets/tool_card.dart';

/// The SOS "I'm craving" toolkit — the most important screen. Opens in one tap
/// from anywhere, loads instantly, works fully offline. Steady and grounding,
/// never alarmed.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final DateTime _startedAt = DateTime.now();

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You\'re not alone'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          // Calm, grounding greeting.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                context.colors.primary.withValues(alpha: 0.10),
                context.palette.surfaceElevated,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This will pass.', style: context.text.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  "Let's get through the next few minutes together. Pick "
                  'whatever feels right — there\'s no wrong choice here.',
                  style: context.text.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ToolCard(
            icon: Icons.waves,
            title: 'Ride the wave',
            subtitle: 'Urge surfing — it peaks and passes in ~20 min',
            onTap: () => _push(const UrgeSurfScreen()),
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: Icons.air,
            title: 'Breathe',
            subtitle: 'A slow, guided breathing pacer',
            onTap: () => _push(const BreathingScreen()),
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: Icons.spa_outlined,
            title: 'Ground yourself',
            subtitle: '5-4-3-2-1 — come back to right now',
            onTap: () => _push(const GroundingScreen()),
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: Icons.movie_outlined,
            title: 'Play the tape forward',
            subtitle: 'See the whole picture before deciding',
            onTap: () => _push(const PlayTapeScreen()),
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: Icons.sports_esports_outlined,
            title: 'Distract yourself',
            subtitle: 'Do something rewarding instead',
            onTap: () => context.goNamed(AppRoute.activities.routeName),
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: Icons.people_outline,
            title: 'Reach out',
            subtitle: 'Call or text someone who helps',
            accent: context.palette.support,
            onTap: () => ReachOutSheet.show(context),
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: Icons.favorite_outline,
            title: "Reasons I'm doing this",
            subtitle: 'Remember why you started',
            accent: context.palette.accent,
            onTap: () => _push(const ReasonsScreen()),
          ),

          const SizedBox(height: 28),
          AppButton(
            label: 'The craving has passed',
            onPressed: () => CravingWrapupSheet.show(context, _startedAt),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'You can leave any time. Just being here helped.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.palette.muted),
            ),
          ),
        ],
      ),
    );
  }
}
