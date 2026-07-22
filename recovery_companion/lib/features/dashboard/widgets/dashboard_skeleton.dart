import 'package:flutter/material.dart';

import '../../../shared/widgets/skeleton.dart';

/// Loading placeholder that mirrors the dashboard layout, so the transition to
/// real content is calm and non-jarring. Scrollable so pull-to-refresh works
/// while loading.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: const [
        // Greeting
        SkeletonBox(width: 200, height: 26),
        SizedBox(height: 8),
        SkeletonBox(width: 120, height: 14),
        SizedBox(height: 28),
        // Sober centerpiece ring
        Center(
          child: SkeletonBox(width: 150, height: 150, shape: BoxShape.circle),
        ),
        SizedBox(height: 28),
        // SOS card
        SkeletonBox(height: 88, borderRadius: null),
        SizedBox(height: 24),
        // Quick stats row
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 84)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 84)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 84)),
          ],
        ),
        SizedBox(height: 28),
        // Today
        SkeletonBox(width: 80, height: 18),
        SizedBox(height: 12),
        SkeletonBox(height: 140),
        SizedBox(height: 24),
        // Motivation
        SkeletonBox(height: 96),
      ],
    );
  }
}
