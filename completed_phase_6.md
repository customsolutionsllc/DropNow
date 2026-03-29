# DropNow — Phase 6: AdMob + Monetization Foundation ✅

## Summary

Phase 6 integrates **Google AdMob** into DropNow with three ad formats — **rewarded ads** (streak protection), **interstitial ads** (frequency-capped after completed commands), and **banner ads** (History screen only). The implementation uses real production ad unit IDs with development safety provided by the Google Mobile Ads SDK's automatic emulator test-device detection. The architecture is **Premium-ready**: a single `_isPremium` flag in `AdService` will disable all ads when a future Premium/No-Ads purchase is activated.

---

## Architecture

- **Centralized AdService** — Single service manages all three ad formats, ad lifecycle (load → show → dispose → reload), persistence of counters/cooldowns, and streak protection state. Created once in `main.dart`, injected via constructors through the existing service chain.
- **AdConfig constants** — All ad unit IDs, thresholds, and cooldowns are centralized in one class for easy tuning.
- **Premium-ready gating** — Every public method in `AdService` checks `_isPremium` before acting. `BannerAdWidget` checks `adService.isPremium` before rendering. Flipping one flag disables all ad surfaces.
- **StatsService integration** — Streak calculation now considers streak protection dates via an injected callback (`isDateStreakProtected`), so a day with only streak protection (no completions) still counts toward the streak.
- **Graceful degradation** — If any ad fails to load, the UI collapses gracefully (`SizedBox.shrink()` for banner, snackbar "Ad not ready" for rewarded, silent no-op for interstitial).

---

## New Files

### `lib/core/services/ad_config.dart`
- Centralized AdMob configuration constants
- **Production Ad Unit IDs**: rewarded (`ca-app-pub-2904858490677289/9640214775`), interstitial (`ca-app-pub-2904858490677289/2141734791`), banner (`ca-app-pub-2904858490677289/5948381773`)
- **Interstitial frequency cap**: threshold = 3 completed commands, cooldown = 120 seconds
- **Streak protection limit**: max 1 per day
- `isDebug` getter wrapping `kDebugMode`

### `lib/core/services/ad_service.dart` (~250 lines)
- **Initialization**: `init()` calls `MobileAds.instance.initialize()`, then preloads rewarded + interstitial ads
- **Rewarded Ad (Streak Protection)**:
  - `isRewardedAdReady` — checks ad availability + non-premium
  - `showRewardedAd()` — shows ad, waits for reward callback, marks streak protection in SharedPreferences, returns `true` only on confirmed reward
  - Auto-reloads next ad on dismiss or failure
- **Interstitial Ad**:
  - `onCommandCompleted()` — increments counter, returns `true` when threshold (3) is reached AND cooldown (120s) has elapsed
  - `showInterstitialAd()` — shows ad, resets counter + records timestamp, auto-reloads next
  - Counter and timestamp persisted in SharedPreferences across app restarts
- **Streak Protection State**:
  - `isStreakProtectionEligible({streak, completedToday, skippedToday})` — eligible when: streak > 0, no completions today, at least 1 skip today, not already used today
  - `isStreakProtectedForDate(String date)` — callback for StatsService streak calculation
  - Protection date persisted as SharedPreferences string key
- **Premium support**: `setPremium(bool)` disposes all ads when premium activates
- **Persistence keys**: `ad_completed_since_interstitial`, `ad_last_interstitial_time`, `ad_streak_protection_date`

### `lib/app/widgets/banner_ad_widget.dart`
- `BannerAdWidget` — `StatefulWidget` displaying an inline adaptive banner (320×60 max)
- Loads ad in `didChangeDependencies()` using screen width for adaptive sizing
- `BannerAdListener` handles load success (sets `_isLoaded = true`) and failure (disposes ad, collapses widget)
- Renders `SizedBox.shrink()` when ad is not loaded — zero visual footprint
- Proper `dispose()` cleans up native ad resources

---

## Modified Files

### `pubspec.yaml`
- Added dependency: `google_mobile_ads: ^5.3.0` (resolved to 5.3.1)

### `android/app/src/main/AndroidManifest.xml`
- Added `<meta-data>` tag with AdMob App ID (`ca-app-pub-2904858490677289~8275716153`) inside `<application>`

### `lib/core/services/services.dart`
- Added exports: `ad_config.dart`, `ad_service.dart`

### `lib/app/widgets/widgets.dart`
- Added export: `banner_ad_widget.dart`

### `lib/core/services/stats_service.dart`
- Added `bool Function(String date)? isDateStreakProtected` callback field
- Refactored `currentStreak` to use `_hasActivity(dateKey)` helper that checks both actual completions AND streak protection status via the callback

### `lib/main.dart`
- Creates `AdService(prefsService.prefs)` after StatsService
- Calls `await adService.init()` to initialize SDK + preload ads
- Wires streak protection callback: `statsService.isDateStreakProtected = adService.isStreakProtectedForDate`
- Passes `adService: adService` to `DropNowApp`

### `lib/app/app.dart`
- Added `AdService adService` field + `required this.adService` constructor parameter
- Forwards `adService` to `AppShell`

