# DropNow — Phase 2 Completed

## Phase: COMMAND ENGINE + LOCAL NOTIFICATION FOUNDATION

### Summary
Phase 2 transforms DropNow from a polished shell into a functional fitness command app. The command generation engine, local notification plumbing, user preference persistence, and scheduling foundation are all wired and operational. Users can configure their personality, difficulty, frequency, and active time window — then trigger commands manually or let the scheduling engine deliver them.

---

### New Functionality

| Feature | Status |
|---|---|
| Command domain model (WorkoutCommand, WorkoutType, Personality, Difficulty) | ✅ |
| Static workout library (12 exercise types, 3 difficulty tiers, 144 tone phrases) | ✅ |
| Personality/tone system (Commander / Funny / Chill) | ✅ |
| Difficulty system (Easy / Medium / Savage with rep/time ranges) | ✅ |
| Command generation service (random template + tone + difficulty → command) | ✅ |
| Preferences persistence via SharedPreferences | ✅ |
| App activation toggle (system on/off) | ✅ |
| Frequency configuration (3, 5, 8, or 10 commands per day) | ✅ |
| Active time window configuration (start/end time pickers) | ✅ |
| Local notification service (platform-safe, permission handling) | ✅ |
| Command scheduling engine (even spacing + jitter within window) | ✅ |
| Manual "Drop Me One" test command | ✅ |
| Command detail bottom sheet | ✅ |
| Functional Home screen (system toggle, latest command, scheduling, stats) | ✅ |
| Functional Profile/Settings screen (all settings interactive) | ✅ |
| Cross-screen sync (Home ↔ Profile refresh on settings change) | ✅ |
| Service initialization in main.dart (async, before runApp) | ✅ |

---

### Files Created

| File | Purpose |
|---|---|
| `lib/core/models/personality.dart` | Personality enum (Commander/Funny/Chill) with label, description, emoji |
| `lib/core/models/difficulty.dart` | Difficulty enum (Easy/Medium/Savage) with label, description, emoji |
| `lib/core/models/workout_type.dart` | 12 workout types with label, isTimeBased, unit, caloriesPerUnit |
| `lib/core/models/workout_command.dart` | WorkoutCommand model with serialization, computed fields |
| `lib/core/models/models.dart` | Barrel export for all models |
| `lib/core/services/workout_library.dart` | Static exercise pool (12 templates) + tone phrases (144 total) |
| `lib/core/services/command_generation_service.dart` | Random command generation from template + tone + difficulty |
| `lib/core/services/preferences_service.dart` | SharedPreferences wrapper for all user settings |
| `lib/core/services/notification_service.dart` | Platform-safe local notification init, permission, show, schedule |
| `lib/core/services/scheduling_service.dart` | Daily schedule builder with even spacing + randomized jitter |
| `lib/core/services/services.dart` | Barrel export for all services |
| `lib/app/widgets/command_detail_sheet.dart` | Modal bottom sheet showing full command details + chips |

### Files Updated

| File | Changes |
|---|---|
| `lib/main.dart` | Async main, service initialization before runApp |
| `lib/app/app.dart` | Accepts and passes service instances to AppShell |
| `lib/app/routes/app_shell.dart` | Distributes services to screens, cross-screen refresh via GlobalKeys |
| `lib/features/home/home_screen.dart` | Full rewrite: StatefulWidget, system toggle, Drop Me One, latest command, scheduling info, settings summary |
| `lib/features/profile/profile_screen.dart` | Full rewrite: functional settings for personality, difficulty, frequency, time window, system toggle |
| `lib/app/widgets/widgets.dart` | Added command_detail_sheet export |
| `test/widget_test.dart` | Updated for new required service parameters |
| `pubspec.yaml` | Added shared_preferences, flutter_local_notifications |

---

### Architecture Notes

- **Service layer pattern**: Services are instantiated in `main.dart` and passed down via constructor injection through `DropNowApp` → `AppShell` → individual screens.
- **Cross-screen sync**: `AppShell` uses `GlobalKey<HomeScreenState>` and `GlobalKey<ProfileScreenState>` with `refresh()` callbacks so changes in Profile update Home and vice versa.
- **Notification approach**: Uses `flutter_local_notifications` v21 with named-parameter API. Scheduling uses `Future.delayed` for this phase (lightweight). Full timezone-aware scheduling deferred to future phase.
- **Preferences defaults**: System off, Commander personality, Medium difficulty, 5x/day frequency, 9:00 AM – 9:00 PM window.
- **Workout library**: 12 exercise types × 3 difficulty ranges × 3 personalities × 4 phrases each = 144 unique tone phrases with `{amount}` and `{exercise}` placeholders.

---

### Verification

- `flutter analyze` → **No issues found**
- `flutter run -d chrome` → **Launches successfully, all screens functional**

---

### Notes for Phase 3

- History tracking: persist completed commands for the History screen
- Challenge system: wire Challenges screen with streak/goal data
- Timezone-aware scheduling with background isolates
- Notification deep-linking to command detail
- Rank/XP progression system in Profile
- Sound/haptic feedback on command arrival
