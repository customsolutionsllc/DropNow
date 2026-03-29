import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_now/core/models/models.dart';

/// Persists execution records (DONE/SKIPPED) via SharedPreferences as JSON.
/// Keyed by date (YYYY-MM-DD) for efficient per-day lookups.
class ExecutionStorageService {
  static const _keyPrefix = 'exec_';
  static const _keyAllDates = 'exec_dates';

  SharedPreferences? _prefs;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'ExecutionStorageService not initialized.');
    return _prefs!;
  }

  /// Format a DateTime to YYYY-MM-DD key.
  static String dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Save an execution record. Appends to the day's list.
  Future<void> addRecord(ExecutionRecord record) async {
    final key = '$_keyPrefix${record.date}';
    final existing = _p.getStringList(key) ?? [];
    existing.add(jsonEncode(record.toMap()));
    await _p.setStringList(key, existing);

    // Track which dates have data
    final dates = _p.getStringList(_keyAllDates) ?? [];
    if (!dates.contains(record.date)) {
      dates.add(record.date);
      await _p.setStringList(_keyAllDates, dates);
    }
  }

  /// Get all records for a specific date (YYYY-MM-DD).
  List<ExecutionRecord> getRecordsForDate(String date) {
    final key = '$_keyPrefix$date';
    final raw = _p.getStringList(key) ?? [];
    return raw.map((json) {
      return ExecutionRecord.fromMap(jsonDecode(json) as Map<String, dynamic>);
    }).toList();
  }

  /// Get all records for today.
  List<ExecutionRecord> get todayRecords =>
      getRecordsForDate(dateKey(DateTime.now()));

  /// Get all dates that have records, sorted descending.
  List<String> get allDates {
    final dates = _p.getStringList(_keyAllDates) ?? [];
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  /// Check if a command ID has already been recorded (prevent duplicates).
  /// Optionally specify [date] to check a specific day; defaults to today.
  bool isRecorded(String commandId, {String? date}) {
    date ??= dateKey(DateTime.now());
    final records = getRecordsForDate(date);
    return records.any((r) => r.id == commandId);
  }
}
