import 'package:drop_now/core/models/workout_type.dart';
import 'package:drop_now/core/models/difficulty.dart';
import 'package:drop_now/core/models/personality.dart';

enum CommandStatus { generated, completed, skipped }

extension CommandStatusExtension on CommandStatus {
  String get label {
    switch (this) {
      case CommandStatus.generated:
        return 'Pending';
      case CommandStatus.completed:
        return 'Done';
      case CommandStatus.skipped:
        return 'Skipped';
    }
  }
}

/// A record of a command that was acted upon (DONE or SKIPPED).
class ExecutionRecord {
  final String id;
  final DateTime timestamp;
  final String date; // YYYY-MM-DD
  final WorkoutType workoutType;
  final int amount;
  final Difficulty difficulty;
  final Personality personality;
  final CommandStatus status;
  final double calories;
  final String displayText;

  const ExecutionRecord({
    required this.id,
    required this.timestamp,
    required this.date,
    required this.workoutType,
    required this.amount,
    required this.difficulty,
    required this.personality,
    required this.status,
    required this.calories,
    required this.displayText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'date': date,
      'workoutType': workoutType.index,
      'amount': amount,
      'difficulty': difficulty.index,
      'personality': personality.index,
      'status': status.index,
      'calories': calories,
      'displayText': displayText,
    };
  }

  factory ExecutionRecord.fromMap(Map<String, dynamic> map) {
    return ExecutionRecord(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      date: map['date'] as String,
      workoutType: WorkoutType.values[map['workoutType'] as int],
      amount: map['amount'] as int,
      difficulty: Difficulty.values[map['difficulty'] as int],
      personality: Personality.values[map['personality'] as int],
      status: CommandStatus.values[map['status'] as int],
      calories: (map['calories'] as num).toDouble(),
      displayText: map['displayText'] as String,
    );
  }
}
