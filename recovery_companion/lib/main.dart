import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/secure_store_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/secure_store.dart';
import 'features/crisis/providers/crisis_providers.dart';
import 'features/crisis/widgets/crisis_help_button.dart';
import 'features/notifications/data/notification_service.dart';
import 'features/notifications/providers/notification_providers.dart';
import 'features/onboarding/onboarding_providers.dart';
import 'features/security/app_lock_gate.dart';
import 'shared/widgets/app_error_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App-wide error boundary: replace Flutter's red error screen with a calm,
  // reassuring fallback so a failure never feels alarming to the user.
  ErrorWidget.builder = (details) => const AppErrorView();

  // Initialize local notifications up front (no-op if the platform plugin
  // isn't available yet). Skipped on web, which has no local-notification
  // plugin — this build is a UI preview only.
  final notifications = NotificationService();
  if (!kIsWeb) await notifications.init();

  // Read the onboarding flag before the first frame so the router can route
  // straight to onboarding on a fresh install without a flash of the app.
  final secureStore = SecureStore();
  final onboardingDone =
      (await secureStore.read(kOnboardingDoneKey)) == 'true';

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
        secureStoreProvider.overrideWithValue(secureStore),
        onboardingDoneProvider.overrideWith((ref) => onboardingDone),
      ],
      child: const RecoveryCompanionApp(),
    ),
  );
}

class RecoveryCompanionApp extends ConsumerStatefulWidget {
  const RecoveryCompanionApp({super.key});

  @override
  ConsumerState<RecoveryCompanionApp> createState() =>
      _RecoveryCompanionAppState();
}

class _RecoveryCompanionAppState extends ConsumerState<RecoveryCompanionApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Keep the notification plan fresh, and lift any legacy single SOS
      // contact into the new support-contacts store.
      if (!kIsWeb) ref.read(notificationSchedulerProvider).rescheduleAll();
      ref.read(supportContactsRepositoryProvider).migrateLegacyIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      // App lock covers content; the crisis button floats above everything —
      // including the lock screen — so help is reachable from every screen.
      builder: (context, child) =>
          _AppShell(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Wraps every screen with the app-lock cover and the always-on crisis button.
/// The crisis button mounts one frame late so it never joins the very first
/// focus pass — which, on web, can run ahead of the first layout.
class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  bool _showHelp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showHelp = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppLockGate(child: widget.child),
        if (_showHelp) const CrisisHelpButton(),
      ],
    );
  }
}
