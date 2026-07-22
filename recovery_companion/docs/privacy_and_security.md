# Privacy, security & the crisis safety net

How the app protects vulnerable users, and the one-time native setup the new
capabilities need.

## What's implemented

### Data & encryption
- **Local-first.** All recovery data lives in a local SQLite database on the
  device. No accounts, no app server holding user data.
- **Encrypted at rest (whole database).** The DB is opened through **SQLCipher**
  ([database.dart](../lib/data/local/database.dart)) with a 256-bit key that is
  generated once and stored only in the platform keystore (Keychain / Android
  Keystore) via `flutter_secure_storage`.
- **Companion chat gets a second layer.** Messages are also AES-GCM encrypted at
  the app level before they hit the (already-encrypted) database.
- **Secrets never in the DB.** The AI backend token, the chat key, the DB key,
  and the app-lock PIN (as a salted **PBKDF2** hash) all live in secure storage.

### Optional app lock
- PIN (4-digit, PBKDF2-hashed) and/or **biometrics** (`local_auth`).
- Locks on launch and whenever the app leaves the foreground — which also blanks
  sensitive content in the app switcher.
- Basic brute-force throttle (cool-down after repeated wrong PINs).
- **Crisis help is reachable on the lock screen itself**, so the lock never
  blocks a person from reaching a hotline.

### Minimal collection, no tracking
- No analytics, no advertising, nothing sold or shared. The app only stores what
  the user types in. This is stated plainly in-app on the Privacy screen.

### Your controls (Me → Privacy & security)
- **Export my data** — a full, decrypted JSON copy, shared via the system sheet.
- **Delete everything** — type-to-confirm, wipes every table and app secret.
- **App lock** — set up / change / turn off.

### Crisis safety net (reachable from EVERY screen)
- A persistent, discreet **crisis button** floats above the whole app (even the
  lock screen) — [crisis_help_button.dart](../lib/features/crisis/widgets/crisis_help_button.dart).
- It opens region-aware resources (US 988 + 911 + SAMHSA by default; UK, CA, AU,
  IE recognized) with **one-tap call/text**, clearly labelled US when we can't
  match the region, and an invitation to add a local line.
- **Personal support people** (sponsor, friend, family) — saved locally, one-tap
  call/text from the SOS screen and the crisis sheet.

### Accessibility
- Text uses theme styles and scales with the OS text-size setting.
- Motion respects the OS "reduce motion" setting (`AppMotion`).
- Semantic labels / tooltips on icon-only and safety-critical controls (crisis
  button, lock keypad, resource + contact call/text buttons, send).

### Onboarding
- A short, warm first-run flow that states plainly the app is a **companion to,
  not a replacement for**, professional treatment and support, and reassures on
  privacy and always-available help.

---

## One-time native setup

This project has no `android/` or `ios/` folders yet. Run `flutter create .`
once, then apply the following (in addition to the notifications setup in
[notifications_native_setup.md](notifications_native_setup.md)).

### SQLCipher
Handled by the `sqlcipher_flutter_libs` package — no manual native code. It needs
the **same core-library desugaring** already required by notifications on Android
(see the notifications doc). On iOS/macOS the CocoaPod links SQLCipher
automatically.

### local_auth (biometrics)
**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```
and make `MainActivity` extend `FlutterFragmentActivity` (not `FlutterActivity`):
```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity : FlutterFragmentActivity()
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock Recovery Companion with Face ID.</string>
```

### share_plus
No configuration needed for exporting the JSON file.

### url_launcher (`tel:` / `sms:`)
Already used by the SOS toolkit. If you add Android package visibility later,
ensure `tel`/`sms` intents are allowed in the manifest `<queries>`.

---

## Notes & honest limitations
- **Can't run yet:** with no platform folders, the app compiles and analyzes but
  can't execute. SQLCipher, biometrics, and sharing are verified by static
  analysis only until platforms are added.
- **PIN strength:** a 4-digit PIN with a simple throttle is convenience-grade;
  biometrics are recommended, and the whole DB is encrypted regardless.
- **Region detection** uses the device locale; it's a best-effort default, not a
  guarantee — hence the always-available "add your local line" path.
