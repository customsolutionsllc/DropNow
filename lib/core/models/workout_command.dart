import 'package:drop_now/core/models/workout_type.dart';
import 'package:drop_now/core/models/difficulty.dart';
import 'package:drop_now/core/models/personality.dart';

class WorkoutCommand {
  final String id;
  final String displayText;
  final WorkoutType workoutType;
  final Difficulty difficulty;
  final Personality personality;
  final int amount;
  final DateTime createdAt;

  const WorkoutCommand({
    required this.id,
    required this.displayText,
    required this.workoutType,
    required this.difficulty,
    required this.personality,
    required this.amount,
    required this.createdAt,
  });

  /// Whether this is a time-based exercise (seconds) or rep-based
  bool get isTimeBased => workoutType.isTimeBased;

  /// Human-readable amount string
  String get amountLabel =>
      isTimeBased ? '$amount seconds' : '$amount ${workoutType.label}';

  /// Estimated calories for this command
  double get estimatedCalories => amount * workoutType.caloriesPerUnit;

  /// Estimated duration in seconds
  int get estimatedDurationSeconds {
    if (isTimeBased) return amount;
    // Rough: ~3 seconds per rep for most exercises
    return (amount * 3).clamp(10, 300);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayText': displayText,
      'workoutType': workoutType.index,
      'difficulty': difficulty.index,
      'personality': personality.index,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutCommand.fromMap(Map<String, dynamic> map) {
    return WorkoutCommand(
      id: map['id'] as String,
      displayText: map['displayText'] as String,
      workoutType: WorkoutType.values[map['workoutType'] as int],
      difficulty: Difficulty.values[map['difficulty'] as int],
      personality: Personality.values[map['personality'] as int],
      amount: map['amount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
