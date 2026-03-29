# DropNow — Phase 4: Firebase + User Accounts + Cloud Sync ✅

## Summary

Phase 4 adds Firebase integration with anonymous authentication, Firestore cloud backup for execution records, and preference synchronization — all while maintaining the local-first architecture from Phase 3.

## Architecture

**Local-first + cloud-backed**: SharedPreferences remains the single source of truth for all local data. Firestore serves as a cloud backup layer. The app works perfectly offline; cloud sync is a non-fatal enhancement.

**Service injection**: `AuthService` and `FirestoreSyncService` are created in `main.dart` and passed through the widget tree via constructor injection, consistent with the existing pattern.

**Non-fatal Firebase**: If Firebase is not configured (no `google-services.json`), or the network is unavailable, the app continues running in local-only mode. Every Firebase call is wrapped in try/catch.

## New Files

### `lib/core/services/auth_service.dart`
- Wraps `FirebaseAuth.instance`
- `ensureSignedIn()` — anonymous auth, safe to call multiple times
- `signOut()` — non-fatal sign out
- Getters: `uid`, `isSignedIn`, `isAnonymous`, `authProviderLabel`
- `authStateChanges` stream for reactive UI

### `lib/core/services/firestore_sync_service.dart`
- Requires `AuthService`, `PreferencesService`, `ExecutionStorageService`
- **User profile**: `bootstrapUserProfile()` creates `users/{uid}` document (merge-safe)
- **Preference sync**: `syncPreferences()` writes current settings to user doc
- **Execution sync**: `syncRecord()` uploads a single record using its ID as Firestore doc ID (naturally idempotent — no duplicates)
- **Batch sync**: `syncAllLocal()` uploads all local completed/skipped records
- **Cloud restore**: `restoreFromCloud()` downloads up to 500 cloud records, only adds missing ones locally
- **Full sync**: `fullSync()` runs upload + restore in sequence

## Modified Files

### `pubspec.yaml`
- Added: `firebase_core: ^3.13.0`, `firebase_auth: ^5.6.0`, `cloud_firestore: ^5.6.7`

### `android/settings.gradle.kts`
- Added: `id("com.google.gms.google-services") version "4.4.2" apply false`

### `android/app/build.gradle.kts`
- Added: `id("com.google.gms.google-services")` plugin

### `android/app/google-services.json`
- Placeholder with `REPLACE_ME` values — must be replaced with real Firebase config

### `lib/main.dart`
- Firebase.initializeApp() (try/catch, non-fatal)
- Creates `AuthService`, calls `ensureSignedIn()`
- Creates `FirestoreSyncService` if Firebase is ready
- Background: bootstraps user profile + syncs local records on startup
- Passes `authService` and `syncService` to `DropNowApp`

### `lib/app/app.dart`
- Added `authService` (required) and `syncService` (optional) parameters
- Passes both to `AppShell`

### `lib/app/routes/app_shell.dart`
- Added `authService` (required) and `syncService` (optional) parameters
- Passes both to `ProfileScreen`

### `lib/core/services/execution_storage_service.dart`
- `isRecorded()` now accepts optional `date` parameter (defaults to today)
- Enables cross-date duplicate checking for cloud restore

### `lib/core/services/services.dart`
- Added exports: `auth_service.dart`, `firestore_sync_service.dart`

### `lib/features/profile/profile_screen.dart`
- Added `authService` and `syncService` parameters
- Account section shows real auth status (`authProviderLabel`)
- New "Cloud Backup" tile shows sync status (Enabled/Offline/Not configured)
- Tapping "Cloud Backup" triggers `fullSync()` with progress SnackBars
- Preference changes auto-sync to cloud via `_rescheduleIfActive()`

### `test/widget_test.dart`
- Added `authService: AuthService()` to match updated constructor

## Firestore Data Structure

```
users/{uid}
├── uid: string
├── createdAt: timestamp
├── lastSeenAt: timestamp
├── authProvider: "anonymous" | "linked"
├── personality: string (enum name)
├── difficulty: string (enum name)
├── frequencyPerDay: int
├── activeStartHour/Minute: int
├── activeEndHour/Minute: int
├── systemEnabled: bool
└── executions/{recordId}
    ├── id: string
    ├── timestamp: Timestamp
    ├── dateKey: "YYYY-MM-DD"
    ├── workoutType: string (enum name)
    ├── amount: int
    ├── difficulty: string (enum name)
    ├── personality: string (enum name)
    ├── status: "done" | "skipped"
    ├── calories: double
    ├── displayText: string
    └── source: "local_sync"
```

## Firestore Security Rules

