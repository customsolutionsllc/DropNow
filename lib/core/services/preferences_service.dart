import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drop_now/core/models/models.dart';

class PreferencesService {
  static const _keySystemActive = 'system_active';
  static const _keyPersonality = 'personality';
  static const _keyDifficulty = 'difficulty';
  static const _keyFrequency = 'frequency';
  static const _keyWindowStartHour = 'window_start_hour';
  static const _keyWindowStartMinute = 'window_start_minute';
  static const _keyWindowEndHour = 'window_end_hour';
  static const _keyWindowEndMinute = 'window_end_minute';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Expose the underlying SharedPreferences instance for other services.
  SharedPreferences get prefs => _p;

  SharedPreferences get _p {
    assert(
      _prefs != null,
      'PreferencesService not initialized. Call init() first.',
    );
    return _prefs!;
  }

  // --- System Active ---
  bool get isSystemActive => _p.getBool(_keySystemActive) ?? false;
  Future<void> setSystemActive(bool value) =>
      _p.setBool(_keySystemActive, value);

  // --- Personality ---
  Personality get personality {
    final index = _p.getInt(_keyPersonality) ?? Personality.commander.index;
    return Personality.values[index.clamp(0, Personality.values.length - 1)];
  }

  Future<void> setPersonality(Personality value) =>
      _p.setInt(_keyPersonality, value.index);

  // --- Difficulty ---
  Difficulty get difficulty {
    final index = _p.getInt(_keyDifficulty) ?? Difficulty.medium.index;
    return Difficulty.values[index.clamp(0, Difficulty.values.length - 1)];
  }

  Future<void> setDifficulty(Difficulty value) =>
      _p.setInt(_keyDifficulty, value.index);

  // --- Frequency (commands per day) ---
  int get frequency => _p.getInt(_keyFrequency) ?? 5;
  Future<void> setFrequency(int value) => _p.setInt(_keyFrequency, value);

  static const List<int> frequencyOptions = [3, 5, 8, 10];

  // --- Active Time Window ---
  TimeOfDay get windowStart {
    final h = _p.getInt(_keyWindowStartHour) ?? 9;
    final m = _p.getInt(_keyWindowStartMinute) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> setWindowStart(TimeOfDay value) async {
    await _p.setInt(_keyWindowStartHour, value.hour);
    await _p.setInt(_keyWindowStartMinute, value.minute);
  }

  TimeOfDay get windowEnd {
    final h = _p.getInt(_keyWindowEndHour) ?? 21;
    final m = _p.getInt(_keyWindowEndMinute) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> setWindowEnd(TimeOfDay value) async {
    await _p.setInt(_keyWindowEndHour, value.hour);
    await _p.setInt(_keyWindowEndMinute, value.minute);
  }

  /// Duration of the active window in minutes.
  int get windowDurationMinutes {
    final start = windowStart.hour * 60 + windowStart.minute;
    final end = windowEnd.hour * 60 + windowEnd.minute;
    if (end <= start) return 0;
    return end - start;
  }

  /// Whether the active window is valid (end > start, minimum 1 hour).
  bool get isWindowValid => windowDurationMinutes >= 60;
}
