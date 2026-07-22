import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../model/notification_settings.dart';

/// Thin wrapper over flutter_local_notifications + timezone. Owns plugin init,
/// permission requests, per-category channels, and the low-level schedule/show
/// calls. All copy and timing decisions live above this, in the scheduler.
///
/// Every call is defensive: if the platform plugin isn't available (e.g. before
/// native folders exist, or on an unsupported target) it degrades to a no-op
/// rather than throwing, so the rest of the app is never affected.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _tzReady = false;

  bool get isReady => _initialized && _tzReady;

  /// Fixed id for the "send a test" preview so repeats replace, not stack.
  static const int previewId = 9000;

  Future<void> init() async {
    if (_initialized) return;

    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      _tzReady = true;
    } catch (e) {
      debugPrint('Notification timezone init skipped: $e');
    }

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
      );
      await _createChannels();
      _initialized = true;
    } catch (e) {
      debugPrint('Notification init skipped: $e');
    }
  }

  /// Asks the OS for permission (Android 13+, iOS). Returns true if granted (or
  /// if there's nothing to ask). Never throws.
  Future<bool> requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      var granted = true;
      if (android != null) {
        granted = (await android.requestNotificationsPermission()) ?? granted;
      }
      if (ios != null) {
        granted = (await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            )) ??
            granted;
      }
      return granted;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    for (final c in NotifCategory.values) {
      final (id, name) = _channel(c);
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          id,
          name,
          description: c.blurb,
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  (String, String) _channel(NotifCategory c) => switch (c) {
        NotifCategory.checkIn => ('checkin', 'Daily check-in'),
        NotifCategory.activities => ('activities', 'Activity reminders'),
        NotifCategory.riskNudges => ('nudges', 'Supportive nudges'),
        NotifCategory.milestones => ('milestones', 'Milestone celebrations'),
        NotifCategory.motivation => ('motivation', 'Daily motivation'),
      };

  NotificationDetails _details(NotifCategory c) {
    final (id, name) = _channel(c);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        channelDescription: c.blurb,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Schedules a one-shot notification at [when] (local time). Silently skips
  /// times in the past or when the plugin/timezone isn't ready.
  Future<void> schedule({
    required int id,
    required NotifCategory category,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    if (!isReady) return;
    try {
      final scheduled = tz.TZDateTime.from(when, tz.local);
      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details(category),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Notification schedule failed ($id): $e');
    }
  }

  /// Fires a notification immediately — used by the "send a test" preview.
  Future<void> showNow({
    required NotifCategory category,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(previewId, title, body, _details(category));
    } catch (e) {
      debugPrint('Notification show failed: $e');
    }
  }

  /// Whether the OS currently lets the app post notifications. Best-effort;
  /// assumes allowed when it can't tell (e.g. iOS before a request).
  Future<bool> areEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return (await android.areNotificationsEnabled()) ?? true;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Notification cancelAll failed: $e');
    }
  }

  Future<int> pendingCount() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.length;
    } catch (_) {
      return 0;
    }
  }
}