Apply these rules in the Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /executions/{executionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Firebase Console Setup Guide

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" → name it (e.g., "DropNow")
3. Disable Google Analytics (optional for dev)
4. Click "Create project"

### 2. Add Android App
1. In the Firebase project, click the Android icon (Add app)
2. Package name: `com.dropnow.drop_now`
3. App nickname: "DropNow Android"
4. Skip SHA-1 for now (only needed for Google Sign-In later)
5. Click "Register app"
6. Download `google-services.json`
7. Replace the placeholder file at `android/app/google-services.json` with the downloaded file

### 3. Enable Anonymous Authentication
1. In Firebase Console → Authentication → Sign-in method
2. Click "Anonymous" → Enable → Save

### 4. Create Firestore Database
1. In Firebase Console → Firestore Database → Create database
2. Choose "Start in test mode" (you'll replace with rules below)
3. Select the closest region to your users
4. Click "Enable"
5. Go to Rules tab → paste the security rules from above → Publish

## Verification

- `flutter analyze` — No issues found
- `flutter build apk --debug` — Builds successfully
- App runs in local-only mode when Firebase is not configured (placeholder google-services.json)
- After replacing google-services.json with real config, anonymous auth + cloud sync will activate automatically

## Dependencies Added

| Package | Version Resolved |
|---------|-----------------|
| firebase_core | 3.15.2 |
| firebase_auth | 5.7.0 |
| cloud_firestore | 5.6.12 |
| google-services plugin | 4.4.2 |

---

## Live Firebase Verification Report

**Date**: 2026-03-29  
**Firebase Project**: `dropnow-app` (Project Number: 42037920456)  
**Device**: Android Emulator (SDK gphone64 x86_64, API 36)  
**Authenticated as**: xhersi.karaj@gmail.com  

### 1. Firebase Initialization ✅

App launches with real `google-services.json` (API key: `AIzaSyBOH...`).
```
[FIREBASE] initialized OK
```

### 2. Anonymous Authentication ✅

Anonymous auth succeeds immediately on launch. A real UID is assigned.
```
[AUTH] signed in: true, uid: 5GrLneO2zKW8EuMD8a6oYERGcQ92, isAnonymous: true
```
Second UID (after data clear): `2ZQPaxY7b8NxIPAMifQ6iAF0x5o1`  
Note: Clearing app data creates a new anonymous UID — this is expected Firebase behavior.

### 3. User Profile Document Created ✅

Firestore document created at `users/{uid}` with all preference fields:
```
users/5GrLneO2zKW8EuMD8a6oYERGcQ92
├── uid: "5GrLneO2zKW8EuMD8a6oYERGcQ92"
├── personality: "commander"
├── difficulty: "medium" → later synced to "savage"
├── frequencyPerDay: 5
├── activeStartHour: 9, activeEndHour: 21
├── systemEnabled: true
├── authProvider: "anonymous"
├── createdAt: 2026-03-29T07:30:40.006Z
└── lastSeenAt: 2026-03-29T07:40:30.998Z
```

### 4. Execution Records Synced ✅

**Startup sync** — existing local record uploaded on launch:
```
[SYNC] Uploaded execution: cmd_1774765836016_7324 (mountainClimbers x15)
[SYNC] startup sync: 1 records uploaded
```

**Real-time sync** — tapping "Done" on a live command syncs immediately:
```
[SYNC] Uploaded execution: cmd_1774769745181_0078 (highKnees x32)
```

**Firestore REST API confirmation** — 2 execution docs verified:
```
cmd_1774765836016_7324 → mountainClimbers x15 (done)
cmd_1774769745181_0078 → highKnees x32 (done)
```

### 5. Preference Sync ✅

Changed difficulty from Medium → Savage via Profile screen. Log confirmed:
```
[SYNC] Preferences synced to Firestore
```
Firestore REST API verification: `difficulty: "savage"` (was `"medium"`).

### 6. Duplicate Prevention ✅

**User profile**: Second app launch logged `User profile already exists` — no duplicate creation.  
**Execution records**: Same record re-uploaded via Firestore `set(merge: true)` — idempotent, no duplicate docs.

### 7. Restore from Cloud ✅

**Test procedure**:
1. Completed a plank command (synced to Firestore as `cmd_1774770221995_3747`)
2. Wiped `FlutterSharedPreferences.xml` (cleared all local execution data)
3. Force-stopped and relaunched (same Firebase UID preserved)
4. Tapped "Cloud Backup" → triggered `fullSync()` → `restoreFromCloud()`

**Result**:
```
[SYNC] Cloud has 1 execution docs
[SYNC] Restored: cmd_1774770221995_3747 (2026-03-29)
```
Local SharedPreferences confirmed re-populated with the plank record (38 reps, 3.8 cal).

### Verification Summary

| Criterion | Status |
|-----------|--------|
| App launches with real Firebase config | ✅ Verified |
| Anonymous auth succeeds with real UID | ✅ Verified |
| `users/{uid}` document created in Firestore | ✅ Verified via REST API |
| Completing a command creates execution doc | ✅ Verified (real-time + startup) |
| Changing settings updates user profile doc | ✅ Verified (difficulty: medium → savage) |
| Relaunching does not duplicate synced records | ✅ Verified |
| Restore from cloud recovers missing local data | ✅ Verified (wiped local → restored from Firestore) |