### `lib/app/routes/app_shell.dart`
- Added `AdService adService` field + `required this.adService` constructor parameter
- Passes `adService: widget.adService` to `HomeScreen` and `HistoryScreen`

### `lib/features/home/home_screen.dart`
- Added `AdService adService` field + `required this.adService` constructor parameter
- **Streak Protection Card**: Computes eligibility via `adService.isStreakProtectionEligible()` using current streak, today's completed count, and today's skipped count. When eligible, renders a warning-colored card with shield icon, "Streak in Danger!" title, and "Save My Streak" button
- **Streak Protection Tap**: Shows rewarded ad via `adService.showRewardedAd()`. On success, refreshes UI and shows success snackbar. On ad-not-ready, shows error snackbar
- **Interstitial Trigger**: In `_recordAction()`, after a completed command, calls `adService.onCommandCompleted()`. When threshold is met, calls `adService.showInterstitialAd()`

### `lib/features/history/history_screen.dart`
- Added `AdService adService` field + `required this.adService` constructor parameter
- Added `BannerAdWidget()` at the bottom of the scrollable content, gated by `!widget.adService.isPremium`

---

## Ad Format Specifications

| Format | Placement | Trigger | Frequency Control | Premium Behavior |
|--------|-----------|---------|-------------------|------------------|
| **Rewarded** | Home screen (streak protection card) | User taps "Save My Streak" | Max 1 per day | Hidden |
| **Interstitial** | After command completion | Every 3 completed commands | 120-second cooldown between shows | Suppressed |
| **Banner** | History screen (bottom) | Always visible when loaded | N/A — passive display | Hidden |

---

## SharedPreferences Keys

| Key | Type | Purpose |
|-----|------|---------|
| `ad_completed_since_interstitial` | `int` | Counter of completed commands since last interstitial |
| `ad_last_interstitial_time` | `int` | Epoch ms of last interstitial show (for cooldown) |
| `ad_streak_protection_date` | `String` | Date key (YYYY-MM-DD) of last streak protection use |

---

## Streak Protection Logic

1. **Eligibility check** (`isStreakProtectionEligible`):
   - Current streak > 0
   - Zero completions today (streak is at risk)
   - At least 1 skip today (user has been active but not completing)
   - Streak protection not already used today
   - Not a premium user

2. **Activation flow**:
   - User taps "Save My Streak" → rewarded ad plays → on reward callback → date saved to SharedPreferences
   - `StatsService.currentStreak` queries `isDateStreakProtected(dateKey)` and counts protected days as streak-maintaining

3. **Persistence**: Protection date stored as `YYYY-MM-DD` string. Only the most recent protection date is stored (max 1 per day).

---

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze` | **No issues found** |
| `flutter build apk --debug` | **Build successful** |
| App launches on emulator (emulator-5554, API 36) | **No crashes** |
| Mobile Ads SDK initializes | **✅** `[ADS] Mobile Ads SDK initialized` |
| Rewarded ad preloads | **✅** `[ADS] Rewarded ad loaded` |
| Interstitial ad preloads | **✅** `[ADS] Interstitial ad loaded` |
| Banner ad loads on History | **✅** `[ADS] Banner ad loaded` |
| Banner ad visible on History screen | **✅** Confirmed via screenshot |
| Navigation across all 4 tabs | **✅** No crashes, all screens render |
| Streak protection card (conditional render) | **✅** Shows only when eligible |
| Interstitial trigger wired to command completion | **✅** Fires after 3 completions with cooldown |
| Zero Dart analysis errors | **✅** Verified |

---

## Dependencies Added

| Package | Version | Purpose |
|---------|---------|---------|
| `google_mobile_ads` | ^5.3.0 (resolved 5.3.1) | Google AdMob SDK — rewarded, interstitial, banner ads |

---

## What Was NOT Built (Per Spec)

- ❌ No Premium purchase flow or paywall UI
- ❌ No ad removal toggle in settings
- ❌ No server-side ad verification
- ❌ No ad mediation or waterfall
- ❌ No analytics events for ad impressions (future phase)
- ❌ `_isPremium` flag is always `false` — ready for future Premium integration

---

## Phase 6 Feature Summary

| Feature | Status |
|---------|--------|
| google_mobile_ads dependency + AndroidManifest config | ✅ Implemented |
| AdConfig centralized constants | ✅ Implemented |
| AdService — rewarded ad management | ✅ Implemented |
| AdService — interstitial ad management with frequency cap | ✅ Implemented |
| AdService — streak protection state + persistence | ✅ Implemented |
| BannerAdWidget — adaptive banner for History screen | ✅ Implemented |
| StatsService — streak protection awareness | ✅ Implemented |
| HomeScreen — streak protection UI card + rewarded flow | ✅ Implemented |
| HomeScreen — interstitial trigger on command completion | ✅ Implemented |
| HistoryScreen — banner ad at bottom | ✅ Implemented |
| Premium-ready gating (`_isPremium` flag) | ✅ Implemented |
| Service injection through constructor chain | ✅ Implemented |
| SharedPreferences persistence for ad state | ✅ Implemented |
| Emulator smoke test — all ad types load | ✅ Verified |
| Static analysis clean | ✅ Verified |
| Debug build successful | ✅ Verified |
