enum Difficulty { easy, medium, savage }

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.savage:
        return 'Savage';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Light reps. Good for beginners.';
      case Difficulty.medium:
        return 'Solid workout. Real effort.';
      case Difficulty.savage:
        return 'No mercy. Maximum output.';
    }
  }

  String get emoji {
    switch (this) {
      case Difficulty.easy:
        return '🟢';
      case Difficulty.medium:
        return '🟡';
      case Difficulty.savage:
        return '🔴';
    }
  }
}
