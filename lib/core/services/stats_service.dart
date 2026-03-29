import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/execution_storage_service.dart';

/// Aggregated stats for a single day.
class DailyStats {
  final String date;
  final int totalCommands;
  final int completed;
  final int skipped;
  final double totalCalories;

  const DailyStats({
    required this.date,
    required this.totalCommands,
    required this.completed,
    required this.skipped,
    required this.totalCalories,
  });

  double get completionRate =>
      totalCommands > 0 ? completed / totalCommands : 0;

  static const empty = DailyStats(
    date: '',
    totalCommands: 0,
    completed: 0,
    skipped: 0,
    totalCalories: 0,
  );
}

/// Computes daily aggregations and streak from execution storage.
class StatsService {
  final ExecutionStorageService _storage;

  /// Optional callback to check if a date has streak protection (ad-based).
  /// Injected after AdService is created.
  bool Function(String date)? isDateStreakProtected;

  StatsService(this._storage);

  /// Stats for a specific date.
  DailyStats statsForDate(String date) {
    final records = _storage.getRecordsForDate(date);
    if (records.isEmpty) return DailyStats.empty;

    int completed = 0;
    int skipped = 0;
    double calories = 0;

    for (final r in records) {
      if (r.status == CommandStatus.completed) {
        completed++;
        calories += r.calories;
      } else if (r.status == CommandStatus.skipped) {
        skipped++;
      }
    }

    return DailyStats(
      date: date,
      totalCommands: records.length,
      completed: completed,
      skipped: skipped,
      totalCalories: calories,
    );
  }

  /// Stats for today.
  DailyStats get todayStats =>
      statsForDate(ExecutionStorageService.dateKey(DateTime.now()));

  /// Current streak: number of consecutive days (ending today or yesterday)
  /// where at least 1 command was completed OR streak protection was used.
  int get currentStreak {
    final now = DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

    bool _hasActivity(String dateKey) {
      final records = _storage.getRecordsForDate(dateKey);
      final hasCompletion = records.any(
        (r) => r.status == CommandStatus.completed,
      );
      if (hasCompletion) return true;
      // Streak protection counts as maintaining the streak
      return isDateStreakProtected?.call(dateKey) ?? false;
    }

    // First check today
    final todayKey = ExecutionStorageService.dateKey(checkDate);

    if (_hasActivity(todayKey)) {
      streak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // If no activity today, check if yesterday had one (streak still alive)
      checkDate = checkDate.subtract(const Duration(days: 1));
      final yesterdayKey = ExecutionStorageService.dateKey(checkDate);
      if (!_hasActivity(yesterdayKey)) {
        return 0; // No activity today or yesterday → streak is 0
      }
      streak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Walk backwards from the day before the start
    while (true) {
      final key = ExecutionStorageService.dateKey(checkDate);
      if (!_hasActivity(key)) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Total completed commands all time.
  int get totalCompleted {
    int total = 0;
    for (final date in _storage.allDates) {
      final records = _storage.getRecordsForDate(date);
      total += records.where((r) => r.status == CommandStatus.completed).length;
    }
    return total;
  }

  /// Total calories burned all time.
  double get totalCalories {
    double total = 0;
    for (final date in _storage.allDates) {
      final records = _storage.getRecordsForDate(date);
      for (final r in records) {
        if (r.status == CommandStatus.completed) {
          total += r.calories;
        }
      }
    }
    return total;
  }
}
