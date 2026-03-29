enum WorkoutType {
  pushups,
  squats,
  jumpingJacks,
  plank,
  lunges,
  wallSit,
  sitUps,
  burpees,
  highKnees,
  mountainClimbers,
  calfRaises,
  tricepDips,
}

extension WorkoutTypeExtension on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.pushups:
        return 'Pushups';
      case WorkoutType.squats:
        return 'Squats';
      case WorkoutType.jumpingJacks:
        return 'Jumping Jacks';
      case WorkoutType.plank:
        return 'Plank';
      case WorkoutType.lunges:
        return 'Lunges';
      case WorkoutType.wallSit:
        return 'Wall Sit';
      case WorkoutType.sitUps:
        return 'Sit-Ups';
      case WorkoutType.burpees:
        return 'Burpees';
      case WorkoutType.highKnees:
        return 'High Knees';
      case WorkoutType.mountainClimbers:
        return 'Mountain Climbers';
      case WorkoutType.calfRaises:
        return 'Calf Raises';
      case WorkoutType.tricepDips:
        return 'Tricep Dips';
    }
  }

  /// Whether this exercise is measured in time (seconds) vs reps
  bool get isTimeBased {
    switch (this) {
      case WorkoutType.plank:
      case WorkoutType.wallSit:
        return true;
      default:
        return false;
    }
  }

  String get unit => isTimeBased ? 'sec' : 'reps';

  /// Approximate calories per rep (rough estimate for future use)
  double get caloriesPerUnit {
    switch (this) {
      case WorkoutType.pushups:
        return 0.5;
      case WorkoutType.squats:
        return 0.4;
      case WorkoutType.jumpingJacks:
        return 0.3;
      case WorkoutType.plank:
        return 0.1; // per second
      case WorkoutType.lunges:
        return 0.5;
      case WorkoutType.wallSit:
        return 0.08; // per second
      case WorkoutType.sitUps:
        return 0.4;
      case WorkoutType.burpees:
        return 1.0;
      case WorkoutType.highKnees:
        return 0.35;
      case WorkoutType.mountainClimbers:
        return 0.45;
      case WorkoutType.calfRaises:
        return 0.2;
      case WorkoutType.tricepDips:
        return 0.45;
    }
  }
}
