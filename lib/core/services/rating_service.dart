import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app rating prompts with cooldowns and eligibility checks.
class RatingService {
  final SharedPreferences _prefs;

  static const _keyLastPromptTime = 'rating_last_prompt_time';
  static const _cooldownDays = 7;
  static const _minCompletedCommands = 5;
  static const _minUsageDays = 3;

  bool _promptedThisSession = false;

  RatingService(this._prefs);

  /// Whether the user is eligible for a rating prompt right now.
  bool isEligible({
    required int totalCompleted,
    required int distinctDaysUsed,
  }) {
    if (_promptedThisSession) return false;

    // Check minimum thresholds
    final meetsCommands = totalCompleted >= _minCompletedCommands;
    final meetsDays = distinctDaysUsed >= _minUsageDays;
    if (!meetsCommands && !meetsDays) return false;

    // Check cooldown
    final lastPrompt = _prefs.getInt(_keyLastPromptTime) ?? 0;
    if (lastPrompt > 0) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastPrompt;
      final cooldownMs = _cooldownDays * 24 * 60 * 60 * 1000;
      if (elapsed < cooldownMs) return false;
    }

    return true;
  }

  /// Request the native in-app review dialog.
  /// Call this AFTER the user taps "Yes" on the soft prompt.
  Future<void> requestReview() async {
    _promptedThisSession = true;
    await _prefs.setInt(
      _keyLastPromptTime,
      DateTime.now().millisecondsSinceEpoch,
    );

    try {
      final reviewer = InAppReview.instance;
      if (await reviewer.isAvailable()) {
        await reviewer.requestReview();
        debugPrint('[RATING] native review dialog requested');
      } else {
        // Fallback: open store listing
        await reviewer.openStoreListing(appStoreId: 'com.dropnow.drop_now');
        debugPrint('[RATING] opened store listing as fallback');
      }
    } catch (e) {
      debugPrint('[RATING] requestReview failed: $e');
    }
  }

  /// Mark that the soft prompt was shown this session (even if dismissed).
  void markPromptShown() {
    _promptedThisSession = true;
    _prefs.setInt(_keyLastPromptTime, DateTime.now().millisecondsSinceEpoch);
  }
}
