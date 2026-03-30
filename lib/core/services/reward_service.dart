import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_now/core/services/execution_storage_service.dart';

/// Daily reward types granted on first open of the day.
enum DailyRewardType { freeCooldownSkip, streakShield }

/// Represents a daily reward.
class DailyReward {
  final DailyRewardType type;
  final String title;
  final String description;
  final String emoji;

  const DailyReward({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

/// Manages daily login rewards. Grants one reward per day on first open.
class RewardService {
  static const _keyLastRewardDate = 'reward_last_date';
  static const _keyFreeCooldownSkip = 'reward_free_cooldown';
  static const _keyStreakShield = 'reward_streak_shield';

  final SharedPreferences _prefs;
  final _random = Random();

  RewardService(this._prefs);

  /// Whether the user has already received today's daily reward.
  bool get isRewardClaimedToday {
    final last = _prefs.getString(_keyLastRewardDate) ?? '';
    return last == ExecutionStorageService.dateKey(DateTime.now());
  }

  /// Check if user has an active free cooldown skip (from daily reward).
  bool get hasFreeCooldownSkip => _prefs.getBool(_keyFreeCooldownSkip) ?? false;

  /// Check if user has an active streak shield (from daily reward).
  bool get hasStreakShield => _prefs.getBool(_keyStreakShield) ?? false;

  /// Consume the free cooldown skip.
  Future<void> useFreeCooldownSkip() async {
    await _prefs.setBool(_keyFreeCooldownSkip, false);
    debugPrint('[REWARD] Free cooldown skip consumed');
  }

  /// Consume the streak shield.
  Future<void> useStreakShield() async {
    await _prefs.setBool(_keyStreakShield, false);
    debugPrint('[REWARD] Streak shield consumed');
  }

  /// Generate and grant today's daily reward.
  /// Returns null if already granted today.
  Future<DailyReward?> claimDailyReward() async {
    if (isRewardClaimedToday) return null;

    // Clear previous reward state
    await _prefs.setBool(_keyFreeCooldownSkip, false);
    await _prefs.setBool(_keyStreakShield, false);

    // Pick a random reward
    final rewards = [
      DailyRewardType.freeCooldownSkip,
      DailyRewardType.streakShield,
    ];
    final type = rewards[_random.nextInt(rewards.length)];

    // Apply reward
    switch (type) {
      case DailyRewardType.freeCooldownSkip:
        await _prefs.setBool(_keyFreeCooldownSkip, true);
        await _markClaimed();
        return const DailyReward(
          type: DailyRewardType.freeCooldownSkip,
          title: 'Free Cooldown Skip',
          description: 'Get an instant command without watching an ad!',
          emoji: '⚡',
        );
      case DailyRewardType.streakShield:
        await _prefs.setBool(_keyStreakShield, true);
        await _markClaimed();
        return const DailyReward(
          type: DailyRewardType.streakShield,
          title: 'Streak Shield',
          description: 'Protect your streak today without watching an ad!',
          emoji: '🛡️',
        );
    }
  }

  Future<void> _markClaimed() async {
    final today = ExecutionStorageService.dateKey(DateTime.now());
    await _prefs.setString(_keyLastRewardDate, today);
    debugPrint('[REWARD] Daily reward granted for $today');
  }
}
