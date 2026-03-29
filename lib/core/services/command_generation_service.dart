import 'dart:math';
import 'package:drop_now/core/models/models.dart';
import 'package:drop_now/core/services/workout_library.dart';

class CommandGenerationService {
  final _random = Random();

  /// Generate a single workout command based on settings.
  WorkoutCommand generate({
    required Difficulty difficulty,
    required Personality personality,
  }) {
    // Pick a random workout template
    final template = WorkoutLibrary
        .templates[_random.nextInt(WorkoutLibrary.templates.length)];

    // Get the rep/time range for the chosen difficulty
    final range = template.ranges[difficulty]!;
    final amount = range.$1 + _random.nextInt(range.$2 - range.$1 + 1);

    // Get tone phrases for this workout + personality
    final toneTemplates = WorkoutLibrary.toneTemplates[template.type];
    final phrases =
        toneTemplates?.forPersonality(personality) ??
        ['{amount} {exercise}. Go.'];
    final phrase = phrases[_random.nextInt(phrases.length)];

    // Build the display text
    final displayText = phrase
        .replaceAll('{amount}', amount.toString())
        .replaceAll('{exercise}', template.type.label.toLowerCase());

    return WorkoutCommand(
      id: _generateId(),
      displayText: displayText,
      workoutType: template.type,
      difficulty: difficulty,
      personality: personality,
      amount: amount,
      createdAt: DateTime.now(),
    );
  }

  String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(9999).toString().padLeft(4, '0');
    return 'cmd_${now}_$suffix';
  }
}
