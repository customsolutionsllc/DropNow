import 'dart:math';
import 'package:flutter/material.dart';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/command_generation_service.dart';
import 'package:drop_now/core/services/notification_service.dart';
import 'package:drop_now/core/services/preferences_service.dart';

class SchedulingService {
  final CommandGenerationService _commandService;
  final NotificationService _notificationService;
  final PreferencesService _prefsService;
  final _random = Random();

  /// The commands scheduled for today (in-memory for this phase).
  final List<ScheduledEntry> _todaySchedule = [];
  List<ScheduledEntry> get todaySchedule => List.unmodifiable(_todaySchedule);

  SchedulingService({
    required CommandGenerationService commandService,
    required NotificationService notificationService,
    required PreferencesService prefsService,
  }) : _commandService = commandService,
       _notificationService = notificationService,
       _prefsService = prefsService;

  /// Build and schedule today's commands based on current settings.
  Future<void> scheduleToday() async {
    await _notificationService.cancelAll();
    _todaySchedule.clear();

    if (!_prefsService.isSystemActive) return;
    if (!_prefsService.isWindowValid) return;

    final frequency = _prefsService.frequency;
    final difficulty = _prefsService.difficulty;
    final personality = _prefsService.personality;
    final start = _prefsService.windowStart;
    final end = _prefsService.windowEnd;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final windowMinutes = endMinutes - startMinutes;

    if (windowMinutes < 60 || frequency <= 0) return;

    // Generate evenly-spaced slots with randomized jitter
    final slotSize = windowMinutes / frequency;
    final times = <DateTime>[];

    for (int i = 0; i < frequency; i++) {
      final slotStart = startMinutes + (slotSize * i).round();
      final slotEnd = startMinutes + (slotSize * (i + 1)).round();
      // Add jitter: random time within the slot, but leave margin
      final margin = ((slotEnd - slotStart) * 0.15).round().clamp(1, 10);
      final min = slotStart + margin;
      final max = slotEnd - margin;
      final minutes = min + (max > min ? _random.nextInt(max - min) : 0);

      final scheduledTime = today.add(Duration(minutes: minutes));
      times.add(scheduledTime);
    }

    // Generate commands and schedule notifications for future times
    for (int i = 0; i < times.length; i++) {
      final command = _commandService.generate(
        difficulty: difficulty,
        personality: personality,
      );

      final entry = ScheduledEntry(command: command, scheduledTime: times[i]);
      _todaySchedule.add(entry);

      // Only schedule notifications for times that haven't passed
      if (times[i].isAfter(now)) {
        await _notificationService.scheduleCommandNotification(
          id: i + 100,
          title: 'DropNow Command! 💪',
          body: command.displayText,
          scheduledTime: times[i],
        );
      }
    }
  }

  /// Get the next upcoming scheduled command (or null if none left today).
  ScheduledEntry? get nextUpcoming {
    final now = DateTime.now();
    for (final entry in _todaySchedule) {
      if (entry.scheduledTime.isAfter(now)) {
        return entry;
      }
    }
    return null;
  }

  /// How many commands are scheduled for today.
  int get totalScheduled => _todaySchedule.length;

  /// How many commands are still upcoming.
  int get remainingCount {
    final now = DateTime.now();
    return _todaySchedule.where((e) => e.scheduledTime.isAfter(now)).length;
  }

  /// Format a time for display
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Format a DateTime for display
  static String formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class ScheduledEntry {
  final WorkoutCommand command;
  final DateTime scheduledTime;

  const ScheduledEntry({required this.command, required this.scheduledTime});
}
