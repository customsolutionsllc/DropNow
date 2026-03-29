# DropNow — Phase 5: Social Challenges (1v1 + Invite System) ✅

## Summary

Phase 5 adds a real-time **1v1 challenge system** enabling users to send, receive, accept, decline, and complete workout challenges against friends. Challenges are stored in a top-level Firestore `challenges` collection with participant-scoped security rules, real-time `snapshots()` streams for live UI, and automatic integration with the local workout history from Phase 3/4. A 24-hour expiry window keeps challenges fresh, and the nullable service injection chain ensures the app degrades gracefully when offline.

---

## Architecture

- **Top-level Firestore collection** (`challenges`) — enables both sender and receiver to query independently via composite indexes.
- **Nullable service injection** — `ChallengeService?` is threaded from `main.dart → DropNowApp → AppShell → ChallengesScreen`; when null (offline / Firebase unavailable), the UI shows a friendly "Sign in to use challenges" placeholder.
- **Real-time streams** — `incomingChallenges()` and `sentChallenges()` return Firestore `snapshots()` streams consumed by `StreamBuilder` widgets for instant UI updates.
- **Cross-phase integration** — Completing a challenge creates a local `ExecutionRecord` (Phase 3) and syncs it to the cloud (Phase 4), bridging social activity into workout history.
- **24-hour expiry** — Each challenge carries an `expiresAt` timestamp; the `isExpired` computed property enables client-side staleness checks.

---

## New Files

### `lib/core/models/challenge.dart`
- `ChallengeStatus` enum: `pending`, `accepted`, `completed`, `declined`, `expired`
- `ChallengeStatusExtension`: `.label` (human-readable) and `.emoji` for each status
- `Challenge` immutable data class with Firestore serialization (`toFirestore()` / `fromFirestore()`)
- Computed properties: `isExpired`, `workoutLabel` (e.g. "Push-ups × 20"), `timeLeft` (human-readable countdown)
- `copyWith()` for status/completedAt mutations

### `lib/core/services/challenge_service.dart`
- Constructor: `ChallengeService({required AuthService authService})`
- `createChallenge(toUserId, workoutType, amount)` — creates pending doc with 24h expiry; prevents self-challenge
- `incomingChallenges()` → `Stream<List<Challenge>>` — queries `toUserId == uid`, ordered by `createdAt` DESC, limit 50
- `sentChallenges()` → `Stream<List<Challenge>>` — queries `fromUserId == uid`, ordered by `createdAt` DESC, limit 50
- `acceptChallenge(id)`, `declineChallenge(id)`, `completeChallenge(id)` — status mutations
- All methods guarded by auth availability with try/catch + `debugPrint` error logging

### `lib/features/challenges/challenges_screen.dart`
- Full rewrite from placeholder to production screen
- UID display card with copy-to-clipboard for sharing
- "Challenge a Friend" button → `_SendChallengeSheet` bottom sheet (opponent UID input, workout type picker, amount selector)
- "INCOMING" and "SENT" sections with `StreamBuilder`-powered real-time lists
- `_ChallengeCard` widget: shows workout label, opponent short UID, time left, status badge; action buttons adapt per role (Accept/Decline for incoming pending, Complete for incoming accepted)
- `_onCompleteChallenge` creates `ExecutionRecord` and syncs to cloud

### `firestore.indexes.json`
- Two composite indexes for the `challenges` collection (see below)

---

## Modified Files

### `lib/main.dart`
- Creates `ChallengeService(authService: authService)` when Firebase is ready
- Passes nullable `challengeService` to `DropNowApp`

### `lib/app/app.dart`
- Added `ChallengeService? challengeService` constructor parameter
- Forwards to `AppShell`

### `lib/app/routes/app_shell.dart`
- Added `ChallengeService? challengeService` constructor parameter
- Forwards to `ChallengesScreen` at bottom nav index 2
- Bottom nav: Home · History · **Challenges** · Profile

### `lib/core/models/models.dart`
- Added `export 'challenge.dart';`

### `lib/core/services/services.dart`
- Added `export 'challenge_service.dart';`

### `firestore.rules`
- Added `challenges/{challengeId}` match block (see Security Rules below)

### `firebase.json`
- Added `"indexes": "firestore.indexes.json"` to the Firestore config section

---

## Firestore Data Structure

```
challenges/{auto-id}
├── id: string           // document ID
├── fromUserId: string   // sender's auth UID
├── toUserId: string     // receiver's auth UID
├── workoutType: string  // WorkoutType enum name (e.g. "pushUps")
├── amount: int          // target count
├── status: string       // "pending" | "accepted" | "completed" | "declined" | "expired"
├── createdAt: Timestamp
├── expiresAt: Timestamp // createdAt + 24 hours
└── completedAt: Timestamp? // set via serverTimestamp on completion
```

---

## Firestore Security Rules

```javascript
match /challenges/{challengeId} {
  // Only authenticated users; fromUserId must match auth UID
  allow create: if request.auth != null
    && request.resource.data.fromUserId == request.auth.uid;

  // Only sender or receiver can read
  allow read: if request.auth != null
    && (resource.data.fromUserId == request.auth.uid
        || resource.data.toUserId == request.auth.uid);

  // Only receiver can update status (accept/decline/complete)
  allow update: if request.auth != null
    && resource.data.toUserId == request.auth.uid;

  // Delete not allowed
}
```

---

## Composite Indexes

| # | Collection   | Field 1              | Field 2              | Scope      | Status |
|---|-------------|----------------------|----------------------|------------|--------|
| 1 | `challenges` | `toUserId` ASC       | `createdAt` DESC     | COLLECTION | ✅ ACTIVE |
| 2 | `challenges` | `fromUserId` ASC     | `createdAt` DESC     | COLLECTION | ✅ ACTIVE |

Deployed via `firebase deploy --only firestore:indexes` and confirmed active via `gcloud firestore indexes composite list`.

---

## Verification

- `flutter analyze` — **No issues found!**
- `flutter build apk --debug` — **Builds successfully**
- Firestore composite indexes — **Both ACTIVE** (confirmed via gcloud CLI)
- Firestore security rules — **Deployed** (confirmed via Firebase CLI)
- App runs on emulator (`emulator-5554`, Pixel 7 API 36) — **No crashes**
- Bottom nav "Challenges" tab navigable and renders correctly
- Offline mode graceful degradation — Displays "Sign in to use challenges" when `ChallengeService` is null

---

## Dependencies Added

No new packages were added in Phase 5. All functionality uses existing dependencies:

| Package | Purpose |
|---------|---------|
| `cloud_firestore` | Challenge document CRUD + real-time streams |
| `firebase_auth` | User identity for challenge ownership |

---

## Phase 5 Feature Summary

| Feature | Status |
|---------|--------|
| Challenge data model with 5 statuses | ✅ Implemented |
| ChallengeService CRUD + real-time streams | ✅ Implemented |
| Full Challenges UI screen | ✅ Implemented |
| Send challenge bottom sheet (UID + workout + amount) | ✅ Implemented |
| Incoming challenge cards (Accept / Decline) | ✅ Implemented |
| Complete challenge + auto-create workout record | ✅ Implemented |
| UID display + copy-to-clipboard | ✅ Implemented |
| 24-hour challenge expiry | ✅ Implemented |
| Firestore security rules (participant-scoped) | ✅ Deployed |
| Composite indexes for query performance | ✅ ACTIVE |
| Nullable service chain (offline graceful) | ✅ Implemented |
| Static analysis clean | ✅ Verified |
| Debug build successful | ✅ Verified |
