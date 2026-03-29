import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_now/core/services/ad_config.dart';
import 'package:drop_now/core/services/execution_storage_service.dart';

/// Central monetization service managing all ad formats and monetization state.
/// Designed for easy Premium/No-Ads toggle in future phases.
class AdService {
  final SharedPreferences _prefs;

  // --- Persistence keys ---
  static const _keyCompletedSinceLastInterstitial =
      'ad_completed_since_interstitial';
  static const _keyLastInterstitialTime = 'ad_last_interstitial_time';
  static const _keyStreakProtectionDate = 'ad_streak_protection_date';

  // --- Ad instances ---
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _rewardedAdLoading = false;
  bool _interstitialAdLoading = false;

  /// True if Premium is active (future use — always false in Phase 6).
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  AdService(this._prefs);

  // ──────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────

  /// Initialize Mobile Ads SDK. Call once at app startup.
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('[ADS] Mobile Ads SDK initialized');

      // Emulators are automatically treated as test devices by the SDK.
      // No additional test device registration is required.
      // In debug mode, request configuration will use test ads automatically.

      // Preload ads
      _loadRewardedAd();
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('[ADS] Mobile Ads init FAILED: $e');
    }
  }

  /// Set premium status (for future Premium/No-Ads support).
  void setPremium(bool value) {
    _isPremium = value;
    if (_isPremium) {
      _disposeAll();
    }
  }

  void _disposeAll() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  void dispose() {
    _disposeAll();
  }

  // ──────────────────────────────────────────
  // REWARDED AD (Streak Protection)
  // ──────────────────────────────────────────

  bool get isRewardedAdReady => _rewardedAd != null && !_isPremium;

  void _loadRewardedAd() {
    if (_isPremium || _rewardedAdLoading || _rewardedAd != null) return;
    _rewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAdLoading = false;
          debugPrint('[ADS] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAdLoading = false;
          debugPrint('[ADS] Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show a rewarded ad for streak protection.
  /// Returns true only if the reward was successfully granted.
  Future<bool> showRewardedAd() async {
    if (_isPremium) return false;
    if (_rewardedAd == null) {
      debugPrint('[ADS] Rewarded ad not ready');
      return false;
    }

    bool rewarded = false;
    final ad = _rewardedAd!;
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd(); // Preload next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[ADS] Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        debugPrint('[ADS] User earned reward: ${reward.amount} ${reward.type}');
      },
    );

    // Small delay to ensure callback fires before we return
    await Future.delayed(const Duration(milliseconds: 500));

    if (rewarded) {
      await _markStreakProtectionUsed();
    }

    return rewarded;
  }

  // ──────────────────────────────────────────
  // INTERSTITIAL AD
  // ──────────────────────────────────────────

  bool get isInterstitialReady => _interstitialAd != null && !_isPremium;

  void _loadInterstitialAd() {
    if (_isPremium || _interstitialAdLoading || _interstitialAd != null) return;
    _interstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAdLoading = false;
          debugPrint('[ADS] Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialAdLoading = false;
          debugPrint('[ADS] Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Record a completed command. Returns true if an interstitial should show.
  bool onCommandCompleted() {
    if (_isPremium) return false;

    final count = completedSinceLastInterstitial + 1;
    _prefs.setInt(_keyCompletedSinceLastInterstitial, count);

    if (count >= AdConfig.interstitialThreshold && _isInterstitialCooldownMet) {
      return true;
    }
    return false;
  }

  /// Show an interstitial ad if one is ready. Returns true if shown.
  Future<bool> showInterstitialAd() async {
    if (_isPremium) return false;
    if (_interstitialAd == null) {
      debugPrint('[ADS] Interstitial ad not ready');
      return false;
    }
    if (!_isInterstitialCooldownMet) {
      debugPrint('[ADS] Interstitial cooldown not met');
      return false;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd(); // Preload next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[ADS] Interstitial failed to show: ${error.message}');
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    await ad.show();

    // Reset counters
    await _prefs.setInt(_keyCompletedSinceLastInterstitial, 0);
    await _prefs.setInt(
      _keyLastInterstitialTime,
      DateTime.now().millisecondsSinceEpoch,
    );

    return true;
  }

  int get completedSinceLastInterstitial =>
      _prefs.getInt(_keyCompletedSinceLastInterstitial) ?? 0;

  bool get _isInterstitialCooldownMet {
    final lastTime = _prefs.getInt(_keyLastInterstitialTime) ?? 0;
    if (lastTime == 0) return true;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastTime;
    return elapsed >= AdConfig.interstitialCooldownSeconds * 1000;
  }

  // ──────────────────────────────────────────
  // STREAK PROTECTION
  // ──────────────────────────────────────────

  /// Whether streak protection has already been used today.
  bool get isStreakProtectionUsedToday {
    final savedDate = _prefs.getString(_keyStreakProtectionDate) ?? '';
    final today = ExecutionStorageService.dateKey(DateTime.now());
    return savedDate == today;
  }

  /// Whether user is eligible for streak protection right now.
  /// Eligible when: streak > 0, no completed commands today, at least 1 skip,
  /// and protection not already used today.
  /// Works for both free users (ad-based) and premium users (ad-free).
  bool isStreakProtectionEligible({
    required int currentStreak,
    required int completedToday,
    required int skippedToday,
  }) {
    if (isStreakProtectionUsedToday) return false;
    if (currentStreak <= 0) return false;
    if (completedToday > 0) return false; // Streak is safe — has a completion
    if (skippedToday <= 0) return false; // No activity at all today
    return true;
  }

  Future<void> _markStreakProtectionUsed() async {
    final today = ExecutionStorageService.dateKey(DateTime.now());
    await _prefs.setString(_keyStreakProtectionDate, today);
    debugPrint('[ADS] Streak protection marked for $today');
  }

  /// Check if streak protection is active for a given date.
  bool isStreakProtectedForDate(String date) {
    final savedDate = _prefs.getString(_keyStreakProtectionDate) ?? '';
    return savedDate == date;
  }

  /// Mark streak protection for premium users (no ad required).
  Future<void> markStreakProtectionForPremium() async {
    await _markStreakProtectionUsed();
  }
}
