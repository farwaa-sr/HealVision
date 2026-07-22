import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/activities_screen.dart';
import '../../features/checkin/checkin_screen.dart';
import '../../features/companion/companion_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/goals/goal_detail_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/motivation/motivation_screen.dart';
import '../../features/notifications/notification_settings_screen.dart';
import '../../features/onboarding/onboarding_providers.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/privacy/privacy_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/sos/sos_screen.dart';
import '../../features/styleguide/style_guide_screen.dart';
import '../../features/tracker/substance_detail_screen.dart';
import '../../features/tracker/tracker_screen.dart';
import 'app_routes.dart';
import 'navigator_keys.dart';
import 'scaffold_with_nav.dart';

/// App router. Exposed as a Riverpod provider so features can later react to
/// auth / onboarding state via `ref`.
final goRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingDoneProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoute.dashboard.path,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == AppRoute.onboarding.path;
      if (!onboardingDone && !atOnboarding) return AppRoute.onboarding.path;
      if (onboardingDone && atOnboarding) return AppRoute.dashboard.path;
      return null;
    },
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Persistent bottom-nav shell (Home / Activities / Companion / Progress / Me).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.dashboard.path,
                name: AppRoute.dashboard.routeName,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.activities.path,
                name: AppRoute.activities.routeName,
                builder: (context, state) => const ActivitiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.companion.path,
                name: AppRoute.companion.routeName,
                builder: (context, state) => const CompanionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.progress.path,
                name: AppRoute.progress.routeName,
                builder: (context, state) => const TrackerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.me.path,
                name: AppRoute.me.routeName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Pushed on top of the shell (full-screen, reachable from anywhere).
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.sos.path,
        name: AppRoute.sos.routeName,
        builder: (context, state) => const SosScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.checkin.path,
        name: AppRoute.checkin.routeName,
        builder: (context, state) => const CheckinScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.goals.path,
        name: AppRoute.goals.routeName,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.motivation.path,
        name: AppRoute.motivation.routeName,
        builder: (context, state) => const MotivationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.insights.path,
        name: AppRoute.insights.routeName,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.notifications.path,
        name: AppRoute.notifications.routeName,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.privacy.path,
        name: AppRoute.privacy.routeName,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '${AppRoute.substanceDetail.path}/:id',
        name: AppRoute.substanceDetail.routeName,
        builder: (context, state) => SubstanceDetailScreen(
          substanceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '${AppRoute.goalDetail.path}/:id',
        name: AppRoute.goalDetail.routeName,
        builder: (context, state) => GoalDetailScreen(
          goalId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoute.styleGuide.path,
        name: AppRoute.styleGuide.routeName,
        builder: (context, state) => const StyleGuideScreen(),
      ),
    ],
  );
});
