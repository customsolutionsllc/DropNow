# Phase 8 — Polish, Optimise & Harden ✅

## Overview
Phase 8 hardens DropNow for production with error handling, offline resilience, performance optimizations, accessibility, deep linking, app branding assets, and release-build configuration.

---

## 1. Global Error Boundary & Crash Logging

### CrashService (`lib/core/services/crash_service.dart`) — NEW
- Singleton crash/error logger
- Stores last 50 errors in an in-memory ring buffer (`CrashRecord` objects)
- `log(error, stackTrace, context)` — tagged `[CRASH]` output
- Ready for Firebase Crashlytics forwarding in future

### main.dart Changes
- Wrapped entire app in `runZonedGuarded` — catches all async zone errors
- Added `FlutterError.onError` handler — catches build-phase widget errors
- Both route to `CrashService.log()`

### ErrorBoundary (`app_shell.dart`) — NEW
- `_ErrorBoundary` StatefulWidget wraps each of the 4 tab screens
- Catches build-phase errors via `_ErrorCatcher` + `ErrorWidget.builder`
- Shows friendly "Something went wrong" card with Retry button
- Logs caught errors to CrashService

---

## 2. Offline-first Firestore Hardening

### FirestoreSyncService Changes
- **Offline queue**: Failed writes are queued in `_offlineQueue` list
- **Persistent queue**: Queue serialized to SharedPreferences (survives restarts)
- **Connectivity monitor**: Checks connectivity every 30s via `InternetAddress.lookup`
- **Auto-sync**: Automatically flushes queue when connectivity returns
- **Firestore persistence**: Enabled with 10MB cache via `Settings(persistenceEnabled: true)`
- **init()** method: Sets Firestore settings, loads queue, starts connectivity timer
- **dispose()** method: Cancels connectivity timer

### Constructor Changes
- Now requires `SharedPreferences sharedPrefs` parameter
- main.dart passes `prefsService.prefs` to the constructor

---

## 3. Performance Pass

### RepaintBoundary Wrappers
- **HomeScreen**: Stats row, streak protection card, today's progress all wrapped in `RepaintBoundary`
- **HistoryScreen**: Each record tile wrapped in `RepaintBoundary`

### Widget Optimization
- Heavy sub-widgets isolated behind `RepaintBoundary` to prevent unnecessary repaints
- `IndexedStack` preserves tab state across switches

---

## 4. Accessibility Pass

### Semantics Annotations
- **HomeScreen**: System toggle card (`toggled`, `label`), stats row (streak + completed count), streak protection button (`button: true, label: 'Protect your streak'`)
- **HistoryScreen**: Each record tile (`label` with status, workout, calories)
- **ProfileScreen**: Profile header (`label` with rank and stats)
- **PremiumScreen**: Subscribe button (`button: true, label` with price)

### Touch Targets
- All interactive elements already ≥ 48dp (Material Design standard)

---

## 5. Deep-link / Notification-tap Routing

### DeepLinkService (`lib/core/services/deep_link_service.dart`) — NEW
- `tabNotifier` (ValueNotifier<int?>) for reactive tab navigation
- `handleNotificationTap(payload)` maps payloads to tab indices:
  - `check_in` → Home (0)
  - `history` → History (1)
  - `challenges` → Challenges (2)
  - `profile` → Profile (3)

### NotificationService Changes
- Added `setDeepLinkService(service)` method
- `_onNotificationTapped()` now routes through DeepLinkService
- All notifications include `payload: 'check_in'` for tap routing

### AppShell Changes
- Listens to `deepLinkService.tabNotifier`
- Auto-navigates to target tab when notification tapped
- Consumes the notification (sets to null) after navigation

---

## 6. App Icon & Splash Configuration

### flutter_native_splash.yaml — NEW
- Background color: `#121212` (matches app dark theme)
- Android 12+ splash support configured
- Run: `dart run flutter_native_splash:create`

### flutter_launcher_icons.yaml — NEW
- Adaptive icon with `#4FC3F7` background color
- Requires `assets/icon/icon.png` (1024×1024) before running
- Run: `dart run flutter_launcher_icons`

### Dev Dependencies Added
- `flutter_native_splash: ^2.4.5`
- `flutter_launcher_icons: ^0.14.3`

**Note**: Actual icon asset (`assets/icon/icon.png`) must be created/placed manually before running the icon generator.

---

## 7. Release-build Audit

### build.gradle.kts Changes
- `versionCode = 8`, `versionName = "1.0.0-rc.1"`
- Release buildType: `isMinifyEnabled = true`, `isShrinkResources = true`
- ProGuard configuration file referenced

### proguard-rules.pro — NEW
Keep rules for:
- Flutter engine
- Firebase
- Google Play Billing / in_app_purchase
- Google Mobile Ads
- Kotlin / AndroidX
- Google Play Core (deferred components) — `-dontwarn` rules
- General: enums, Serializable, Parcelable, native methods, annotations

### pubspec.yaml Version
- Updated to `1.0.0-rc.1+8`

### Build Results
- Debug APK: ✅ builds successfully
- Release APK: ✅ builds successfully (55.5MB with R8 minification)

---

## 8. Final QA Matrix

| Test | Result |
|------|--------|
| `dart analyze lib` | ✅ 0 errors, 0 warnings (2 pre-existing infos) |
| Debug build | ✅ Compiles cleanly |
| Release build | ✅ Compiles with R8/ProGuard |
| App launch | ✅ All services initialize correctly |
| Home tab | ✅ Renders, no errors |
| History tab | ✅ Renders, no errors |
| Challenges tab | ✅ Renders, no errors |
| Profile tab | ✅ Renders, no errors |
| Tab navigation | ✅ All 4 tabs, zero crashes |
| CrashService init | ✅ Logged in console |
| Offline queue init | ✅ `queue: 0 items` logged |
| Firebase init | ✅ `initialized OK` |
| Auth init | ✅ Anonymous sign-in |
| Firestore sync | ✅ Profile bootstrap + sync |
| Billing init | ✅ `Store available: false` (expected on emulator) |

---

## Files Created/Modified

### New Files
| File | Purpose |
|------|---------|
| `lib/core/services/crash_service.dart` | Error logging service |
| `lib/core/services/deep_link_service.dart` | Notification tap routing |
| `android/app/proguard-rules.pro` | R8/ProGuard keep rules |
| `flutter_native_splash.yaml` | Splash screen config |
| `flutter_launcher_icons.yaml` | App icon config |

### Modified Files
| File | Changes |
|------|---------|
| `lib/main.dart` | `runZonedGuarded`, `FlutterError.onError`, CrashService, DeepLinkService |
| `lib/app/app.dart` | Pass crashService + deepLinkService |
| `lib/app/routes/app_shell.dart` | ErrorBoundary wrappers, deep link listener, removed unused import |
| `lib/core/services/firestore_sync_service.dart` | Offline queue, connectivity monitor, persistence |
| `lib/core/services/notification_service.dart` | DeepLinkService integration, payload on notifications |
| `lib/core/services/services.dart` | Export crash_service + deep_link_service |
| `lib/features/home/home_screen.dart` | RepaintBoundary, Semantics |
| `lib/features/history/history_screen.dart` | RepaintBoundary, Semantics |
| `lib/features/premium/premium_screen.dart` | Semantics on subscribe button |
| `lib/features/profile/profile_screen.dart` | Semantics on profile header |
| `pubspec.yaml` | Version bump, dev_dependencies |
| `android/app/build.gradle.kts` | Version, ProGuard, R8 config |
