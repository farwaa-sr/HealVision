# Notifications — native setup

The Dart side is done and self-contained: scheduling, quiet hours, copy, and the
settings screen all work as soon as the platform plugin has a native home. This
project doesn't have `android/` or `ios/` folders yet, so do this once.

## 0. Add the platforms

From the project root:

```bash
flutter create .
```

This generates `android/` and `ios/` without touching `lib/`. Then `flutter pub get`.

## 1. Android

`flutter_local_notifications` needs three things on Android.

**a) Core library desugaring** (required by the plugin). In
`android/app/build.gradle` (or `build.gradle.kts`):

```gradle
android {
  compileOptions {
    coreLibraryDesugaringEnabled true      // Kotlin DSL: isCoreLibraryDesugaringEnabled = true
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
  }
}
dependencies {
  coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

**b) Manifest** — `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

and inside `<application>`:

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

> We schedule with **inexact** alarms on purpose (gentle, not to-the-second), so
> you do **not** need `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` and won't trip
> Android 14's exact-alarm restrictions.

**c) Notification icon** (optional but nicer): add a small white, transparent
`ic_stat_notify.png` to `res/drawable-*` and pass it to
`AndroidInitializationSettings('ic_stat_notify')` in
`notification_service.dart`. The current default is `@mipmap/ic_launcher`, which
works out of the box.

## 2. iOS

In `ios/Runner/AppDelegate.swift`, register the delegate so scheduled
notifications present while the app is foregrounded:

```swift
import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

No Info.plist changes are needed — permission is requested at runtime (the app
does this from the notification settings screen, and again the first time it
schedules).

## 3. That's it

- Timezone data is bundled by the `timezone` package — no native config.
- The app initializes the plugin in `main()` and reschedules on every launch,
  after saving settings, and after you plan an activity.
- Until the platforms are added, the app still builds and analyzes cleanly; the
  notification calls simply no-op.
