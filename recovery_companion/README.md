# Recovery Companion

A calm, private, non-judgmental recovery companion. Local-first, Flutter, Material 3.

> **Clinical north star** — no shame; compassionate relapse handling; in-the-moment
> help first; pattern awareness over willpower; behavioral activation; connection;
> escalate real risk. Every screen honors these.

## Architecture

- **State:** Riverpod (`flutter_riverpod` + `riverpod_annotation`, code-gen providers)
- **Routing:** `go_router` with a persistent bottom nav — Home / Activities / Companion / Progress / Me — plus an always-available **Support now (SOS)** button
- **Storage:** local-first **Drift** (SQLite) for structured data; **flutter_secure_storage** for secrets
- **Layers:**
  - `lib/core` — theme, constants, routing, providers
  - `lib/data` — models, repositories, local db (Drift + secure store)
  - `lib/features` — `dashboard`, `activities`, `companion`, `tracker`, `settings`, `sos`, `checkin`, `goals`, `motivation`
  - `lib/shared` — reusable widgets (loading, error view, feature scaffold)

## First-time setup

This repo contains the Dart application layer + config. Two steps generate the
native platform folders and the code-gen output, then it runs.

### 1. Backfill the native `android/` + `ios/` folders

The `lib/` code and `pubspec.yaml` here are the source of truth — generate the
native folders into a throwaway dir and copy them in so nothing is overwritten.

**PowerShell (Windows):**
```powershell
cd recovery_companion
flutter create --platforms=android,ios --org com.recoverycompanion --project-name recovery_companion "$env:TEMP\rc_native"
Copy-Item "$env:TEMP\rc_native\android","$env:TEMP\rc_native\ios" -Destination . -Recurse -Force
Remove-Item "$env:TEMP\rc_native" -Recurse -Force
```

**bash/macOS/Linux:**
```bash
cd recovery_companion
flutter create --platforms=android,ios --org com.recoverycompanion --project-name recovery_companion /tmp/rc_native
cp -r /tmp/rc_native/android /tmp/rc_native/ios .
rm -rf /tmp/rc_native
```

Then set the Android **minSdk to 23** in `android/app/build.gradle`
(`flutter_secure_storage`'s encrypted prefs and `sqlite3_flutter_libs` require it):
```gradle
defaultConfig {
    minSdk = 23
}
```

### 2. Install deps + generate code + run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift + Riverpod codegen
flutter run
```

`build_runner` produces the `*.g.dart` files (git-ignored) for the Drift database
and the Riverpod providers — required before the app compiles.

## Notes

- **The Companion (AI chat)** will call Claude through a server-side proxy (the
  existing Firebase Cloud Function), so the API key never ships in the app. That
  wiring lands when the Companion feature is built.
- Design system (typography, spacing, components) is intentionally minimal here —
  it's fleshed out in the next step.
