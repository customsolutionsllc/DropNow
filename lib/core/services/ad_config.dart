import 'package:flutter/foundation.dart';

/// Centralized AdMob configuration.
/// Production IDs are used in code, but the Google Mobile Ads SDK
/// automatically treats emulators as test devices — no extra setup needed.
class AdConfig {
  AdConfig._();

  // --- Production Ad Unit IDs ---
  static const String rewardedAdUnitId =
      'ca-app-pub-2904858490677289/9640214775';
  static const String interstitialAdUnitId =
      'ca-app-pub-2904858490677289/2141734791';
  static const String bannerAdUnitId = 'ca-app-pub-2904858490677289/5948381773';

  // --- Interstitial frequency cap ---
  /// Show an interstitial ad after this many completed commands.
  static const int interstitialThreshold = 3;

  /// Minimum seconds between interstitial shows.
  static const int interstitialCooldownSeconds = 120;

  /// Max streak protections allowed per day.
  static const int maxStreakProtectionsPerDay = 1;

  /// Whether the build is in debug mode (safe for dev testing).
  static bool get isDebug => kDebugMode;
}
