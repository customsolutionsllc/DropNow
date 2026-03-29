# COMPLETED — PHASE 1

## Summary
Phase 1 establishes the full product foundation for **DropNow** — a command-based micro workout app. This phase delivers a running Flutter app with a clean scalable folder structure, polished dark-themed UI, bottom navigation shell, and four fully designed placeholder screens that already feel like a real product. The codebase is organized for easy Firebase integration and feature expansion in future phases.

## Screens Implemented

### Home
- App title and greeting header
- Command status card with live indicator (STANDING BY)
- Stats row: streak counter + completed counter
- Today's progress card with progress bar, done/skipped/calories breakdown
- Quick action cards (Drop Me One, View History)
- Next Command upcoming card

### History
- Weekly summary stats (Commands, Obeyed, Skipped, Calories)
- Calendar placeholder showing current month with today highlighted
- Recent Activity section with empty state messaging
- Date-based UI ready for future history inspection

### Challenges
- "Challenge a Friend" primary action button
- Incoming challenges section (empty state with messaging)
- Sent challenges section (empty state with messaging)
- Challenge history with empty state card
- Social teaser section with feature chips (1v1 Battles, Leaderboards, Streaks)

### Profile / Settings
- Profile header card with rank display (Soldier / Recruit)
- Workout Settings group: Commander Personality, Drop Frequency, Difficulty, Quiet Hours
- Account group: Account, Social
- App group: Appearance, About DropNow, Send Feedback
- Grouped card layout with dividers — expandable without redesign

## Architecture

### Folder Structure
```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # MaterialApp root widget
│   ├── routes/
│   │   └── app_shell.dart             # Bottom nav shell with IndexedStack
│   ├── theme/
│   │   └── app_theme.dart             # Full dark theme configuration
│   └── widgets/
│       ├── widgets.dart               # Barrel export
│       ├── section_header.dart        # Reusable section header
│       ├── dashboard_card.dart        # Reusable surface card
│       ├── stat_card.dart             # Stat display card
│       ├── empty_state_card.dart      # Empty state with icon/text/action
│       ├── settings_row_tile.dart     # Settings list row
│       └── buttons.dart              # Primary + Secondary buttons
├── features/
│   ├── home/
│   │   └── home_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   ├── challenges/
│   │   └── challenges_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── settings/                      # Reserved for future settings screens
├── core/
│   ├── constants/
│   │   ├── constants.dart             # Barrel export
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_strings.dart           # Centralized strings
│   │   └── app_spacing.dart           # Spacing & radius constants
│   ├── models/                        # Reserved for data models
│   ├── services/                      # Reserved for Firebase/notification services
│   └── utils/                         # Reserved for utility functions
```

### Key Architecture Decisions
- **Feature-based organization** — each screen lives in its own feature folder
- **IndexedStack navigation** — preserves screen state across tab switches
- **Barrel exports** — clean imports via `widgets.dart` and `constants.dart`
- **Service-ready structure** — `core/services/` ready for auth, Firestore, FCM
- **Separated constants** — colors, spacing, strings isolated for consistency
- **No hardwired fake data** — placeholder values are clearly placeholder, no cleanup pain

## Design System

### Theme Details
- **Background:** Dark charcoal (#0D0D0D)
- **Surface:** Slightly lighter (#1A1A1A) with subtle border (#2E2E2E)
- **Accent:** Bold red (#FF4D4D) — commanding, aggressive, on-brand
- **Text:** White primary (#F5F5F5), muted secondary (#9E9E9E), dim (#616161)
- **Status colors:** Green (success), Orange (warning/streak), Red (error), Blue (info)
- **Typography:** Heavy weights (700-900) for headings, tight letter-spacing, large sizes
- **Cards:** Rounded (16px), bordered, zero elevation — clean modern look
- **Buttons:** Rounded (12px), bold text, accent-colored primary

### Reusable Components Created
| Component | Purpose |
|---|---|
| `SectionHeader` | Uppercase label with optional action link |
| `DashboardCard` | Bordered surface card with optional tap handler |
| `StatCard` | Icon + value + label stat display |
| `EmptyStateCard` | Icon + title + subtitle + optional action button |
| `SettingsRowTile` | Icon box + title/subtitle + trailing chevron |
| `PrimaryButton` | Full-width accent elevated button with optional icon |
| `SecondaryButton` | Full-width outlined button with optional icon |

## Navigation
- **Bottom navigation bar** with 4 tabs: Home, History, Challenges, Profile
- **IndexedStack** preserves each screen's scroll position and state
- Themed nav bar: dark background, red accent for active tab, muted inactive
- Top border separator for clean visual boundary
- Architecture supports adding deep/push navigation per tab in future phases

## Notes

### Important Decisions
- Chose `IndexedStack` over `PageView` for tab persistence — no unnecessary rebuilds
- Used `withValues(alpha:)` instead of deprecated `withOpacity` for future-proofing
- Portrait-only lock set from `main.dart` — mobile-first as specified
- System UI overlay styled to match dark theme (transparent status bar, dark nav bar)
- Debug banner disabled for production feel during testing
- No external packages added — only Flutter SDK used (minimal dependency approach)

### Firebase Readiness
- `core/services/` directory exists and is ready for `auth_service.dart`, `firestore_service.dart`, etc.
- `core/models/` ready for data models (workout, user, challenge)
- No hardwired data patterns that would conflict with Firestore integration
- `main.dart` already calls `WidgetsFlutterBinding.ensureInitialized()` — necessary for Firebase init

### For Next Phase
- The Home screen "Drop Me One" action and "Next Command" card are wired for the workout command engine (Phase 2)
- History screen calendar and activity list are structured for date-based data binding (Phase 3)
- Challenges screen layout supports incoming/sent/history data streams (Phase 5)
- Profile settings rows are ready to open detail screens or show pickers

## Verification
- ✅ `flutter analyze` — 0 issues found
- ✅ App successfully launches in Chrome
- ✅ Bottom navigation works — all 4 tabs switch correctly
- ✅ All screens render with intentional, polished layouts
- ✅ Theme applied consistently across all screens
- ✅ Reusable components used throughout (DashboardCard, StatCard, SectionHeader, etc.)
- ✅ Codebase is clean, organized, and ready for Phase 2
