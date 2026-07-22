import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../data/repositories/user/user_repoistory.dart';

/// Handles FCM device-token registration so the `sendCheckinReminder`
/// Cloud Function can deliver check-in / reminder pushes to this device.
///
/// The reminders are sent as `notification` payloads, which the OS displays
/// automatically — the app only needs to register (and refresh) its token.
class NotificationService extends GetxService {
  static NotificationService get instance => Get.find();

  final _messaging = FirebaseMessaging.instance;
  final _userRepository = Get.put(UserRepository());

  /// Call once the user is authenticated (uid known).
  Future<void> registerFor(String userId) async {
    if (userId.isEmpty) return;
    try {
      await _messaging.requestPermission();

      final token = await _messaging.getToken();
      if (token != null) {
        await _userRepository.saveDeviceToken(userId, token);
      }

      // Persist future token rotations too.
      _messaging.onTokenRefresh.listen((newToken) {
        _userRepository.saveDeviceToken(userId, newToken);
      });
    } catch (_) {
      // Non-fatal: reminders simply won't reach this device.
    }
  }
}
