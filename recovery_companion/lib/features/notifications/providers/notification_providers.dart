import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../activities/providers/activities_providers.dart';
import '../../checkin/providers/checkin_providers.dart';
import '../../tracker/providers/tracker_providers.dart';
import '../data/notification_scheduler.dart';
import '../data/notification_service.dart';
import '../data/notification_settings_repository.dart';
import '../logic/notification_copy.dart';
import '../model/notification_settings.dart';

part 'notification_providers.g.dart';

/// The plugin wrapper. Overridden in `main()` with an already-initialized
/// instance so scheduling works from the very first frame.
@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

@Riverpod(keepAlive: true)
NotificationSettingsRepository notificationSettingsRepository(
  NotificationSettingsRepositoryRef ref,
) {
  return NotificationSettingsRepository(ref.watch(appDatabaseProvider));
}

/// Whether the OS currently permits notifications (drives the settings banner).
@riverpod
Future<bool> notificationsPermitted(NotificationsPermittedRef ref) {
  return ref.watch(notificationServiceProvider).areEnabled();
}

@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(NotificationSchedulerRef ref) {
  return NotificationScheduler(
    service: ref.watch(notificationServiceProvider),
    settingsRepo: ref.watch(notificationSettingsRepositoryProvider),
    checkInRepo: ref.watch(checkInRepositoryProvider),
    activitiesRepo: ref.watch(activitiesRepositoryProvider),
    trackerRepo: ref.watch(soberTrackerRepositoryProvider),
  );
}

/// Editable notification preferences for the settings screen. Every change is
/// persisted and triggers a full reschedule, so the plan always matches the UI.
@riverpod
class NotificationSettingsController extends _$NotificationSettingsController {
  @override
  Future<NotificationSettings> build() {
    return ref.watch(notificationSettingsRepositoryProvider).load();
  }

  /// Persists [next] and rebuilds the whole notification plan to match.
  Future<void> apply(NotificationSettings next) async {
    state = AsyncData(next);
    await ref.read(notificationSettingsRepositoryProvider).save(next);
    await ref.read(notificationSchedulerProvider).rescheduleAll();
  }

  /// Asks the OS for notification permission; returns whether it's granted.
  Future<bool> requestPermissions() {
    return ref.read(notificationServiceProvider).requestPermissions();
  }

  /// Fires a sample notification so the user can see how a category looks.
  Future<void> sendTest(NotifCategory category) async {
    final sample = NotificationCopy.sampleFor(category);
    await ref.read(notificationServiceProvider).showNow(
          category: category,
          title: sample.title,
          body: sample.body,
        );
  }
}
